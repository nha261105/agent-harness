#!/usr/bin/env bash
# Tests for guard.sh. Run: bash .claude/hooks/guard.test.sh
# Each case feeds one Bash command to the guard and checks the exit code:
# 0 = let through, 2 = blocked.

guard="$(dirname "$0")/guard.sh"
fail=0

check() { # <expected exit code> <command>
  local input got
  input=$(jq -cn --arg c "$2" '{tool_input: {command: $c}}')
  echo "$input" | bash "$guard" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$1" ]; then
    echo "ok    $1  $2"
  else
    echo "FAIL  want $1, got $got:  $2"
    fail=1
  fi
}

# Ordinary commands pass.
check 0 'ls -la'
check 0 'npm test'
check 0 'grep -rn "environment" src'
check 0 'cat src/env.ts'
check 0 'git status && git log --oneline -5'

# Secret .env files are blocked, wherever the path appears.
check 2 'cat .env'
check 2 'cat ./.env'
check 2 'cat config/.env.local'
check 2 'source .env.production'
check 2 'cp .env.staging /tmp/x'
check 2 'grep KEY .env; echo done'
check 2 'FILE=.env node load.js'
check 2 'cat .env.example.local'

# Templates without secrets pass.
check 0 'cat .env.example'
check 0 'diff .env.sample .env.template'

# A push written with options before "push" would skip the ask rule, so it is blocked.
check 2 'git -C ../app push'
check 2 'git --no-pager push origin main'
# A plain push is left to the ask rule.
check 0 'git push origin feat/x'

exit "$fail"
