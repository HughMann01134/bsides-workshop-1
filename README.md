# Workshop 1: Read The Logs
A hands-on cybersecurity workshop teaching log analysis through investigation of a simulated security incident.

**Status:** In development. Target delivery: March 2027

## What This Is
A two-hour, in-person workshop for up to 60 attendees. Students receive pre-captured log files from a compromised WordPress site (Apache logs, auth logs, Suricata alerts, Zeek logs) and investigate independently to reconstruct what happened. The workshop teaches log reading, hypothesis testing, and MITRE ATT&CK terminology through investigation and discovery.

**Audience:** Beginner to intermediate. Some Linux familiarity is assumed, but no detection engineering background required.

## Why This Project Exists
This is the first in a planned series of workshops focused on making practical security skills accessible without expensive tools, complex setups, or specialized hardware. The design draws on lessons from a previous workshop, including direct attendee feedback about where it succeeded and where it fell short.

- **Streamlined Deployment:** No VM installation, no local setup. Attendees open a browser, click a link, and get a working investigation environment.
- **Focused Curriculum:** One scenario, one set of skills, one clean learning arc. Workshop 1 covers log analysis only. Later workshops in the series will address other topics.
- **Discovery over Lecture:** Attendees investigate independently and reconstruct the attack themselves. The instructors and teaching assistants guide the attendees but don't directly provide solutions.
- **Platform-Agnostic:** Browser-based delivery means any laptop, and any OS can be used.

## Architecture
**Stack A - Log Generation Lab:** Runs in a controlled environment to produce realistic logs. Includes a vulnerable WordPress target, Suricata and Zeek sensors, MITRE Caldera as the attacker, and benign traffic simulator.

**Stack B - Workshop Delivery:** Hosted in the cloud during the workshop. Provides browser-based terminal access (ttyd) for each attendee, with nginx reverse proxy and Cloudflare Tunnel for authentication and secure delivery.

**Stack A** generates the log bundles. **Stack B** serves them to students during the workshop.

## Not In Scope For v1
To keep the workshop deliverable and the codebase manageable, the first version will deliberately exclude:

- Live attack execution by students (logs are pre-captured)
- Windows-based components (Linux-only telemetry)
- Individualized log variation (all attendees investigate the same scenario)
- Scoring or competition mechanics
- Persistent student state between sessions

These may appear in future workshops.

## Repository Layout
```
bsides-workshop-1/
├── stack-a/                    # Log generation lab
│   ├── caldera/                # Adversary profiles, custom abilities
│   ├── target/                 # Vulnerable WordPress compose
│   ├── sensors/                # Suricata, Zeek configs
│   ├── benign-traffic/         # Legitimate user simulator
│   └── pipeline/               # Capture, sanitize, bundle
├── stack-b/                    # Workshop delivery
│   ├── student-container/      # Dockerfile + content
│   ├── nginx/                  # Reverse proxy config
│   ├── cloudflare/             # Tunnel + Access config
│   └── admin/                  # TA tooling
├── bundles/                    # Versioned log bundles (gitignored, or LFS)
│   └── v0.1.0/
├── content/                    # Student/TA-facing materials
│   ├── questions.md
│   ├── cheatsheet.md
│   ├── ta-briefing.md
│   ├── answer-key.md
│   └── slides/
├── scripts/                    # One-off ops scripts
├── docs/                       # Architecture decisions, runbooks
```

## Following The Build
I'm documenting this project publicly on Substack as a series. Other workshop organizers should be able to clone the repo and run their own version.

**Read Along:** [Hugh Mann's Substack](https://hmann.substack.com)

## Status And Roadmap
### Infrastructure
- [x] Architecture decided
- [x] Repository structure
- [ ] Stack A: Vulnerable WordPress target
- [ ] Stack A: Suricata and Zeek sensors
- [ ] Stack A: Caldera adversary profile
- [ ] Stack A: Benign traffic simulator
- [ ] Stack A: Log capture and bundling pipeline
- [ ] Stack B: Student container
- [ ] Stack B: nginx reverse proxy
- [ ] Stack B: Cloudflare Tunnel deployment

### Content
- [ ] Student questions document
- [ ] Student cheat sheet
- [ ] TA briefing document
- [ ] Answer key
- [ ] Instructor slides

### Testing And Delivery
- [ ] First friendly test (August 2026)
- [ ] Second test (October 2026)
- [ ] Third test (January 2027)
- [ ] Final delivery (March 2027)

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details. Workshop content and code are free to use, adapt, and redeploy for your own workshop. Attribution appreciated but not required.
