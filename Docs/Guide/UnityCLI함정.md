# Unity CLI 함정

> Unity CLI(`unity command …`)는 **Unity 공식 도구(베타)라 우리가 못 고친다.** 여기는 우리가 덴 자리 모음이다.
> 명령 이름은 판마다 바뀔 수 있으니 `unity command` 목록으로 확인한다.
> 출처 : `Docs/Todo/2026-09-20-UnityCLI사용피드백.md` · `Docs/Todo/2026-09-18-ProjectMozzi설치피드백.md`
> 마지막 고침 : 2026-09-21

## 1. 조용히 성공한다

- **`eval` 은 Play 가 꺼져 있어도 성공을 돌려준다.** 상태를 바꾸기 전에 `editor_status` 로 playMode 를 확인한다.
  확인 없이 임시 오브젝트를 찍었다가 Edit 모드 씬에 그대로 남은 적이 있다.
- **`eval` 에러는 `--format json` 전체를 봐야 보인다.** `"result"` 만 grep 하면 실패가 **빈 출력**으로 나온다.

## 2. 어셈블리와 타입

- **asmdef 를 쓰면 어셈블리가 `Assembly-CSharp` 가 아니다.** `Type.GetType("…, Assembly-CSharp")` 이 안 먹는다.
  이 템플릿은 `<이름>.Runtime` 이다. 타입을 직접 쓰거나 맞는 어셈블리 이름을 준다.

## 3. 머티리얼·자산 고치기

- **TMP 외곽선은 `outlineWidth` 만으론 안 보인다.** `OUTLINE_ON` 키워드를 켜야 한다.
  `GetFloat("_OutlineWidth")` 에는 값이 멀쩡히 들어 있어 머티리얼만 보면 원인을 못 찾는다.
- **같은 이름 필드가 여러 곳에 있을 수 있다.** URP 6 의 `m_StripUnusedPostProcessingVariants` 는 세 곳(레거시 최상위 ·
  `m_URPShaderStrippingSetting` · `m_Settings` 의 SerializeReference 블록)에 있어 하나만 고치면 안 먹는다.
  `SerializedObject.GetIterator()` 로 다 잡는다.
- **자산 일괄 수정은 YAML 손편집보다 `eval_file` + `SerializedObject` 가 빠르다.** 예상 150분짜리가 실제 25분에 끝났다.

## 4. 파일을 조용히 만든다

- **`capture_game_view --save_path` 는 `Assets/` 아래만 받는다.** 폴더와 `.meta` 를 조용히 만드니 커밋 전에 지운다.

## 5. 빌드

- **`build_status` 는 `build` 명령으로 건 빌드만 본다.** `BuildPipeline.BuildPlayer` 를 `eval` 로 부르면 안 잡혀
  Editor.log 를 직접 읽어야 한다.

## 6. 조사 거리 (까닭을 못 밝힌 것)

- **`InGameHub` 의 정적 표가 `eval` 에서 비어 보인다.** Play 중인데도 `n=0` 이었다.
  `eval` 이 어느 도메인·어느 어셈블리 문맥에서 도는지 아직 모른다.
