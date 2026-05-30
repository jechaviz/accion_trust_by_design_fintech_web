$ErrorActionPreference = 'Stop'
$url = if ($env:TRUST_DEMO_URL) { $env:TRUST_DEMO_URL } else { 'http://127.0.0.1:5178/' }
$shot = Join-Path (Split-Path -Parent $PSScriptRoot) 'automation_screenshot_ready.png'
npx playwright screenshot --wait-for-selector 'text=Gender-Disaggregated Metrics' --viewport-size=1366,900 $url $shot
if (!(Test-Path -LiteralPath $shot)) {
  throw 'Expected Playwright screenshot was not created.'
}
Write-Host "ui_smoke: ok $shot"
