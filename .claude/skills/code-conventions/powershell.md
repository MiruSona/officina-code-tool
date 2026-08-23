# PowerShell

- **PowerShell 5.1 이다.** `&&` · `||` · 삼항 · `??` · `?.` 가 **없다** → `;` 와 `if ($?) { }` 로 푼다
- 파일은 **UTF-8 BOM** 으로 쓴다 (BOM 이 없으면 5.1 이 한글을 깬다)
- 스크립트 머리에 `Set-Location $PSScriptRoot` — 어디서 부르든 같게 돈다
- 공백 있는 경로는 큰따옴표로 감싼다. 네이티브 exe 는 `& "C:\...\app.exe" 인자`
- `Set-Content`/`Add-Content` 는 `-Encoding utf8` 을 **명시**한다
- 긴 문자열은 here-string `@'...'@` — 닫는 `'@` 는 **줄 맨 앞**에 둔다
- Bash 도구를 쓸 때는 POSIX 문법으로 따로 쓴다 (섞지 않는다)
