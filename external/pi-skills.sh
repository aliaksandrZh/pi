#!/usr/bin/env bash
# Manage skills from microsoft/dotnet/skills in Pi.
# Usage:
#   pi-skills.sh list               — show available skills and which are enabled
#   pi-skills.sh add <name...>      — enable a skill by name (optimizing-ef-core-queries)
#                                     or a whole plugin: dotnet11:*
#   pi-skills.sh remove <name...>   — disable skills/plugins
#   pi-skills.sh update             — git pull the skills repository
#   pi-skills.sh mcp                — add the binlog MCP server (on demand)
#   pi-skills.sh mcp-remove         — remove the binlog MCP server
# After add/remove: restart pi or run /reload.

set -euo pipefail

REPO="${PI_SKILLS_REPO:-$HOME/Programming/pi/skills}"
export PI_SETTINGS="${PI_SETTINGS:-$HOME/.pi/agent/settings.json}"
SKILLS_ROOT="$REPO/plugins"

# --- helpers ---------------------------------------------------------------

skills_in_settings() {
  python3 -c '
import json, os
s = json.load(open(os.path.expanduser(os.environ["PI_SETTINGS"])))
[print(x) for x in s.get("skills", [])]'
}

available_skills() {
  for d in "$SKILLS_ROOT"/*/skills/*; do
    [ -f "$d/SKILL.md" ] && printf '%s\n' "${d#$SKILLS_ROOT/}"
  done
}

resolve_to_dirs() {
  # input: skill name | plugin_name:* (whole plugin)
  local entries=()
  for req in "$@"; do
    if [[ "$req" == *":*" ]]; then
      local plug="${req%%:*}"
      local dir="$SKILLS_ROOT/$plug"
      if [ ! -d "$dir/skills" ]; then echo "Plugin not found: $plug" >&2; exit 1; fi
      for d in "$dir"/skills/*; do entries+=("$d"); done
    else
      local found=0
      for d in "$SKILLS_ROOT"/*/skills/"$req"; do
        if [ -f "$d/SKILL.md" ]; then entries+=("$d"); found=1; fi
      done
      if [ "$found" != 1 ]; then echo "Skill not found: $req" >&2; exit 1; fi
    fi
  done
  printf '%s\n' "${entries[@]}"
}

# --- commands --------------------------------------------------------------

case "${1:-list}" in
  list|"")
    echo "== Enabled (settings.json, from dotnet/skills):"
    skills_in_settings | grep 'pi/skills/' || echo "  (empty)"
    echo
    echo "== Available in $SKILLS_ROOT:"
    settings_real=$(skills_in_settings | while read -r e; do echo "${e/#\~/$HOME}"; done)
    while read -r rel; do
      [ -z "$rel" ] && continue
      if printf '%s\n' "$settings_real" | grep -qx "$SKILLS_ROOT/$rel"; then mark="✅"; else mark="  "; fi
      printf '%s %s\n' "$mark" "$rel"
    done < <(available_skills)
    ;;

  add)
    shift
    resolve_to_dirs "$@" | python3 -c '
import json, os, sys
home = os.path.expanduser("~")
settings = os.path.expanduser(os.environ["PI_SETTINGS"])
s = json.load(open(settings))
skills = s.setdefault("skills", [])
added = []
for p in sys.stdin.read().splitlines():
    if not p:
        continue
    rel = ("~/" + os.path.relpath(p, home)) if p.startswith(home + os.sep) else p
    if rel not in skills:
        skills.append(rel)
        added.append(rel)
json.dump(s, open(settings, "w"), indent=2)
[print("added:", a) for a in added or ["(nothing — already enabled)"]]
'
    echo "Done. Restart pi or run /reload."
    ;;

  remove)
    shift
    resolve_to_dirs "$@" | python3 -c '
import json, os, sys
settings = os.path.expanduser(os.environ["PI_SETTINGS"])
s = json.load(open(settings))
bad = {os.path.realpath(os.path.expanduser(p)) for p in sys.stdin.read().splitlines() if p}
kept = [x for x in s.get("skills", []) if os.path.realpath(os.path.expanduser(x)) not in bad]
s["skills"] = kept
json.dump(s, open(settings, "w"), indent=2)
print("removed:", len(bad) - (len(s.get("skills", [])) - len(kept)), "entries; kept total:", len(kept))
'
    echo "Done. Restart pi or run /reload."
    ;;

  update)
    git -C "$REPO" pull --ff-only && echo "Repository updated. Run /reload in pi."
    ;;

  mcp)
    pi mcp add binlog -- dotnet dnx Microsoft.AITools.BinlogMcp --yes --prerelease
    echo "binlog MCP added (user-level)."
    ;;

  mcp-remove)
    pi mcp remove binlog
    ;;

  *)
    head -12 "$0" >&2
    exit 1
    ;;
esac
