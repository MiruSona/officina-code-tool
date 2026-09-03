# CodeTool

게임 프로젝트에 넣어 줄 **코드 구조 템플릿 · 코딩 컨벤션 · 코드 저장소(검색) 붙이기**를 다루는 툴이다.
Officina 툴킷의 한 조각이며, 이 저장소만 따로 받아도 그대로 쓸 수 있다.

**상태 : 조사 끝 · 1차·2차 설계 끝 · 코드는 아직 없다 (지금은 문서만 있는 저장소다).**

## 무엇을 정해 놓았나

- **코드 기본 구조는 7층**이다. 위 3층 `GameMaster`(static) / `GameRunner`(Mono) / `~Service`(순수 C#) 아래에
  `~Master` / `~Manager`·`~Hub` / `~Object` / `~Agent`·`~Util` 4층이 붙는다.
- **`Update` 진입점은 `GameRunner` 하나뿐**이고, MonoBehaviour 인 것은 `GameRunner` · `~Master` · `~Object` 셋뿐이다.
- **코딩 컨벤션은 SOLID + 8가지**다. 사람·Claude 용 원문과 로컬 LLM 용 100줄 요약본 두 벌로 나눠 둔다.
- **인스펙터 배선은 금지**다. AI 는 인스펙터를 못 보므로 설정과 연결은 전부 코드에 둔다.

자세한 내용과 그렇게 정한 까닭은 아래 문서에 있다.

## 폴더 지도

| 경로 | 내용 |
| --- | --- |
| `Docs/Guide/코딩컨벤션.md` | 코드 쓰는 규칙 원문 (SOLID + 8가지) |
| `Docs/Guide/코딩컨벤션-요약.md` | 위 문서의 로컬 LLM 용 요약본 (100줄 이내) |
| `Docs/Design/` | 기본 구조 1차 설계(2026-08-20) · 2차 설계(2026-09-01) |
| `Docs/Research/` | 조사 결과 — Unity 프로젝트 구조 · ECS/DOTS · 코드 컨벤션 · C# 포매터 · 저장소와 기억 MCP |
| `Docs/Todo/` | 할 일 — `코드와저장소.md`(전체) · `기본구조.md`(4층 구조 원문) |
| `.claude/skills/code-conventions/` | 코드를 쓰기 전에 읽는 체크리스트 스킬 (C#/Unity · Go · PowerShell) |

**할 일은 `Docs/Todo/코드와저장소.md` 부터 본다.**

## 스킬 쓰는 법

`.claude/skills/code-conventions/` 는 Claude Code 스킬이다. 코드를 쓰기 전 · 커밋 전 · 리뷰 전에 읽는다.

- 이 저장소를 단독으로 열면 세션을 시작할 때 바로 뜬다.
- 스튜디오 저장소에 서브모듈로 물려 있으면 **세션 시작 때는 안 뜬다.**
  `CodeTool/` 안의 파일을 한 번 읽으면 그때부터 `CodeTool:code-conventions` 로 뜬다.

## 설치할 것

없다. 문서뿐이라 받아서 읽으면 된다.

## 라이선스

MIT — `LICENSE` 를 본다.
