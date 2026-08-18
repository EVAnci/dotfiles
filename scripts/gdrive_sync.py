#!/usr/bin/env python3

import argparse
import subprocess
import os
import sys
import tempfile

# Mapping for base paths
CATEGORIES = {
    "1": ("~/Documentos/UM/1ro/", "UMGDrive:UM/1ro"),
    "2": ("~/Documentos/UM/2do/", "UMGDrive:UM/2do"),
    "3": ("~/Documentos/UM/3ro/", "UMGDrive:UM/3ro"),
    "4": ("~/Documentos/UM/4to/", "UMGDrive:UM/4to"),
    "5": ("~/Documentos/UM/5to/", "UMGDrive:UM/5to"),
}

def build_git_exclude_file(local_root):
    """
    Recorre local_root buscando directorios .git y genera un archivo de
    exclusiones para rclone con el repositorio completo (directorio padre
    de cada .git) excluido, en vez de solo el .git en sí.

    rclone --exclude-from usa patrones relativos a la raíz de la sync
    (local_root en este caso), con sintaxis tipo:
        NombreRepo/**
    lo que excluye el directorio del repo y todo su contenido.
    """
    local_root = os.path.abspath(local_root)
    patterns = []

    for dirpath, dirnames, _ in os.walk(local_root, followlinks=True):
        if ".git" in dirnames:
            repo_dir = dirpath
            rel_repo = os.path.relpath(repo_dir, local_root)
            if rel_repo == ".":
                # local_root mismo es un repo git: no tiene sentido
                # "excluirlo" (excluiria todo), así que solo se ignora .git
                patterns.append(".git/**")
            else:
                patterns.append(f"{rel_repo}/**")
            # no bajar más adentro de este repo, ya está marcado completo
            dirnames[:] = [d for d in dirnames if d != ".git"]
            dirnames.clear()

    if not patterns:
        return None

    fd, path = tempfile.mkstemp(prefix="gdrive_sync_excludes_", suffix=".txt")
    with os.fdopen(fd, "w") as f:
        f.write("\n".join(patterns) + "\n")

    print(f"[*] Excluding {len(patterns)} git repo(s) via {path}:")
    for p in patterns:
        print(f"    - {p}")

    return path


def run_rclone(source, destination, mode='sync', push=False, dry_run=False):
    # Expand ~ and resolve symlinks (crucial for ~/Documentos -> /run/media/elio/Documentos)
    if not source.startswith("UMGDrive:"):
        source = os.path.expanduser(source)
        source = os.path.realpath(os.path.normpath(source))
    if not destination.startswith("UMGDrive:"):
        destination = os.path.expanduser(destination)
        destination = os.path.realpath(os.path.normpath(destination))
    
    print(f"[*] Running rclone {mode} from {source} to {destination}...")
    
    # --copy-links (-L) es necesario cuando la ruta base es un symlink
    # o cuando hay symlinks a directorios dentro como Computación II / Analogica 2
    base_cmd = ["rclone", mode, source, destination, "--progress", "-L"]
    if dry_run:
        base_cmd = base_cmd + ["--dry-run"]
    
    exclude_file = None
    try:
        if push:
            # source es local en el caso de push: siempre queremos excluir
            # los repos para no subirlos (y para que sync no los borre en Drive)
            exclude_file = build_git_exclude_file(source)
            if exclude_file:
                base_cmd = base_cmd + ["--exclude-from", exclude_file]
            subprocess.run(base_cmd, check=True)
        else:
            # pull: destination es local. Solo importa excluir en modo sync,
            # ya que es el único que borra archivos en destino. Con copy no
            # hace falta: copy nunca elimina nada en destination.
            if mode == 'sync':
                exclude_file = build_git_exclude_file(destination)
                if exclude_file:
                    base_cmd = base_cmd + ["--exclude-from", exclude_file]
            subprocess.run(base_cmd, check=True)
        print(f"[+] Operation finished successfully.")
    except subprocess.CalledProcessError as e:
        print(f"[!] Error during {mode}: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"[!] Error: rclone not found. Please ensure it is installed.", file=sys.stderr)
        sys.exit(1)
    finally:
        if exclude_file and os.path.exists(exclude_file):
            os.remove(exclude_file)

def sync_to_gdrive(local_path, remote_path, mode='sync', dry_run=False):
    run_rclone(local_path, remote_path, mode, push=True, dry_run=dry_run)

def sync_from_gdrive(local_path, remote_path, mode='sync', dry_run=False):
    run_rclone(remote_path, local_path, mode, dry_run)

def main():
    parser = argparse.ArgumentParser(description="Sync directory to Google Drive.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-d", "--directory", nargs=2, metavar=('LOCAL', 'REMOTE'), help="Local and remote directory paths")
    group.add_argument("-y", "--category", nargs=3, metavar=('KEY', 'LOCAL_SUB', 'REMOTE_SUB'), help="Category key (1-5) indicating the year, followed by [local subdir] [remote subdir]")
    
    parser.add_argument("-p", "--pull", action="store_true", help="Pull from remote to local")
    parser.add_argument("-c", "--copy", action="store_true", help="Use copy instead of sync (non-destructive)")
    parser.add_argument("-r", "--dry-run", action="store_true", help="Simulate the operation without real changes.")

    args = parser.parse_args()
    
    mode = 'copy' if args.copy else 'sync'
    sync_func = sync_from_gdrive if args.pull else sync_to_gdrive

    if args.category:
        key, local_sub, remote_sub = args.category
        if key not in CATEGORIES:
            print(f"[!] Error: Invalid category key. Choose from {list(CATEGORIES.keys())}")
            sys.exit(1)
        
        base_local, base_remote = CATEGORIES[key]
        full_local = os.path.join(base_local, local_sub)
        full_remote = os.path.join(base_remote, remote_sub)
        sync_func(full_local, full_remote, mode=mode, dry_run=args.dry_run)
        
    elif args.directory:
        local_path, remote_path = args.directory
        remote_path = "UMGDrive:"+remote_path
        sync_func(local_path, remote_path, mode=mode, dry_run=args.dry_run)

if __name__ == "__main__":
    main()
