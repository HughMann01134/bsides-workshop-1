# BSides Malware Analysis Lab Post-Mortem

## Background and Motivation
In 2026, I had the opportunity to teach my first practical malware analysis workshop at BSides Regina. It was an exciting experience and overall a success. However, reflecting on the session highlighted a few key areas for improvement.

## Lessons Learned
The first iteration of the workshop revealed a few bottlenecks and areas for growth:
* **Information Overload:** The curriculum included too much information and tried to cover too many topics for a single session.
* **Setup Friction:** While the initial setup went smoothly, having all attendees manually install VMware Workstation Pro and provision the various virtual machines took up way too much time.
* **Manual Analysis Fatigue:** Attendees struggled a bit with manually scanning and parsing large log files.
* **Narrative Structure:** A cohesive scenario or story is needed to help ground the workshop in the real world.
* **Teaching vs. Showing:** The initial introduction could have been focused down to just the most relevant information.
* **Student Discovery:** The workshop would have benefited from more hands-on assignments for the attendees to discover concepts on their own.
* **Teaching Assistants:** Training up assistants beforehand would have helped manage and troubleshoot student issues more effectively.
* **Hardwar Required:** The workshop utilized Windows OS which required a PC computer with enough memory and CPU. A more platform agnostic solution would be better. 
## Project Goals
This repository serves as a refactored approach to the workshop, starting with the basics of scanning log files. I'm redesigning the material and infrastructure to ensure a smoother learning experience. The core focus areas are:
* **Streamlined Deployment:** Automating the lab environment setup to get attendees analyzing faster instead of fighting with installations.
* **Focused Curriculum:** Narrowing the scope to core concepts to prevent information overload.
* **Improved Tooling:** Integrating better automated processing to assist with log parsing and reduce manual fatigue.
## Initial Directory Structues

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
