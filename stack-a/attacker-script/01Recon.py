#!/usr/bin/env python3
"""
Step 1 - T1595: Active Scanning

Generates realistic WPScan-style recon traffic against the target.
This step doesn't need to "suicceed" at anything. Its only job is to
produce the log entries a real attackers recon phase would leave behind,
so students have something authentic to find in the apache_access.log.

Usage:
    python3 01Recon.py --target http://172.28.0.10
"""

import argparse
import requests
import random
import time 

# A small, realistic slice of what WPScan's plugin wordlist looks like.
# Real WPScan checks thousands of slugs. We don't need thousands of log
# lines, just enough that the pattern (many 404s, one 200, or 301 for the
# real installed plugin) is recognizable in the access log.
PLUGIN_SLUGS_TO_CHECK = [
    "akismet",
    "all-in-one-seo-pack",
    "all-in-one-wp-migration",
    "all-in-one-wp-security-and-firewall",
    "antispam-bee",
    "autoptimize",
    "bbpress",
    "better-wp-security",
    "broken-link-checker",
    "classic-editor",
    "contact-form-7",
    "cookie-law-info",
    "custom-post-type-ui",
    "disable-comments",
    "duplicate-post",
    "duplicator",
    "elementor",
    "envira-gallery-lite",
    "google-analytics-for-wordpress",
    "google-sitemap-generator",
    "jetpack",
    "wp-fastest-cache",
    "wp-super-cache",
    "wpdiscuz",          # the one that actually exists
    "wordfence",
    "woocommerce",
    "yoast-seo",
]

# Fingerprints paths that a recon checks.
# Version Disclosure, Loing Page, REST API

FINGERPRINT_PATHS = [
    "/",
    "/wp-login.php",
    "/wp-json/",
    "/readme.html",
    "/xmlrpc.php",
    "/wp-cron.php",
    "/wp-config.php.bak"
]

SCANNER_USER_AGENT = "WPScan v3.8.20 (https://wpscan.com/wordpress-security-scanner)"

def fingerprint_target(session: requests.Session, base_url: str) -> None:
    """ 
        Hit the small set of paths that reveal Content Management System (CMS) 
        type/version/attack surface 
    """
    print("[*] Fingerprinting target...")
    for path in FINGERPRINT_PATHS:
        url = base_url.rstrip("/") + path
        try:
            resp = session.get(url, timeout=5)
            print(f"    GET {path:30s} -> {resp.status_code}")
        except requests.RequestException as e:
            print(f"    GET {path:30s} -> ERROR: {e}")
        time.sleep(random.uniform(0.3, 1.2)) # Random delay to simulate human-like behavior

def enumerate_plugins(session: requests.Session, base_url: str) -> None:
    """
        Probe for known plugin readme.txt files. This is a classic WPScan technique to enumerate installed plugins.

        WordPress here returns a soft-404s: a 200 status with a generic HTML page
        for anything under /up-content/plugins/ that doesn't exist. Status
        code alone is unreliable. A real readme.txt is served as text/plain and
        starts with "=== Plugin Name ===". Check both.
    """
    print("[*] Enumerating plugins...")
    for slug in PLUGIN_SLUGS_TO_CHECK:
        url = f"{base_url.rstrip('/')}/wp-content/plugins/{slug}/readme.txt"
        try:
            resp = session.get(url, timeout=5)
            content_type = resp.headers.get("Content-Type", "")
            is_plaintext = "text/plain" in content_type
            starts_like_readme = resp.text.lstrip().startswith("=== ")
            looks_real = resp.status_code == 200 and is_plaintext and starts_like_readme
            marker = " <-- FOUND" if looks_real else ""
            print(f"    GET /wp-content/plugins/{slug}/readme.txt -> {resp.status_code}{marker}")
        except requests.RequestException as e:
            print(f"    GET .../{slug}/readme.txt -> ERROR: ({e})")
        time.sleep(random.uniform(0.4, 1.5)) # Random delay to simulate human-like behavior

def enumerate_users(session: requests.Session, base_url: str) -> None:
    """
        WordPress REST API leaks usernames by default unless locked down.
    """
    print("[*] Enumerating users via REST API...")
    url = base_url.rstrip("/") + "/wp-json/wp/v2/users"
    try:
        resp = session.get(url, timeout=5)
        print(f"    GET /wp-json/wp/v2/users -> {resp.status_code}")
        if resp.status_code == 200:
            try:
                users = resp.json()
                for u in users:
                    print(f"    found user: {u.get('slug', '?')}")
            except ValueError:
                print("     response was not JSON, skipping parse")
    except requests.RequestException as e:
        print(f"    GET /wp-json/wp/v2/users -> ERROR: {e}")

def main():
    parser = argparse.ArgumentParser(description="Step 1: Active Scanning (T1595)")
    parser.add_argument(
        "--target", 
        default="http://172.28.0.10", 
        help="Base URL of the target (default: %(default)s)",
    )
    args = parser.parse_args()

    session = requests.Session()
    session.headers.update({"User-Agent": SCANNER_USER_AGENT})

    print(f"[*] Starting recon against {args.target}")
    start = time.time()
    
    fingerprint_target(session, args.target)
    enumerate_plugins(session, args.target)
    enumerate_users(session, args.target)
    
    elapsed = time.time() - start
    print(f"[*] Recon completed in {elapsed:.1f}s")
    
if __name__ == "__main__":
    main()


        