#!/usr/bin/env python3

import argparse
import subprocess
import os
import sys

# Mapping for base paths
CATEGORIES = {
    "1": ("~/Documentos/UMendoza/1ro/", "UMGDrive:UM/1ro"),
    "2": ("~/Documentos/UMendoza/2do/", "UMGDrive:UM/2do"),
    "3": ("~/Documentos/UMendoza/3ro/", "UMGDrive:UM/3ro"),
    "4": ("~/Documentos/UMendoza/4to/", "UMGDrive:UM/4to"),
    "5": ("~/Documentos/UMendoza/5to/", "UMGDrive:UM/5to"),
}

def run_rclone(source, destination, mode='sync'):
    # Expand ~ if it's a local path
    if not source.startswith("UMGDrive:"):
        source = os.path.expanduser(source)
    if not destination.startswith("UMGDrive:"):
        destination = os.path.expanduser(destination)
    
    print(f"[*] Running rclone {mode} from {source} to {destination}...")
    
    try:
        subprocess.run(["rclone", mode, source, destination, "--progress", "--exclude-if-present", ".git"], check=True)
        print(f"[+] Operation finished successfully.")
    except subprocess.CalledProcessError as e:
        print(f"[!] Error during {mode}: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"[!] Error: rclone not found. Please ensure it is installed.", file=sys.stderr)
        sys.exit(1)

def sync_to_gdrive(local_path, remote_path, mode='sync'):
    run_rclone(local_path, remote_path, mode)

def sync_from_gdrive(local_path, remote_path, mode='sync'):
    run_rclone(remote_path, local_path, mode)

def main():
    parser = argparse.ArgumentParser(description="Sync directory to Google Drive.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-d", "--directory", nargs=2, metavar=('LOCAL', 'REMOTE'), help="Local and remote directory paths")
    group.add_argument("-y", "--category", nargs=3, metavar=('KEY', 'LOCAL_SUB', 'REMOTE_SUB'), help="Category key (1-5) indicating the year, followed by [local subdir] [remote subdir]")
    
    parser.add_argument("-p", "--pull", action="store_true", help="Pull from remote to local")
    parser.add_argument("-c", "--copy", action="store_true", help="Use copy instead of sync (non-destructive)")

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
        sync_func(full_local, full_remote, mode=mode)
        
    elif args.directory:
        local_path, remote_path = args.directory
        remote_path = "UMGDrive:"+remote_path
        sync_func(local_path, remote_path, mode=mode)

if __name__ == "__main__":
    main()
