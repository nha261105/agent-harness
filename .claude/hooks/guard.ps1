# PreToolUse guard for Bash and PowerShell calls. Compatible with Windows PowerShell 5.1.
# Exit 2 with a message on stderr blocks the call; exit 0 lets it through.
# Edits to this file are the human's (see .claude/settings.json deny rules).

try {
    $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    [Console]::Error.WriteLine('Blocked by .claude/hooks/guard.ps1: could not parse the hook input, so the guard fails closed.')
    exit 2
}
$command = $null
if ($payload -and $payload.tool_input) { $command = [string]$payload.tool_input.command }
if ([string]::IsNullOrWhiteSpace($command)) { exit 0 }

# .env as a path token: starts the token or follows / \ quote = or whitespace,
# with an optional suffix such as .local, and ends the token.
$envPattern = '(^|[\s"''/\\=])\.env(\.[\w.-]+)?(?=$|[\s"'';|&)>])'
if ($command -match $envPattern) {
    [Console]::Error.WriteLine('Blocked by .claude/hooks/guard.ps1: .env files are off limits. Do not work around this; ask the human.')
    exit 2
}

# A push not written as plain "git push ..." would slip past the ask rule.
$pushPattern = '\bgit\b(?!\s+push\b).*\bpush\b'
if ($command -match $pushPattern) {
    [Console]::Error.WriteLine('Blocked by .claude/hooks/guard.ps1: write the push as plain "git push ..." so the human gets the approval prompt.')
    exit 2
}

exit 0
