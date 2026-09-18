# ProjectMozzi 설치 피드백 (2026-09-18)

`install.ps1 -Namespace Mozzi` 를 ProjectMozzi2 의 `ProjectMozziUnity/Assets` 에 처음 돌린 기록이다.
Unity 6000.3.23f1 · 2D URP · Pipeline 패키지(`unity command`)로 컴파일·씬·플레이를 봤다.

## 결론

- **템플릿 코드는 한 줄도 안 고쳤다.** 복사 28장 · 치환 44곳 · 잔여 0 → 컴파일 오류 0 → `Sample/` 지우고 `Game/InGameMaster` · `InGameHub` 만들고 다시 0 → 플레이에서 `GameRunner`(DontDestroyOnLoad) 가 서고 `GameMaster.IsBooted` 참.
- README 「상태」의 「Unity 안 컴파일 검증은 아직」은 이제 **끝났다** 로 고쳐도 된다. `Default.globalconfig` 가 실제로 진단을 먹는지는 **아직 안 봤다**(IDE 를 안 열었다).

## 잘 된 것

| 무엇 | 왜 좋았나 |
| --- | --- |
| `-DryRun` 계획표 | 28장이 어디 놓이는지 한 눈에 보여 안심하고 실복사를 눌렀다 |
| asmdef 이름 치환 | `Officina.Runtime.asmdef` → `Mozzi.Runtime.asmdef` 까지 파일 이름이 같이 바뀌어 손댈 것이 없었다 |
| Sample 3장 | `InGameHub` 는 네임스페이스만 바꿔 그대로 썼고, `SampleMaster` 는 빈 `CreateManagers` 로 줄여 `InGameMaster` 가 됐다. 지워도 다른 곳이 안 깨졌다 |

## 막히거나 헷갈린 것

| 무엇 | 자세히 | 제안 |
| --- | --- | --- |
| 「Unity 를 열어」라는 안내 | 에디터가 이미 열려 있으면 `unity command recompile` → `recompile_status` 로 본다. README 의 「사용자가 할 일」이 손 절차만 적고 있다 | 「Unity CLI 가 있으면 `recompile` · `recompile_status` · `get_console_logs --severity error`」한 줄을 더한다 |
| `Sample/` 지우는 법 | `.meta` 까지 같이 지우려면 파일 삭제가 아니라 `unity command delete_asset --asset … --confirm true` 가 맞다 | README 「사용자가 할 일 3」에 적는다 |
| 대상 경로 출력 | `Unity m_EditorVersion: 6000.3.23f1` 처럼 파일의 키 이름이 그대로 찍힌다 | `m_EditorVersion:` 를 떼고 판만 찍는다 |
| Master 의 등록 순서 주석 | 설계에 Manager 11개 순서가 있지만 아직 코드가 없어 주석으로만 적었다. 컨벤션 「주석 2줄」과 부딪혀 3줄이 됐다 | 「등록 순서 표 주석은 예외」인지 컨벤션에 한 줄 정한다 |

## 전제가 낡은 것

- **「AI 는 인스펙터를 못 본다」는 전제는 2026-09-18 에 사용자가 거뒀다.** Unity CLI(`get_component_properties` · `set_component_properties`)로 씬·프리팹 값을 읽고 쓸 수 있다. 이 설치에서도 카메라 값을 SampleScene 에서 읽어 Farm 씬에 그대로 맞췄다.
  README 「무엇을 정해 놓았나」 4번째 줄과 `csharp-unity.md` 첫 줄, `2026-08-20-Unity프로젝트구조조사.md` 의 근거를 「흐름 배선은 코드 · 모양은 프리팹 가능」으로 고쳐야 한다 (게임 쪽 `AGENTS.md` 10절은 이미 고쳤다).

## 안 한 것

- `Default.globalconfig` 진단이 IDE 에서 먹는지 확인 안 함.
- `PrefabKeysValidator` 메뉴를 안 눌러 봤다 (프리팹이 아직 없다).
