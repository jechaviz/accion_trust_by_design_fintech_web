$ErrorActionPreference = 'Stop'
$url = if ($env:TRUST_DEMO_URL) { $env:TRUST_DEMO_URL } else { 'http://127.0.0.1:5178/' }
$root = Split-Path -Parent $PSScriptRoot
$metricsShot = Join-Path $root 'automation_screenshot_ready.png'
$judgeShot = Join-Path $root 'automation_screenshot_judge.png'
npx playwright screenshot --wait-for-selector 'text=Gender-Disaggregated Metrics' --viewport-size=1366,900 $url $metricsShot
npx playwright screenshot --wait-for-selector 'text=Competitive Judge Room' --viewport-size=1366,900 "$url#judge-check" $judgeShot
if (!(Test-Path -LiteralPath $metricsShot) -or !(Test-Path -LiteralPath $judgeShot)) {
  throw 'Expected Playwright screenshot was not created.'
}
Write-Host "ui_smoke: ok $metricsShot $judgeShot"
