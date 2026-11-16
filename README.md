# Pi agent configuration

Personal configuration for the [Pi coding agent](https://pi.dev): user-level settings, MCP servers, model definitions, and helper scripts.

## Layout

| Path | Purpose |
|---|---|
| `agent/settings.json` | user settings — provider/model, skills, packages |
| `agent/mcp.json` | MCP servers (currently `binlog` for MSBuild binary logs) |
| `agent/models.json` | model definitions (local Ollama) |
| `agent/auth.json`, `agent/models-store.json` | runtime-managed by Pi — ignored, never commit |
| `external/pi-skills.sh` | manages skills from [dotnet/skills](https://github.com/dotnet/skills) |
| `external/Plugins.md` | install/setup notes |

## Skills

Skills are installed individually from the Microsoft [dotnet/skills](https://github.com/dotnet/skills) collection (cloned to `~/Programming/pi/skills`):

```bash
~/.pi/external/pi-skills.sh list              # enabled / available
~/.pi/external/pi-skills.sh add <name...>     # enable a skill or a whole plugin (name:*)
```

After any skills change, run `/reload` in Pi. See `external/Plugins.md` for the full guide.
