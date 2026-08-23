# C# / Unity

- **설정과 연결은 코드에 둔다. 인스펙터에서만 알 수 있는 배선을 만들지 않는다 — AI 는 인스펙터를 못 본다** (AGENTS 10)
- ScriptableObject 는 **수치 데이터 통**으로만 쓴다. 이벤트 배선 도구로 안 쓴다
- `.meta` 파일은 **대상 파일과 항상 함께** 커밋한다
- `Library/` `Temp/` `Logs/` `Build/` 는 커밋하지 않는다
- 씬(`.unity`)·프리팹(`.prefab`)은 **같은 파일을 동시에 고치지 않는다** (합치기가 지옥이다)
- 근거 : `CodeTool/Docs/Research/2026-08-20-Unity프로젝트구조조사.md`
