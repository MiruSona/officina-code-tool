# C# / Unity

- **흐름 배선(이벤트·참조·순서)은 코드에 둔다.** 인스펙터에서만 알 수 있는 연결을 만들지 않는다 — diff·검색·리뷰가 안 된다. 값·모양은 프리팹에 둬도 된다 (AGENTS 10)
- ScriptableObject 는 **수치 데이터 통**으로만 쓴다. 이벤트 배선 도구로 안 쓴다
- UI 글씨는 **처음부터 TMP + 프로젝트 안 폰트 자산**으로 쓴다. legacy `UI.Text`·`TextMesh` 의 기본 폰트는 OS 폰트에 기대서 **WebGL 빌드에서 글씨가 사라진다**
- Editor 스크립트의 네임스페이스는 **`<루트>.EditorTools`** 다. `<루트>.Editor` 로 쓰면 `UnityEditor.Editor` 클래스와 이름이 부딪힌다 (어셈블리 이름만 `.Editor`)
- Animator 를 코드 시계로 몰 때 : `speed = 0` → `Play(hash, 0, t)` → **`Update(0f)` 를 꼭 부른다.** 안 부르면 한 프레임 늦거나 안 바뀐다
- 클립 한 벌을 여러 종이 나눠 쓸 때 : 클립은 스프라이트를 직접 물지 않고 `[SerializeField] private int` 를 움직인다. 종마다 다른 스크립트가 그 번호로 자기 스프라이트를 고른다
- `.meta` 파일은 **대상 파일과 항상 함께** 커밋한다
- `Library/` `Temp/` `Logs/` `Build/` 는 커밋하지 않는다
- 씬(`.unity`)·프리팹(`.prefab`)은 **같은 파일을 동시에 고치지 않는다** (합치기가 지옥이다)
- Unity CLI(`unity command …`)로 일할 때 덴 자리는 **`Docs/Guide/UnityCLI함정.md`**
  — 스튜디오에서는 `CodeTool/Docs/Guide/UnityCLI함정.md`
- 근거 : Unity 프로젝트 구조 조사 문서
  — 스튜디오에서는 `CodeTool/Docs/Research/2026-08-20-Unity프로젝트구조조사.md`,
  CodeTool 저장소 단독에서는 `Docs/Research/2026-08-20-Unity프로젝트구조조사.md`
