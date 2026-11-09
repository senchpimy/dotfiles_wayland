#!/usr/bin/env python3
import os
import subprocess
import json
import time
import hashlib

# Configuration paths based on your system
WALLPAPER_DIR = "/home/plof/configs/hyde/themes/Local/wallpapers"
COLORS_JSON = "/home/plof/.local/state/quickshell/user/generated/colors.json"
AWWW_SCRIPT = "/home/plof/configs/bin/awwwallpaper.sh"

def get_colors_hash():
    if not os.path.exists(COLORS_JSON):
        return None
    with open(COLORS_JSON, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def get_wallpapers():
    valid_exts = ('.jpg', '.jpeg', '.png', '.gif')
    return sorted([os.path.join(WALLPAPER_DIR, f) for f in os.listdir(WALLPAPER_DIR) if f.lower().endswith(valid_exts)])

def test_direction(direction):
    print(f"\n--- Testing direction: {direction} ---")
    walls = get_wallpapers()
    results = []
    
    for i in range(len(walls)):
        old_hash = get_colors_hash()
        
        print(f"[{i+1}/{len(walls)}] Switching wallpaper ({direction})...", end="\r")
        
        # Run the wallpaper script
        proc = subprocess.run([AWWW_SCRIPT, f"-{direction}"], capture_output=True, text=True)
        
        # Give a small buffer for FileView/matugen to settle if needed, 
        # though matugen should be synchronous now.
        time.sleep(1) 
        
        new_hash = get_colors_hash()
        
        status = "✅ OK" if old_hash != new_hash else "❌ FAILED (Colors didn't change)"
        if proc.returncode != 0:
            status = f"💥 CRASHED (Exit {proc.returncode})"
            
        results.append({
            "step": i,
            "status": status,
            "output_snippet": proc.stderr.splitlines()[-1:] if proc.stderr else ""
        })

    for res in results:
        print(f"Step {res['step']}: {res['status']} {res['output_snippet']}")

if __name__ == "__main__":
    print("Starting Color Generation Diagnostic...")
    test_direction("n")
    print("\nResetting for next test...")
    time.sleep(2)
    test_direction("p")
