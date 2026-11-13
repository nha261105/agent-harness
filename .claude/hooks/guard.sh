#!/usr/bin/env bash
# PreToolUse guard for Bash calls. Needs bash and jq.
# Exit 2 with a message on stderr blocks the call; exit 0 lets it through.
# Edits to this file are the human's.

block() { echo "Blocked by .claude/hooks/guard.sh: $1" >&2; exit 2; }

command -v jq >/dev/null 2>&1 || block 'jq is not installed, so the guard fails closed. Ask the human to install jq.'

# jq regexes (Oniguruma) support lookahead, so both checks run in one jq call.
# .env as a path token: starts the token or follows / \ quote = or whitespace,
# with an optional suffix such as .local, and ends the token.
# A push not written as plain "git push ..." would slip past the ask rule.
program=$(cat <<'JQ'
(.tool_input.command // "") as $c
| if ($c | test("(^|[\\s\"'/\\\\=])\\.env(\\.[\\w.-]+)?(?=$|[\\s\"';|&)>])")) then "env"
  elif ($c | test("\\bgit\\b(?!\\s+push\\b).*\\bpush\\b")) then "push"
  else "ok" end
JQ
)

verdict=$(jq -r "$program" 2>/dev/null) || block 'could not parse the hook input, so the guard fails closed.'

case "$verdict" in
  ok) exit 0 ;;
  env) block '.env files are off limits. Do not work around this; ask the human.' ;;
  push) block 'write the push as plain "git push ..." so the human gets the approval prompt.' ;;
  *) block 'unexpected guard result, so the guard fails closed.' ;;
esac
