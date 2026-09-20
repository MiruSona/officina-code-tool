# ProjectMozzi 사용 피드백 (2026-09-20)

게임 저장소 ProjectMozzi2 에서 코딩 컨벤션과 템플릿을 쓴 기록이다.
이날 UI 글씨를 legacy `Text` 에서 TMP 로 바꿨다 (UI 코드 13개 · View 2개 · Text 365곳).

## 막힌 것

- 없다.

## 헷갈린 것

| 무엇 | 자세히 | 제안 |
| --- | --- | --- |
| Editor 쪽 네임스페이스가 섞여 있다 | asmdef rootNamespace 와 `PrefabKeysValidator` 는 `Mozzi.EditorTools`, 게임 쪽에서 만든 `WebGlBuild` 는 `Mozzi.Editor` 다 | 템플릿이 Editor 스크립트 네임스페이스 규칙을 한 줄로 정해 준다 |

## 잘 된 것

| 무엇 | 왜 좋았나 |
| --- | --- |
| README 를 읽으면 스킬이 뜬다 | 서브에이전트가 `Tools/CodeTool/README.md` 를 읽으니 `code-conventions` 스킬이 떴다. TMP 전환 때 주변 코드 결을 맞추는 데 썼다 |
| 「흐름 배선은 코드에, 모양은 프리팹에」 구조 | Text 365개를 TMP 로 바꾸면서 코드 쪽은 타입 이름(`Text` → `TMP_Text`)과 `UiBindUtil.Find<>` 제네릭 인자만 바꾸면 됐다 |

## 바라는 것 (컨벤션에 넣을 만한 함정)

- Unity 6 에서 legacy `UI.Text` / `TextMesh` 의 내장 기본 폰트(LegacyRuntime)는 OS 폰트에 기댄다. 그래서 **WebGL 빌드에서 글씨가 통째로 사라진다.**
- 템플릿 · 컨벤션이 처음부터 **TMP + 프로젝트 안 폰트**를 쓰게 안내하면 같은 실수를 막는다. 이 게임은 09-20 에 365곳을 뒤늦게 바꿨다.
