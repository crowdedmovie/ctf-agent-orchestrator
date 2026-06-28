# ctf-agent-orchestrator

An AI-powered CTF solving workstation. Point it at a CTF platform or upload challenge files, and Claude Code will work through them autonomously — running tools, writing exploits, and reporting flags.

```
┌──────────┐   challenge    ┌─────────────────────┐   spawns    ┌──────────────┐
│ Web UI / │ ─────────────► │  Webapp (Starlette) │ ──────────► │ Claude / Codex│
│ Discord  │ ◄───────────── │  state · streaming  │ ◄────────── │ + full toolkit│
└──────────┘   live stream  └─────────────────────┘   events    └──────────────┘
```

## Why

Modern AI agents can solve many CTF challenges autonomously — the bottleneck is usually *environment*, not intelligence. An agent needs binutils, disassemblers, debuggers, forensics suites, network tools, and a sandbox where it can run freely. This project provisions that environment once, then exposes challenges to agents that can execute commands, read/write files, collaborate, and iterate until they find the flag.

Agents are effective out of the box, but get better with **skills** — structured, version-controlled workflows that guide how to approach each challenge type (forensics, reversing, crypto, pwn, web, …). When you catch an agent down a rabbit hole or missing an obvious technique, you encode that lesson into a skill so it doesn't repeat the mistake. The skill library compounds over time and the solve rate climbs.

---

## Quick Start (Local)

Run the webapp on your own machine — no cloud account needed.

### Prerequisites

- **Python 3.12+** — check with `python3 --version`
- **uv** — install with `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **Claude Code CLI** — install with `npm install -g @anthropic-ai/claude-code`, then `claude auth login`

### 1. Clone the repo

```bash
git clone https://github.com/NUSGreyhats/ctf-agent-orchestrator
cd ctf-agent-orchestrator
```

### 2. Install Python dependencies

```bash
uv venv ~/.ctf-solver/venv
uv pip install --python ~/.ctf-solver/venv/bin/python \
  starlette uvicorn python-multipart itsdangerous websockets httpx requests
