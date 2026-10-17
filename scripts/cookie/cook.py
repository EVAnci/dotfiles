#!/usr/bin/env python3
"""Sincroniza la autenticación OAuth de Codex con OpenCode.

OpenCode 1.x usaba auth.json directamente. OpenCode 2.x importa ese archivo
una sola vez y luego guarda las credenciales en opencode.db. Este programa
soporta ambos formatos sin imprimir secretos.
"""

from __future__ import annotations

import argparse
import base64
import datetime as dt
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import uuid


LABEL = "Codex CLI (sincronizado)"
OAUTH_METHOD = "chatgpt-browser"


class SyncError(RuntimeError):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Sincroniza el inicio de sesión de Codex con OpenCode."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="valida y muestra qué haría, sin modificar archivos",
    )
    parser.add_argument(
        "--no-reload",
        action="store_true",
        help="no solicita a OpenCode que recargue su configuración",
    )
    return parser.parse_args()


def codex_auth_path() -> Path:
    codex_home = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))
    return codex_home / "auth.json"


def opencode_data_dir() -> Path:
    xdg_data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share"))
    return xdg_data / "opencode"


def load_json(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as handle:
            value = json.load(handle)
    except FileNotFoundError as exc:
        raise SyncError(f"No existe {path}") from exc
    except (OSError, json.JSONDecodeError) as exc:
        raise SyncError(f"No se pudo leer {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise SyncError(f"{path} no contiene un objeto JSON")
    return value


def jwt_claims(token: str) -> dict:
    parts = token.split(".")
    if len(parts) != 3:
        raise SyncError("El access_token de Codex no es un JWT válido")
    payload = parts[1]
    payload += "=" * (-len(payload) % 4)
    try:
        decoded = base64.urlsafe_b64decode(payload.encode("ascii"))
        claims = json.loads(decoded)
    except (ValueError, UnicodeError, json.JSONDecodeError) as exc:
        raise SyncError("No se pudo decodificar el access_token de Codex") from exc
    if not isinstance(claims, dict):
        raise SyncError("El payload del access_token no es un objeto JSON")
    return claims


def extract_credential(auth: dict) -> dict:
    tokens = auth.get("tokens")
    if not isinstance(tokens, dict):
        raise SyncError("Falta el objeto tokens en la autenticación de Codex")

    access = tokens.get("access_token")
    refresh = tokens.get("refresh_token")
    if not isinstance(access, str) or not access:
        raise SyncError("Falta tokens.access_token en la autenticación de Codex")
    if not isinstance(refresh, str) or not refresh:
        raise SyncError("Falta tokens.refresh_token en la autenticación de Codex")

    claims = jwt_claims(access)
    exp = claims.get("exp")
    if not isinstance(exp, (int, float)):
        raise SyncError("El access_token no contiene una expiración válida")
    expires = int(exp * 1000)
    if expires <= int(time.time() * 1000):
        raise SyncError("El access_token de Codex ya venció; inicia sesión en Codex nuevamente")

    namespaced = claims.get("https://api.openai.com/auth")
    if not isinstance(namespaced, dict):
        namespaced = {}
    account_id = (
        tokens.get("account_id")
        or claims.get("chatgpt_account_id")
        or namespaced.get("chatgpt_account_id")
    )
    if not isinstance(account_id, str) or not account_id:
        raise SyncError("No se pudo determinar el account_id de ChatGPT")

    return {
        "type": "oauth",
        "access": access,
        "refresh": refresh,
        "expires": expires,
        "accountId": account_id,
    }


def has_v2_schema(db_path: Path) -> bool:
    if not db_path.is_file():
        return False
    try:
        uri = f"file:{db_path}?mode=ro"
        with sqlite3.connect(uri, uri=True) as db:
            row = db.execute(
                "SELECT 1 FROM sqlite_master WHERE type='table' AND name='credential'"
            ).fetchone()
            return row is not None
    except sqlite3.Error as exc:
        raise SyncError(f"No se pudo inspeccionar {db_path}: {exc}") from exc


def backup_database(db: sqlite3.Connection, db_path: Path) -> Path:
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup_path = db_path.with_name(f"{db_path.name}.cook-backup-{stamp}")
    try:
        with sqlite3.connect(backup_path) as backup:
            db.backup(backup)
        os.chmod(backup_path, 0o600)
    except (OSError, sqlite3.Error) as exc:
        try:
            backup_path.unlink(missing_ok=True)
        except OSError:
            pass
        raise SyncError(f"No se pudo crear el respaldo {backup_path}: {exc}") from exc
    return backup_path


def sync_v2(db_path: Path, credential: dict, dry_run: bool) -> tuple[str, Path | None]:
    try:
        db = sqlite3.connect(db_path, timeout=30)
        db.execute("PRAGMA busy_timeout = 30000")
    except sqlite3.Error as exc:
        raise SyncError(f"No se pudo abrir {db_path}: {exc}") from exc

    with db:
        columns = {row[1] for row in db.execute("PRAGMA table_info(credential)")}
        required = {
            "id", "integration_id", "label", "value", "connector_id",
            "method_id", "active", "time_created", "time_updated",
        }
        if not required.issubset(columns):
            raise SyncError("La tabla credential de OpenCode tiene un esquema desconocido")

        target = db.execute(
            """
            SELECT id
            FROM credential
            WHERE integration_id = 'openai'
              AND json_valid(value)
              AND json_extract(value, '$.type') = 'oauth'
            ORDER BY (label = ?) DESC, (active = 1) DESC, time_updated DESC
            LIMIT 1
            """,
            (LABEL,),
        ).fetchone()

    action = "actualizar" if target else "crear"
    if dry_run:
        db.close()
        return action, None

    backup_path = backup_database(db, db_path)
    now = int(time.time() * 1000)
    # OpenCode 2 validates the JSON value of every credential. The OAuth
    # method and provider-specific data must live in this JSON as well as in
    # the indexed SQL columns; otherwise Credential.all() rejects the row.
    value = json.dumps(
        {
            "type": "oauth",
            "methodID": OAUTH_METHOD,
            "refresh": credential["refresh"],
            "access": credential["access"],
            "expires": credential["expires"],
            "metadata": {"accountID": credential["accountId"]},
        },
        separators=(",", ":"),
        ensure_ascii=False,
    )

    try:
        db.execute("BEGIN IMMEDIATE")
        db.execute(
            "UPDATE credential SET active = 0, time_updated = ? "
            "WHERE integration_id = 'openai' AND active = 1",
            (now,),
        )
        if target:
            db.execute(
                """
                UPDATE credential
                SET label = ?, value = ?, connector_id = NULL,
                    method_id = ?, active = 1, time_updated = ?
                WHERE id = ?
                """,
                (LABEL, value, OAUTH_METHOD, now, target[0]),
            )
        else:
            credential_id = f"cred_{uuid.uuid4().hex}"
            db.execute(
                """
                INSERT INTO credential
                    (id, integration_id, label, value, connector_id,
                     method_id, active, time_created, time_updated)
                VALUES (?, 'openai', ?, ?, NULL, ?, 1, ?, ?)
                """,
                (credential_id, LABEL, value, OAUTH_METHOD, now, now),
            )
        db.commit()
    except sqlite3.Error as exc:
        db.rollback()
        raise SyncError(f"No se pudo actualizar la credencial de OpenCode: {exc}") from exc
    finally:
        db.close()

    return action, backup_path


def atomic_write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(value, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temp_path, 0o600)
        os.replace(temp_path, path)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise


def sync_legacy(auth_path: Path, credential: dict, dry_run: bool) -> Path | None:
    existing = load_json(auth_path) if auth_path.exists() else {}
    if dry_run:
        return None
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup_path = auth_path.with_name(f"{auth_path.name}.cook-backup-{stamp}")
    if auth_path.exists():
        shutil.copy2(auth_path, backup_path)
        os.chmod(backup_path, 0o600)
    else:
        backup_path = None
    existing["openai"] = credential
    try:
        atomic_write_json(auth_path, existing)
    except OSError as exc:
        raise SyncError(f"No se pudo actualizar {auth_path}: {exc}") from exc
    return backup_path


def reload_opencode() -> None:
    binary = shutil.which("opencode")
    if not binary:
        print("Aviso: no se encontró opencode; reinícialo manualmente.", file=sys.stderr)
        return
    try:
        result = subprocess.run(
            [binary, "reload"], stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE, text=True, timeout=30, check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        print(f"Aviso: no se pudo recargar OpenCode ({exc}); reinícialo manualmente.", file=sys.stderr)
        return
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()
        suffix = f": {detail[-1]}" if detail else ""
        print(
            f"Aviso: OpenCode no aceptó la recarga{suffix}. Reinícialo manualmente.",
            file=sys.stderr,
        )


def main() -> int:
    args = parse_args()
    source = codex_auth_path()
    credential = extract_credential(load_json(source))
    expiry = dt.datetime.fromtimestamp(
        credential["expires"] / 1000, tz=dt.timezone.utc
    ).isoformat()

    data_dir = opencode_data_dir()
    db_path = Path(os.environ.get("OPENCODE_DB", data_dir / "opencode.db"))
    legacy_path = data_dir / "auth.json"

    print(f"Origen: {source}")
    print(f"Token vigente hasta: {expiry}")

    if has_v2_schema(db_path):
        action, backup = sync_v2(db_path, credential, args.dry_run)
        if args.dry_run:
            print(f"Simulación: se va a {action} la credencial OAuth OpenAI en {db_path}")
            return 0
        print(f"OpenCode 2: credencial OAuth OpenAI sincronizada ({action}).")
        print(f"Respaldo: {backup}")
        if not args.no_reload:
            reload_opencode()
    else:
        backup = sync_legacy(legacy_path, credential, args.dry_run)
        if args.dry_run:
            print(f"Simulación: se va a actualizar {legacy_path}")
            return 0
        print(f"OpenCode 1: credencial OAuth OpenAI sincronizada en {legacy_path}.")
        if backup:
            print(f"Respaldo: {backup}")

    print("Listo. Los tokens no se mostraron en pantalla.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SyncError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
