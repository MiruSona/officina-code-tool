# CodeTool

게임 프로젝트에 넣어 줄 **코드 구조 템플릿 · 코딩 컨벤션 · 코드 저장소(검색) 붙이기**를 다루는 툴이다.
Officina 툴킷의 한 조각이며, 이 저장소만 따로 받아도 그대로 쓸 수 있다.

**상태 : 조사·설계 끝 · 복사 템플릿(`Template/` — 뼈대 `.cs` 25장 · asmdef 2장 · `Default.globalconfig`)과 `install.ps1` 있음 · Unity 안 컴파일 검증 끝 (2026-09-18 · Unity 6000.3.23f1 · 2D URP · 오류 0). Default.globalconfig 진단이 IDE 에서 먹는지와 PrefabKeysValidator 메뉴는 아직 안 봤다.**

## 무엇을 정해 놓았나

- **코드 기본 구조는 7층**이다. 위 3층 `GameMaster`(static) / `GameRunner`(Mono) / `~Service`(순수 C#) 아래에
  `~Master` / `~Manager`·`~Hub` / `~Object` / `~Agent`·`~Util` 4층이 붙는다.
- **`Update` 진입점은 `GameRunner` 하나뿐**이고, MonoBehaviour 인 것은 `GameRunner` · `~Master` · `~Object` 셋뿐이다.
- **코딩 컨벤션은 SOLID + 8가지**다. 사람·Claude 용 원문과 로컬 LLM 용 100줄 요약본 두 벌로 나눠 둔다.
- **흐름 배선은 코드에, 모양은 프리팹에** 둔다. 누가 누구를 부르는지(이벤트·참조·순서)는 diff·검색·리뷰가 되는 코드에만 적는다. 값과 모양은 프리팹에 둬도 된다 (Unity CLI 로 읽고 쓸 수 있다).

자세한 내용과 그렇게 정한 까닭은 아래 문서에 있다.

## 폴더 지도

| 경로 | 내용 |
| --- | --- |
| `Docs/Guide/코딩컨벤션.md` | 코드 쓰는 규칙 원문 (SOLID + 8가지) |
| `Docs/Guide/코딩컨벤션-요약.md` | 위 문서의 로컬 LLM 용 요약본 (100줄 이내) |
| `Docs/Guide/UnityCLI함정.md` | Unity CLI(`unity command …`)로 일하며 덴 자리 모음 |
| `Docs/Design/` | 기본 구조 1차 설계(2026-08-20) · 2차 설계(2026-09-01) |
| `Docs/Research/` | 조사 결과 — Unity 프로젝트 구조 · ECS/DOTS · 코드 컨벤션 · C# 포매터 · 저장소와 기억 MCP |
| `Docs/Todo/` | 할 일 — `코드와저장소.md`(전체) · `기본구조.md`(4층 구조 원문) |
| `Template/` | 게임 프로젝트의 `Assets/` 에 복사되는 원본 — `Default.globalconfig` · `_Project/Scripts/` 아래 뼈대 `.cs` 와 asmdef 2장 |
| `install.ps1` | 위 템플릿을 복사하고 네임스페이스 `Officina.*` 를 게임 이름으로 치환하는 스크립트 |
| `.claude/skills/code-conventions/` | 코드를 쓰기 전에 읽는 체크리스트 스킬 (C#/Unity · Go · PowerShell) |

**할 일은 `Docs/Todo/코드와저장소.md` 부터 본다.**

## 스킬 쓰는 법

`.claude/skills/code-conventions/` 는 Claude Code 스킬이다. 코드를 쓰기 전 · 커밋 전 · 리뷰 전에 읽는다.

- 이 저장소를 단독으로 열면 세션을 시작할 때 바로 뜬다.
- 스튜디오 저장소에 서브모듈로 물려 있으면 **세션 시작 때는 안 뜬다.**
  `CodeTool/` 안의 파일을 한 번 읽으면 그때부터 `CodeTool:code-conventions` 로 뜬다.

## 끼우는 법

게임 Unity 프로젝트의 `Assets/` 에 복사한다. `.meta` 는 Unity 가 만든다.

```powershell
.\install.ps1 -AssetsPath <Unity 프로젝트>\Assets -Namespace <게임이름> -DryRun   # 계획만 본다
.\install.ps1 -AssetsPath <Unity 프로젝트>\Assets -Namespace <게임이름>           # 실제 복사
```

- `.cs`·asmdef 는 이미 있으면 건너뛴다. `Default.globalconfig` 만 백업 뒤 덮는다.
- 복사 뒤 Unity 를 열어 컴파일 오류 0 을 보고, `Sample/` 을 지우고 자기 Master 를 만든다.
- 설계와 검증 항목은 `Docs/Design/2026-09-18-복사템플릿설계.md` 를 본다.
- `Sample/` 은 `.meta` 와 함께 지운다.
- UI 글씨는 TMP 로 시작한다 — 까닭은 스킬의 `csharp-unity.md`.
- Unity CLI 로 확인할 때 덴 자리는 `Docs/Guide/UnityCLI함정.md`.

## 라이선스

MIT — `LICENSE` 를 본다.