```

### 3. Start the webapp

```bash
bash start-local.sh
```

The password is printed on startup and saved to `~/.ctf-solver/.password`. To retrieve it later:

```bash
cat ~/.ctf-solver/.password
```

Open **http://localhost:8080** in your browser and log in with that password.

> To use a different port: `PORT=9000 bash start-local.sh`

### 4. Connect your CTF platform (optional)

If your CTF runs on a supported platform (CTFd, rCTF, HTB, etc.) you can pull all challenges in one click instead of uploading them manually.

**Getting a CTFd API token:**
1. Log in to your CTFd instance
2. Click your username (top right) → **Settings** → **Access Tokens**
3. Generate a token and copy it

**Adding the connection in the webapp:**
1. Go to **Settings** → **Platforms** → **Add Platform** → select **CTFd**
2. Enter the CTFd URL and paste your API token
3. Click **Test Connection** — you should see your username confirmed
4. Click **Save**

### 5. Import challenges and solve

**From a platform:**
1. Click **Import from Platform** on the main page
2. Select your saved connection
3. Pick the challenges you want and click **Import**

**Manually:**
1. Click **+ Add Challenge**
2. Fill in the name, description, flag format, and upload any files
3. Select an agent (Claude Code recommended) and model
4. Click **Create & Solve**

Watch the agent work in real time. When it finds a flag, a banner appears — review it and click **Submit** to send it to the platform.

---

## Solving a Challenge — What to Expect

1. **Agent starts** — Claude reads the challenge description and files, then starts working
2. **Live output** — you see every tool call, thought, and result as it happens
3. **Flag detected** — a banner appears with the candidate flag
4. **You submit** — click the submit button (or enable auto-submit in Settings to do it automatically)
5. **Steer if needed** — if the agent gets stuck, type a hint in the Steer box and hit Enter
6. **Resume / Retry** — if a run fails, Resume continues the session; Retry starts fresh

> **Auto-submit** is off by default. Each unique flag candidate is only submitted once, so there's no risk of rate-limit bans from duplicate attempts. Enable it in **Settings → Auto-submit detected flags** only if you trust the flag detection.

---

## Features

**Agents & solving**
- **Claude Code and Codex**, via their native SDK/integration paths. Pick model and reasoning effort per agent.
- **Parallel mode** — add multiple agent rows to race the same challenge. Each agent gets an isolated workspace and shares validated breakthroughs through working notes and the `notify_teammates` tool.
- **Steering** — send mid-solve guidance; the agent resumes from its current session with your message.
- **Resume / Retry / Solve / Unsolve** — resume from saved session state, restart fresh, or manually override status.
- **Advisor** — a per-challenge conversational agent that reads the solvers' live transcripts, answers your questions, researches techniques/CVEs online, and can relay concise hints to the running solvers.

**Web UI**
- **Live streaming** over WebSocket — thinking blocks, tool calls, results, and text with syntax highlighting and collapsible sections; split or tabbed views for parallel runs.
- **Flag detection** — auto-detects `flag{…}`, `CTF{…}`, `HTB{…}`, `picoCTF{…}`, and custom formats. A silent `ctfgrep` preflight over challenge files surfaces candidate flags before the agent even starts.
- **Auto-submit** — detected flags can be submitted to the connected platform; a correct flag marks the challenge solved and stops sibling runs.
- **File browser** — inspect original challenge files and per-run workspaces (images, syntax-highlighted text, hex for binaries).
- **Usage & statistics** — per-agent account/usage dashboards and per-challenge token/cost/duration/turn breakdowns.
- **Export** — download a markdown report with the full activity log.

**Challenge management**
- **Single, bulk (`.zip`/`.7z`), and platform import.** Pull challenges directly from **CTFd, rCTF, Hack The Box CTF, CDDC, Cywaria/Cympire, and SAS CTF**; saved connections re-sync for new challenges, points, and solves.
- **On-demand instances** — HTB, Cywaria, and SAS CTF challenges with Docker/machine instances are started at solve time and their connection info is injected into the prompt.
- **Per-challenge / per-run skills** — set global defaults, lock challenge-level skills at creation, or change a run's skills mid-solve (symlinks refresh and the agent resumes).
- **TLS verification on by default**, with an explicit opt-out for self-signed/local events.

**Infrastructure**
- **One-command deploy** via Terraform to **Hetzner Cloud, DigitalOcean, or GCP**.
- **Swarm** — dispatch a challenge to a dedicated, disposable GCP worker VM cloned from a golden image, isolating heavy CPU/RAM/disk work from the controller. See [SWARM.md](SWARM.md).
- **WireGuard VPN** — built-in management for challenges that need network access to CTF infrastructure, with reverse routing to client-side internal CIDRs.
- **Integrated tooling** — a persistent GDB MCP server (Claude + Codex) and headless IDA Pro analysis via the `analyze-with-ida-domain-api` skill (bring your own licensed IDA).
- **Discord bot** (optional) — per-challenge threads/channels, real-time notifications, flag review, and slash commands for team coordination.

> For internals — collaboration model, filesystem layout, solve lifecycle, security model, persistence, and settings reference — see **[DESIGN.md](DESIGN.md)**.

<details>
<summary><b>Full feature list</b> (click to expand)</summary>

**Agents & models**
- Claude Code (via `claude-agent-sdk`) and Codex (via `codex app-server`, JSON-RPC over stdio)
- Per-agent model selection — Claude: Opus 4.8/4.7/4.6/4.5, Sonnet 4.6/4.5, Haiku 4.5, Fable 5 (default Opus 4.6 1M); Codex: discovered from local cache/config
- Per-agent reasoning effort — Claude low/medium/high/max; Codex discovered (default XHigh), compatibility-guarded so unsupported combos fall back instead of failing
- Per-provider session resume (Claude session id, Codex thread id) and a persistent default-agent toggle

**Solving & collaboration**
- Single and parallel solving modes; race multiple agents on one challenge, or add runs to an existing challenge (promotes single → parallel)
- Isolated per-run workspace with a symlinked `challenge_files/` view of the original files
- Working notes per agent, cross-symlinked so teammates can read them
- `notify_teammates` tool for validated breakthroughs (Claude in-process MCP tool, Codex dynamic tool), injected into teammates' sessions
- User broadcast to all running agents (web or Discord)
- Steer a running agent mid-solve; stop one run or all runs; Resume, Retry, Mark Solved, Unsolve
- Auto-stop sibling runs when one solves or submits a correct flag

**Web UI**
- Real-time WebSocket streaming of thinking, tool calls, tool results, text, and raw output
- Syntax highlighting, collapsible tool sections, copy buttons, subagent tabs, split or tabbed multi-agent layout, per-event elapsed timestamps, user prompts as chat bubbles
- Flag detection for `flag{}`/`CTF{}`/`HTB{}`/`picoCTF{}`/custom formats with neutral → correct/rejected states that persist
- Silent `ctfgrep` preflight that surfaces flag candidates before the agent starts; auto-submit detected flags to the connected platform
- File browser for original files and per-run workspaces (image/text/hex), auto-refreshing, with safe server-side path resolution
- Per-challenge statistics (input/output/cache tokens, cost, duration, API time, turns, tool calls, per-model breakdown, aggregate)
- Usage dashboards (Claude auth/plan/org + token usage + daily chart; Codex auth status; per-agent challenge totals)
- Per-challenge Advisor agent (configurable provider/model) that reads solver transcripts, answers questions, researches online, and relays hints
- Markdown export reports + bulk export index; global cross-challenge toast notifications; keyboard shortcuts; responsive collapsible sidebar; dark/light theme

**Challenges & platforms**
- Create single challenges or bulk-upload `.zip`/`.7z` archives (preview/edit metadata before import)
- Import from CTFd, rCTF, Hack The Box CTF, CDDC, Cywaria/Cympire, SAS CTF, and GPN (auto-discovered plugin registry)
- Saved platform connections with re-sync for new challenges and points/solves updates
- On-demand Docker/machine instances started at solve time (HTB, Cywaria, SAS); connection info injected into the prompt
- HTB multi-answer (`flagsInfo`) support with a `submit_answer.py` helper
- Per-challenge import size cap; TLS verification on by default with an explicit insecure-TLS opt-out

**Skills**
- Repo skills (forensics and tool-specific) plus external [ljagiello/ctf-skills](https://github.com/ljagiello/ctf-skills), compiled into the `all-skills/` catalog
- Selected skills symlinked into each run's `.claude/skills` and `.codex/skills`; Codex also receives them as structured skill inputs
- Global default skills, challenge-level skills locked at creation, per-run skill overrides applied mid-run (stop → refresh symlinks → resume)
- Upload new skills from Settings as a `.zip` bundle or a single `SKILL.md`

**Infrastructure & tooling**
- One-command Terraform deploy to Hetzner Cloud, DigitalOcean, or GCP
- Runtime-allowlist deploy sync that preserves `challenges/` and `state/` on the VM
- Swarm: dispatch a challenge to a disposable GCP worker cloned from a golden image — per-challenge pinning, start/stop/delete, idle auto-stop (default 30 min), credential sync, a Local | Swarm (auto) | Swarm:\<instance\> run-target selector, live SSH file browse, and hub-and-spoke VPN routing
- WireGuard VPN management: server control, generated Linux client config, reverse routing to client-side internal CIDRs, optional `dnsmasq` DNS forwarding, status (handshake age + transfer)
- Persistent GDB MCP server (registered for Claude and Codex); headless IDA Pro analysis via the `analyze-with-ida-domain-api` skill (bring your own licensed IDA)
- Rich preinstalled toolchain (reverse engineering, disk/memory/network/file forensics, crypto, pwn, web)
- uv-based Python installs; dependency-aware parallel provisioning (`INSTALL_SCRIPTS_PARALLEL`); end-of-setup validation

**Discord (optional)**
- Per-challenge destination as a thread or a category-matched channel
- Notifications for starts, stops, solves, flag detections, breakthroughs, and completions
- Flag-review buttons (submit / reject / mark correct / broadcast) and challenge action buttons (status, stats, tail, flags, submit, solved, stop, resume)
- Slash commands: `/broadcast` `/ctf` `/files` `/flags` `/help` `/resume` `/solved` `/stats` `/status` `/steer` `/stop` `/submit` `/tail`
- Live settings reconcile (gateway starts/stops/restarts on config change)

**Persistence & security**
- Challenge metadata, run history, detected flags, per-run JSONL logs, platform connections, and settings persisted under `state/` and `challenges/`; stale `solving` runs reset on restart
- HTTP Basic/session auth, CSRF on state-changing routes, authenticated WebSockets with Origin validation
- Browser hardening headers (CSP, `nosniff`, Referrer-Policy, X-Frame-Options, Permissions-Policy, COOP, HSTS over TLS)

</details>

---

## Supported Agents

| Agent | Models | Effort levels | Resume | Collaboration | Steering |
|-------|--------|---------------|--------|---------------|----------|
| **Claude Code** | Provider default, Fable 5, Opus 4.8/4.7/4.6/4.5, Sonnet 4.6/4.5, Haiku 4.5 (default **Opus 4.6 1M**) | Provider default, Low, Medium, High, Max (default **High**) | ✅ | `notify_teammates`, working notes | ✅ |
| **Codex** | Discovered from local Codex cache/config | Per-model; common fallback Low, Medium, High, XHigh (default **XHigh**) | ✅ | `notify_teammates`, working notes | ✅ |

Two or more agent rows on a challenge automatically create a parallel run.

---

## Cloud Deployment

For a persistent, fully-tooled solving environment, deploy to a cloud VM. The install scripts provision all CTF tooling (reverse engineering, forensics, crypto, pwn, web) automatically.

### 1. Deploy the VM

Pick a cloud provider (see [infra/README.md](infra/README.md) for provider-specific options):

```bash
cd infra/hetzner          # or infra/digitalocean or infra/gcp
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your settings

