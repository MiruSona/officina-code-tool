# Unity CLI 함정

> Unity CLI(`unity command …`)는 **Unity 공식 도구(베타)라 우리가 못 고친다.** 여기는 우리가 덴 자리 모음이다.
> 명령 이름은 판마다 바뀔 수 있으니 `unity command` 목록으로 확인한다.
> 출처 : `Docs/Todo/2026-09-20-UnityCLI사용피드백.md` · `Docs/Todo/2026-09-18-게임저장소설치피드백.md` ·
> `Docs/Todo/2026-10-03-반복03버그수정피드백.md` · `Docs/Todo/2026-10-03-화면맞춤세이브작업피드백.md` ·
> `Docs/Todo/2026-10-03-정식화면연출작업피드백.md` · `Docs/Todo/2026-10-05-화풍통일코드갈래피드백.md`
> 마지막 고침 : 2026-10-05

## 1. 조용히 성공한다

- **`eval` 은 Play 가 꺼져 있어도 성공을 돌려준다.** 상태를 바꾸기 전에 `editor_status` 로 playMode 를 확인한다.
  확인 없이 임시 오브젝트를 찍었다가 Edit 모드 씬에 그대로 남은 적이 있다.
- **`eval` 에러는 `--format json` 전체를 봐야 보인다.** `"result"` 만 grep 하면 실패가 **빈 출력**으로 나온다.
- **`recompile_status` 는 고친 것이 없으면 `completed` 가 아니라 `up_to_date` 를 준다.** 기다리는 루프가
  `completed` 만 보면 끝까지 돈다. 둘 다 끝으로 본다. (출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함)
- **콘솔에 앞 세션 오류가 남아 컴파일 에러처럼 보인다.** `console` 의 `counts.error` 에 지난 「없는 명령」 오류 한 줄이
  남아 있었다. 컴파일 뒤에는 `clear_console` 을 먼저 하고, 판정은 `groundTruth.consoleErrors` 로 한다.
  (출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함)

## 2. 명령 부르기

> 출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함

- **긴 eval 코드는 셸로 넘기지 말고 파일로 써서 `eval_file --file` 로 돌린다.** bash heredoc 에 한글·따옴표가 섞이면
  `unexpected EOF` 로 아무것도 안 돈다. PowerShell 에서 `eval --code "…"` 는 C# 의 큰따옴표·세미콜론이 깨져 한 번도 못 썼다.
  PowerShell 에서는 `eval_file` 만 쓰고, 다른 셸에서도 10줄이 넘으면 파일로 쓴다.
- **`unity command <이름> --help` 는 공통 도움말만 나온다.** 명령별 인자는 `unity command --query <이름>` 의 매개변수 열로 본다.

## 3. 어셈블리와 타입

- **asmdef 를 쓰면 어셈블리가 `Assembly-CSharp` 가 아니다.** `Type.GetType("…, Assembly-CSharp")` 이 안 먹는다.
  이 템플릿은 `<이름>.Runtime` 이다. 타입을 직접 쓰거나 맞는 어셈블리 이름을 준다.

## 4. 머티리얼·자산 고치기

- **TMP 외곽선은 `outlineWidth` 만으론 안 보인다.** `OUTLINE_ON` 키워드를 켜야 한다.
  `GetFloat("_OutlineWidth")` 에는 값이 멀쩡히 들어 있어 머티리얼만 보면 원인을 못 찾는다.
- **같은 이름 필드가 여러 곳에 있을 수 있다.** URP 6 의 `m_StripUnusedPostProcessingVariants` 는 세 곳(레거시 최상위 ·
  `m_URPShaderStrippingSetting` · `m_Settings` 의 SerializeReference 블록)에 있어 하나만 고치면 안 먹는다.
  `SerializedObject.GetIterator()` 로 다 잡는다.
- **자산 일괄 수정은 YAML 손편집보다 `eval_file` + `SerializedObject` 가 빠르다.** 예상 150분짜리가 실제 25분에 끝났다.
  코드를 넘기는 법은 2절.

## 5. 캡처와 파일

- **`capture_game_view --save_path` 는 `Assets/` 아래만 받는다.** 폴더와 `.meta` 를 조용히 만드니 커밋 전에 지운다.
- **`capture_game_view` 기본 크기는 1280×720 이다.** Game 뷰가 세로(1080×2400)여도 가로 그림이 찍혀 화면이 깨진 줄 안다.
  `--width --height` 를 꼭 넣는다. (출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함)
- **`editor_pause` 중에 찍으면 옛 프레임이 찍힌다.** 멈춘 동안 Game 뷰가 다시 안 그려진다. 연출 중간 장면은
  에디터 멈춤 대신 게임 쪽 시간(`TimeScale 0`)을 멈추고 손으로 조금씩(0.05초) 돌려 찍는다.
  (출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함)
