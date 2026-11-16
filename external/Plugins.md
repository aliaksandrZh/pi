pi install npm:pi-web-access

# .NET skills (dotnet/skills) in Pi

## Source and management tool

```bash
git clone https://github.com/dotnet/skills.git ~/Programming/pi/skills
```

Installed manager — `~/.pi/pi-skills.sh`:

```bash
./pi-skills.sh list              # enabled (✅) / available skills
./pi-skills.sh add <name...>     # single skill (binlog-generation) or whole plugin (dotnet11:*)
./pi-skills.sh remove <name...>  # disable
./pi-skills.sh update            # git pull + "/reload" in Pi
./pi-skills.sh mcp               # add the binlog MCP server
./pi-skills.sh mcp-remove        # remove the binlog MCP server
```

## Skills

Entries in `~/.pi/agent/settings.json` → `"skills"`:

```json
  "~/Programming/pi/skills/plugins/dotnet/skills/msbuild",
  "~/Programming/pi/skills/plugins/dotnet/skills/setup-local-sdk",
  "~/Programming/pi/skills/plugins/dotnet-diag/skills/dotnet-trace-collect",
  "~/Programming/pi/skills/plugins/dotnet-diag/skills/dump-collect",
  "~/Programming/pi/skills/plugins/dotnet-diag/skills/microbenchmarking",
  "~/Programming/pi/skills/plugins/dotnet-data/skills/optimizing-ef-core-queries",
  "~/Programming/pi/skills/plugins/dotnet-msbuild/skills/binlog-generation",
  "~/Programming/pi/skills/plugins/dotnet-msbuild/skills/binlog-failure-analysis"
```

## binlog MCP

Entry in `~/.pi/agent/mcp.json` (added by `./pi-skills.sh mcp`):

```json
"binlog": {
  "command": "dotnet",
  "args": ["dnx", "Microsoft.AITools.BinlogMcp", "--yes", "--prerelease"]
}
```

## Add as needed

```bash
./pi-skills.sh add dotnet11:*                                    # writing on .NET 11 (Process/STJ APIs)
./pi-skills.sh add run-tests platform-detection filter-syntax     # tests (VSTest/MTP)
./pi-skills.sh add analyzing-dotnet-performance                   # perf anti-pattern scan
```

After every skills change: run `/reload` in Pi or restart it.