terraform init
terraform apply
```

This creates the VM, copies runtime files, runs the setup scripts, validates the environment, and starts the webapp service. Retrieve the login password with:

```bash
terraform output -raw webapp_password   # also stored on the VM at /root/.ctf-solver-password
```

### 2. Authenticate the agents

SSH in and log in to whichever agents you'll use:

```bash
ssh root@$(terraform output -raw external_ip)
claude auth login      # Claude Code
codex login            # Codex
```

### 3. Solve from the web UI

Open `https://<VM_IP>` and log in, then follow steps 4–5 from the Quick Start above.

### 4. (Optional) Discord

Enable Discord in **Settings** with a bot token and channel. The bot creates per-challenge threads/channels and supports slash commands — `/ctf`, `/status`, `/flags`, `/files`, `/broadcast`, `/submit`, `/solved`, `/resume`, `/stop`.

### Teardown

```bash
cd infra/hetzner   # or your provider
terraform destroy
```

---

## Skills

Skills are structured workflows that steer how agents approach challenge types. They come from two sources, both compiled into the runtime `all-skills/` catalog during setup:

- **This repo** (`skills/`) — forensics (disk, memory, pcap, stego/repair) and tool-specific skills (IDA, apk analysis, kernel GEF debugging, angrop ROP chains).
- **[ljagiello/ctf-skills](https://github.com/ljagiello/ctf-skills)** — category skills for pwn, web, crypto, rev, misc, osint, malware, and AI/ML.

The webapp symlinks selected skills into each run's `.claude/skills` and `.codex/skills`. You can also upload a `.zip` bundle or single `SKILL.md` from **Settings**. See [skills/README.md](skills/README.md) for the full catalog.

---

## Project Structure

```text
infra/            Terraform configs (Hetzner, DigitalOcean, GCP)
install_scripts/  Numbered provisioning scripts (tools, CLIs, deps); run.sh, lib/ helpers
webapp/           Starlette/ASGI app — challenge management + agent streaming
  agents/         Agent provider implementations (Claude, Codex) + broadcast bus
  plugins/        CTF platform integrations (CTFd, rCTF, HTB, CDDC, Cywaria, SAS)
  swarm*.py       Remote GCP worker dispatch (manager, runner, exec)
  static/         Frontend (vanilla JS, CSS)
mcps/             MCP servers (GDB debugger)
skills/           Repo-owned agent skills (forensics, tools)
start-local.sh    Local startup script (runs on port 8080, no root needed)
```

Runtime-only directories created on first run: `~/.ctf-solver/` (local) or `/root/ctf-agent-wrapper/` (cloud VM) — holds challenge files, state, and the skill catalog. These are never committed to the repo.

---

## Documentation

- **[DESIGN.md](DESIGN.md)** — architecture, collaboration model, filesystem layout, solve lifecycle, platform plugins, VPN, security, persistence, and the full settings reference.
- **[SWARM.md](SWARM.md)** — remote GCP execution design and operations.
- **[infra/README.md](infra/README.md)** — per-provider Terraform usage.
- **[skills/README.md](skills/README.md)** — skill catalog.
