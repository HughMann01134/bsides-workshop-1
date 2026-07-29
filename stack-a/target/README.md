# stack-a/target — Vulnerable WordPress Target

The compromised target for Workshop 1. This folder just stands up
WordPress + wpDiscuz; the attack against it, the sensors watching it,
and the benign traffic bracketing it are separate folders (see repo
root README for the full layout).

## Prerequisites

- Running inside the `stackant` VM (Ubuntu 22.04 Server, VMware
  Workstation Pro) — required later for promiscuous mode when
  `stack-a/sensors/` (Suricata/Zeek) comes online.
- Docker + Docker Compose installed on stackant.

## First-time setup

1. **Get wpDiscuz 7.0.4 as a local fallback.** The official
   `wp plugin install --version=7.0.4` doesn't reliably serve old builds.
   Place a copy at `stack-a/target/wpdiscuz-7.0.4.zip` (WordPress.org
   plugin package, fetched from a source you trust — this file is
   gitignored, not committed, so anyone cloning the repo needs to grab
   their own copy).

2. **Bring the stack up:**
   ```bash
   cd stack-a/target
   docker compose up -d db wordpress
   # wait ~15s for mysql to initialize
   docker compose up wp-cli        # runs once, provisions WP + wpDiscuz, then exits
   ```

3. **Verify:**
   - WordPress: `http://localhost:8080` — should show "Prairie Wares Co."
     Admin login at `/wp-admin`, `admin` / `Welcome2024!`.
   - wpDiscuz active and correct version:
     ```bash
     docker exec stacka-wpcli wp plugin list --allow-root
     ```
     Confirm it's specifically 7.0.4 — a newer version won't carry the CVE.

## Network layout

| Container | IP (stacka-net) | Purpose |
|---|---|---|
| stacka-wordpress | 172.28.0.10 | Vulnerable target |
| stacka-db | 172.28.0.11 | MySQL backing WordPress |
| stacka-wpcli | 172.28.0.12 | One-shot provisioning, exits after run |

These are internal Docker IPs — sanitization to `10.0.0.50` /
`203.0.113.42` happens later in `stack-a/pipeline/`, not here.

## Sanity checks before moving to the next folder

- [ ] WordPress loads and admin login works with `Welcome2024!`
- [ ] wpDiscuz version confirmed as 7.0.4, not just "a" wpDiscuz install
- [ ] `docker compose ps` stays healthy after a full `down && up -d`
