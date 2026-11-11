# OpenCode Provider Integration — Roadmap

## Project Goal

Extend CTF Agent Orchestrator with OpenCode as a third agent runtime alongside Claude Code and Codex.

The integration must preserve all existing functionality, remain backward-compatible, and allow OpenCode to use external inference providers such as DeepSeek.

## Core Principles

- **Non-breaking:** Claude Code and Codex must continue working unchanged.
- **Additive:** OpenCode is an optional provider, not a replacement.
- **Native integration:** Prefer OpenCode's supported API/server or SDK interfaces over fragile terminal-output parsing.
- **Provider-agnostic:** Model selection and configuration should support multiple inference backends.
- **Feature parity:** Existing orchestration features should remain available. Provider-specific capabilities must be explicitly identified and adapted where possible.
- **Security:** Protect API keys, maintain existing file-access protections, and preserve process isolation.

## Required Functionalities

- Agent creation, start, stop, retry and resume
- Persistent session management
- Real-time output streaming
- Shell commands and filesystem tools
- Per-run workspace isolation
- CTF skills and MCP servers
- Parallel execution and working notes
- `notify_teammates` collaboration
- User broadcasts and mid-run steering
- Flag detection and automatic submission
- Advisor integration with custom tools
- Usage statistics and model costs
- Discord integration
- Local and GCP Swarm execution

## Implementation Phases

### Phase 0 — Research and Compatibility Audit

- [ ] Inspect OpenCode CLI, server API and SDK
- [ ] Verify session creation, continuation and interruption
- [ ] Identify streaming event formats
- [ ] Investigate custom tools and MCP support
- [ ] Verify dynamic steering and teammate messages
- [ ] Review previous OpenCode implementation in upstream Git history
- [ ] Document any unsupported features

### Phase 1 — Provider Adapter

- [ ] Create `webapp/agents/opencode.py`
- [ ] Register OpenCode in `webapp/agents/__init__.py`
- [ ] Implement the existing `AgentProvider` contract
- [ ] Implement session persistence
- [ ] Normalize tool, text, reasoning and result events
- [ ] Handle failures, cancellation and process cleanup

### Phase 2 — Multi-Model Configuration

- [ ] Configure DeepSeek as the first inference backend
- [ ] Add model selection through the existing UI
- [ ] Support additional OpenCode-compatible providers
- [ ] Add secure per-provider API-key configuration
- [ ] Support provider-specific model options
- [ ] Report token usage and costs accurately

### Phase 3 — Full Framework Integration

- [ ] Integrate skills and MCP tools
- [ ] Integrate teammate collaboration
- [ ] Implement steering and broadcasts
- [ ] Support Advisor custom tools
- [ ] Preserve flag detection and submission
- [ ] Support GCP Swarm workers
- [ ] Validate installation and authentication workflows

### Phase 4 — Testing and Stabilization

- [ ] Add mocked provider contract tests
- [ ] Test live streaming and filesystem operations
- [ ] Test stop, retry, resume and steering
- [ ] Test mixed Claude / Codex / OpenCode parallel runs
- [ ] Test skills changes during execution
- [ ] Test local and Swarm execution
- [ ] Compare statistics with real API usage
- [ ] Run regression tests for existing providers

## Definition of Done

The integration is complete when OpenCode can autonomously solve supported CTF challenges, communicate with other agents, resume sessions, use CTF tooling and integrate with the existing UI.

No existing Claude Code or Codex workflow may regress.

Any capability that cannot be reproduced identically must be documented and covered by an explicit compatibility decision.

## Out of Scope

- Rewriting the main orchestrator
- Replacing Claude Code or Codex
- Redesigning the frontend
- Reimplementing CTF platform integrations
- Changing the global challenge storage format without necessity

## Initial Deliverable

A working OpenCode provider using DeepSeek, with normalized streaming, tool execution, session resume and backward compatibility. Advanced collaboration and Swarm parity follow in subsequent milestones.