- **캡처 한 번이 1초쯤 걸려 짧은 연출을 `sleep` 으로 못 잡는다.** 0.9초 연출을 두 장 찍었더니 같은 그림이었다.
  `eval` 로 `GameMaster.TimeScale` · `Time.timeScale` 을 0.02 로 낮추고 찍은 뒤 되돌린다.
  단, `unscaledDeltaTime` 으로 도는 연출에는 안 먹는다. (출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함)

## 6. 빌드

- **`build_status` 는 `build` 명령으로 건 빌드만 본다.** `BuildPipeline.BuildPlayer` 를 `eval` 로 부르면 안 잡혀
  Editor.log 를 직접 읽어야 한다.

## 7. 잘 되는 틀

> 덴 자리가 아니라 해 보니 된 길이다. 출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함

- **에이전트 여럿이 갈래를 나눠 동시에 고칠 때는 EditMode 시험까지만 한다.** Play 로 보는 확인은 갈래를 합친 뒤 한 번만 한다.
  에디터가 한 대라 남이 파일을 고치면 재컴파일이 끼어들어 Play 가 꺼지거나 옛 상태가 남는다.
  본 것이 누구 변경의 결과인지도 알 수 없다. 갈래마다 에디터를 따로 띄우는 길은 8절(조사 거리).
- **화면 비율 시험은 CLI 만으로 끝까지 된다.** `PlayModeWindow.SetCustomRenderingResolution` 으로 Game 뷰 크기를 바꾸고
  `capture_game_view --source screen` 으로 찍는다. 네 비율 × 여덟 화면을 사람 손 없이 봤다.
  단, 맞춤 크기가 Game 뷰 목록에 더해지기만 해서 시험 뒤에 남는다 (되돌리는 길은 8절).
- **세이브 시험은 reflection 으로 private 읽기 함수를 임시 경로에 대고 부른다.** `eval` 에서 `LoadFile` 같은 private 메서드를
  불러 세이브 파일 여덟 경우를 한 번에 돌렸다. 사용자 세이브는 안 건드린다. 파일을 만지는 코드 시험에 잘 맞는다.
- **프리팹 손질기는 `PrefabUtility.LoadPrefabContents` → 고침 → `SaveAsPrefabAsset`.** Editor 정적 클래스에 두고
  `eval` 로 한 줄에 부른다. 몇 번 돌려도 같은 결과가 되게 쓰면 자리 고치기가 빠르다.
- **끌기 시험은 `simulate_pointer` 로 안 된다.** 한 프레임짜리 누름이라 누름 → 옮김 → 뗌을 따로 불러도 탭이 된다.
  `InputSystem.QueueStateEvent(Mouse.current, new MouseState{…}.WithButton(…))` 로 마우스 상태를 한 장씩 넣어
  누름 · 옮김 · 뗌을 만든다.
- **그림 바꿔 보기는 Play 중에 PNG 를 바꾸고 `AssetDatabase.Refresh()`.** 화면 그림이 그 자리에서 바뀐다
  (C# 을 안 건드리면 도메인이 안 다시 읽힌다). `TimeScale 0` 으로 멈춰 두면 같은 순간을 그림만 바꿔 가며 견줄 수 있다.

## 8. 조사 거리 (까닭을 못 밝힌 것)

> 출처 : 게임 저장소 피드백 · 툴 쪽 실측 안 함

- **`InGameHub` 가 `eval` 에서 비어 보였다.** 옛 판에서 Play 중인데도 `n=0` 이었다.
  Unity 6000.3.23f1 · CLI 1.0.0-beta.12 에서는 Play 중 풀이름(`<게임>.Game.InGameHub.Get<…>()`)으로 부르니 됐다.
  옛 증상의 까닭은 모른다.
- **캡처를 프로젝트 밖으로 받는 길이 있나.** 지금은 `Assets/` 아래에 `.meta` 째 쌓여 `AssetDatabase.DeleteAsset` 으로 지운다.
- **`EditorApplication.Step()` 을 `eval` 로 부르면 프레임 수가 안 맞는다.** 한 `eval` 안에서 여러 번 불러도 한 프레임만 가고,
  `eval` 을 여러 번 부르면 예상보다 많이 간다. 「0.25초 지점」 같은 정확한 때를 못 골랐다.
- **Game 뷰를 Free Aspect 로 못 되돌린다.** 되돌리는 공개 API 를 못 찾았다. 못 찾으면 「시험 뒤 사람이 고른다」.
- **Device Simulator 를 CLI 로 켜서 safeArea 를 볼 수 있나.** 에디터에서는 `Screen.safeArea` 가 화면 전체라 안전 영역을 못 본다.
- **갈래마다 작업 폴더(worktree)와 에디터를 따로 띄워 Play 확인을 갈래 안에서 할 수 있나.** 아직 조사하지 않았다.
