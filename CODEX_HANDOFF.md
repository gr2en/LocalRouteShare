# Codex Handoff

이 문서는 노트북 교체 후 같은 프로젝트를 Codex에서 자연스럽게 이어가기 위한 인수인계 메모입니다.

## 프로젝트

- 작업 폴더: `/Users/gr2nshoes/Documents/건설관리TP`
- Xcode 프로젝트: `LocalRouteShare.xcodeproj`
- 앱 소스 폴더: `LocalRouteShare/`
- 앱 표시명: `Local Routes`
- 플랫폼: SwiftUI iOS 앱
- Deployment target: iOS 16.0
- 외부 라이브러리: 없음
- Firebase: 아직 연결하지 않음

## 지금까지 구현한 것

사용자 경험 기반 지도/경로 공유 앱 MVP를 구현했습니다.

- 하단 탭 4개: 홈, 지름길, 노선투표, 내정보
- 더미데이터 기반 홈 화면
- 지름길 목록, 저장/좋아요 토글
- 노선 제안/투표 목록, 투표 상태 변경
- 지름길 등록 시트
- 노선 제안 등록 시트
- 마이페이지, 활동 통계, 배지 더미데이터

추가로 “실외 GPS 기반 경로 기록 기능”을 지름길 등록 플로우 안에 구현했습니다.

- `AddShortcutView`에서 출발지/도착지/설명/태그 입력
- “기록 시작하기”로 `RecordingMapView` fullScreenCover 진입
- `CLLocationManager` 기반 foreground 위치 기록
- GPS horizontalAccuracy가 25m보다 나쁘면 좌표 저장 제외
- 마지막 저장 좌표와 5m 이상 떨어진 경우에만 새 좌표 저장
- `MKMapView` + `MKPolyline`로 iOS 16에서도 지도 위 경로선 표시
- 현재 위치 마커 표시
- 사진 추가 시 현재 위치에 `RoutePhotoMarker` 저장
- 사진 마커를 지도 위 카메라 마커로 표시
- 기록 종료 후 `AddShortcutView`에 이동 거리, 기록 시간, 사진 개수, 지도 미리보기 반영
- 완료 시 `Shortcut`에 routePoints, photoMarkers, recordedDistance, recordedDuration 저장
- 홈/지름길 목록의 카드에서 “상세 지도 보기”로 진입하는 `ShortcutDetailView` 추가
- 상세 화면에서 기록 지도, 출발/도착 정보, 기록 요약, 사진 마커, 저장 토글 표시
- 샘플 지름길 데이터에 데모용 routePoints/photoMarkers/recordedDistance/recordedDuration 추가
- Figma 영어 UI 작업에 맞춰 SwiftUI 앱의 탭, 버튼, 화면 카피, 샘플 데이터, 권한 문구를 영어로 변경
- Profile 탭의 활동 지표, Shared Shortcuts, Badge 카드를 클릭 가능하게 개선
- Profile의 Shared Shortcuts/Saves & Likes에서 작성한 shortcut을 `ShortcutDetailView`로 연결
- Profile에서 내가 작성한 shortcut을 편집/삭제할 수 있도록 `EditShortcutView`, row 메뉴, 상세 화면 관리 메뉴 추가
- Profile 헤더의 Local Score 클릭 시 Reward History 화면으로 이동하도록 구현
- Reward History에 레벨 진행률, 점수 획득 내역, 주간 미션, 점수 규칙 표시
- Home 상단을 캐릭터/말풍선/Local Score/Routes-Votes-Likes 요약이 있는 헤더로 변경
- Home 섹션 제목을 `Best Shortcuts This Week`, `Trending Route Requests`로 변경하고 캐릭터 이미지를 `Assets.xcassets`에 추가
- My Page를 캐릭터 프로필 헤더, `My Activity`, `My Saved Routes`, `Achievements` 구성으로 변경
- My Page 항목 제목을 `Saves`, `Routes Shared`, `Routes Voted`로 맞추고, 저장 route/achievement 샘플 데이터도 레퍼런스에 맞춰 조정
- Home 캐릭터 이미지를 새 레퍼런스 이미지로 교체하고, 말풍선 `Top 5% contributor!`가 잘리지 않도록 고정 레이아웃으로 수정
- Home `Best Shortcuts This Week` 아이콘을 초록 위치 핀으로 바꾸고, 목록을 `Muak Dorm → Eng. Hall` 컴팩트 카드 스타일로 변경
- `RouteMascot` 이미지를 흰 배경 제거/자동 crop한 투명 PNG로 교체해 캐릭터 누끼처럼 보이도록 수정
- Figma `페이지 완성` 전체 스크린샷을 기준으로 Home 헤더/카드 밀도, 하단 탭 라벨(`Vote`, `My`), `My Routes` 탭, `Register My Route`, `Route Detail`, `Route Requests & Voting`, `Route Request Detail`, `Suggest a New Route` 화면 구조와 주요 기능 캡션을 SwiftUI에 반영
- Home의 중복 Local Score 카드를 제거하고, `Trending Route Requests`를 Figma의 78px 컴팩트 카드 형태로 변경
- `My Routes` 카드에 Share/Save/Report 메뉴와 `Start` 상세 진입을 추가하고, Route Vote 카드에서 상세 화면 진입과 투표 기능을 함께 제공
- `Suggest a New Route`에 Expected Benefits 체크 항목을 추가해 제출 데이터에 함께 저장하도록 구현
- Figma `기능` 페이지의 `스마트 경로` 캡션을 Home 검색 제출 플로우에 연결해 `Smart Route` 추천 화면으로 구현
- QA를 위해 `-initialTab shortcuts|vote|my` launch argument로 특정 탭을 바로 열 수 있도록 `MainTabView`에 안전한 초기 탭 선택 로직 추가

이번 MVP에서 의도적으로 제외한 것:

- 백그라운드 위치 기록
- Firebase 저장
- Firebase Storage 사진 업로드
- 실내 위치 보정
- 노선 제안/투표 기능의 GPS 기록 적용

## 핵심 파일

- `LocalRouteShare/Models/Shortcut.swift`
- `LocalRouteShare/Models/RoutePoint.swift`
- `LocalRouteShare/Models/RoutePhotoMarker.swift`
- `LocalRouteShare/Models/RouteRecordingResult.swift`
- `LocalRouteShare/ViewModels/AppViewModel.swift`
- `LocalRouteShare/ViewModels/RouteRecordingManager.swift`
- `LocalRouteShare/Views/AddShortcutView.swift`
- `LocalRouteShare/Views/RecordingMapView.swift`
- `LocalRouteShare/Views/ShortcutDetailView.swift`
- `LocalRouteShare/Components/RouteMapView.swift`
- `LocalRouteShare/Components/ImagePicker.swift`
- `LocalRouteShare.xcodeproj/project.pbxproj`

## 권한 설정

`LocalRouteShare.xcodeproj/project.pbxproj`의 generated Info.plist 설정에 다음 권한 문구를 추가했습니다.

- `NSLocationWhenInUseUsageDescription`: 경로를 기록하기 위해 현재 위치 접근이 필요합니다.
- `NSCameraUsageDescription`: 경로 중 사진을 기록하기 위해 카메라 접근이 필요합니다.
- `NSPhotoLibraryUsageDescription`: 경로 사진을 선택하기 위해 사진 보관함 접근이 필요합니다.

## 검증한 빌드 명령

```bash
xcodebuild -project LocalRouteShare.xcodeproj -scheme LocalRouteShare -configuration Debug -sdk iphonesimulator -derivedDataPath /private/tmp/LocalRouteShareDerivedData CODE_SIGNING_ALLOWED=NO build
```

마지막 확인 결과는 `BUILD SUCCEEDED`였습니다.

샌드박스 환경에서는 CoreSimulatorService 관련 경고가 뜰 수 있지만, SwiftUI 앱 빌드는 성공했습니다.

2026-06-02 이어받기 작업 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-02 영어 UI 문구 반영 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-02 Profile 클릭 UX 개선 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-02 My Shortcut 편집/삭제 기능 추가 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-02 Reward History 화면 추가 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-06 Home 캐릭터 헤더/메인 제목 변경 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-06 My Page 구성/항목 제목 변경 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Home 캐릭터/말풍선/Best Shortcuts 컴팩트 카드 재수정 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 RouteMascot 누끼 PNG 처리 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Figma `페이지 완성` 화면 묶음(Home/My Routes/Register/Route Detail/Vote Detail/Suggest Route) 1차 반영 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Smart Route 기능 캡션 반영 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 RouteMascot 투명 누끼 표시 보정(`renderingMode(.original)`, 고품질 보간, antialias)과 Local Score 콤마 표기 보정 후에도 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 My Routes 필터 칩 표시 문구와 기존 샘플 태그가 어긋나 목록이 비는 문제를 막기 위해 내부 태그 alias 매칭을 추가했고, 위 명령으로 다시 확인했으며 `BUILD SUCCEEDED`였습니다.

2026-06-07 네이티브 TabView 탭바를 숨기고 Figma에 가까운 둥근 커스텀 하단 탭바(`AppBottomTabBar`)를 `safeAreaInset`으로 연결했으며, Home의 `Trending Route Requests` 카드가 `Route Request Detail`로 진입하도록 수정했습니다. 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Figma `기능` 페이지의 `트렌딩 노선` 캡션을 다시 확인하고, Vote 탭에 orange/pink gradient 요약 헤더(`Trending Routes`, 127 Proposed / 8 Approved / 3.2k Participants)와 랭킹형 `RouteProposalCard` 표시, gradient vote CTA를 추가했습니다. 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Home 상단 `#Dorm`, `#Indoor` 칩이 실제 Shortcut 목록을 필터링하도록 연결하고, `+` 칩은 `Register My Route` 시트로 진입하게 수정했습니다. `Suggest a New Route`의 Expected Benefits는 `RouteProposal.expectedBenefits` 모델 필드로 분리 저장하고 상세 화면에서 제안별 목록을 표시하도록 보강했습니다. 경로 제목/공유 문구의 화살표를 Figma 스타일의 `→`로 통일했으며, 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Figma `페이지 완성` 전체 스크린샷을 다시 받아 실제 시뮬레이터(iPhone 17 Pro)에서 Home/Shortcuts/Vote/My 탭을 캡처 QA했습니다. Vote 탭은 `페이지 완성`의 `Route Requests & Voting` 화면에 맞춰 orange/pink 기능용 hero를 제거하고, 제목/설명/보라색 `Suggest a New Route` CTA/`Most Popular` 필터/보라색 Vote 버튼 구조로 되돌렸습니다. 하단 탭바는 둥근 플로팅 바가 아니라 Figma처럼 평평한 흰색 탭바에 가깝게 수정했습니다. Home shortcut card와 My Page 헤더는 실제 캡처 기준으로 과하게 커 보이던 비율을 줄였고, `Route Detail`, `Start Record`, `View Route` 같은 Figma 문구 차이를 보정했습니다. 위 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 `RouteMascot` 에셋을 체크보드 기준으로 다시 확인해 바깥 배경이 투명한 누끼 PNG 상태임을 검증했고, 투명 여백을 더 타이트하게 줄인 `292 x 327` RGBA PNG로 교체했습니다. 권한을 올려 위 빌드 명령을 다시 실행했고 `BUILD SUCCEEDED`였습니다.

2026-06-07 Figma `페이지 완성`의 상세/등록/제안 흐름에 더 맞도록 추가 보정했습니다. `Register My Route`와 `Suggest a New Route`는 시트 대신 탭바가 유지되는 네비게이션 화면으로 열리도록 바꿨고, `Route Detail`에서는 사진 마커 기능 섹션을 `Start Route` CTA 뒤로 내려 Figma의 주요 흐름(`How Was This Route?` → `Start Route`)을 먼저 보이게 했습니다. `Route Requests & Voting` 카드의 메타 정보는 Figma처럼 `15-minute walk | supporters` 형태로 정리했고, `Route Request Detail`의 지도 미리보기는 단순 그라데이션 대신 도로/경유지/경로선이 보이는 지도 카드 느낌으로 보강했습니다. `rg` 검색으로 `Route Details`, `Start Recording`, `Trending Routes`, `Community-built`, 한글 UI 문구 잔여는 잡히지 않았습니다. 단, 이 추가 수정분은 Codex 사용량 제한으로 권한 상승 `xcodebuild`가 거절되어 아직 실제 빌드 검증은 못 했습니다. 제한이 풀리면 위 빌드 명령을 다시 실행해야 합니다.

2026-06-08 Shortcuts 탭의 각 route card 하단 하트/숫자를 실제 버튼으로 연결했습니다. 하트를 누르면 `isSaved`가 토글되어 `heart.fill`/`heart`와 주황/회색 상태가 바뀌고, `saveCount`도 `+1/-1`로 함께 변경됩니다. `AppViewModel.toggleSaveShortcut`은 수정된 `Shortcut` 값을 배열에 다시 대입하도록 바꿔 SwiftUI 갱신이 확실하게 일어나게 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다. iPhone 17 Pro 시뮬레이터에 설치 후 `-initialTab shortcuts`로 실행해 `/private/tmp/localroutes-shortcuts-heart-toggle.png` 캡처로 하트/숫자/Start 버튼 레이아웃을 확인했습니다.

2026-06-08 `Route Detail` 상단 메타 줄의 기존 `bookmark + count` 표시를 `heart` 좋아요 버튼으로 교체했습니다. 이 버튼도 `AppViewModel.toggleSaveShortcut(shortcutID:)`를 사용하므로 선택 시 `heart.fill` + 주황색 + `saveCount +1`, 해제 시 빈 하트 + 회색 + `saveCount -1`로 바뀌며 Shortcuts 리스트와 같은 상태를 공유합니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Home 헤더 퀄리티 보정 작업을 했습니다. `RouteMascot`에 `route-mascot@2x.png`(584x654)와 `route-mascot@3x.png`(876x981)를 추가하고 asset catalog에 연결해 iPhone 3x 렌더링에서 캐릭터가 덜 흐리게 보이도록 했습니다. Home 말풍선은 더 크게 키우고 글자를 rounded/heavy 스타일로 조정해 `Top 5% contributor!`가 잘리지 않게 했으며, `My Local Score`와 점수는 기존보다 왼쪽으로 이동했습니다. Home의 `+` 버튼은 더 이상 `Register My Route`로 이동하지 않고, 같은 줄에 `#` 입력 칩을 띄워 사용자가 바로 새 해시태그를 입력할 수 있게 변경했습니다. 입력 후 return 또는 `+` 재탭으로 새 태그가 추가됩니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다. iPhone 17 Pro 시뮬레이터 홈 캡처는 `/private/tmp/localroutes-home-header-tag.png`입니다.

2026-06-08 Home 태그 row 추가 보정을 했습니다. `+`로 태그를 추가해도 첫 번째 `#Dorm` 칩이 잘리지 않도록 Home 전용 horizontal ScrollView의 이중 좌측 패딩을 제거했고, 새 태그 저장 후 첫 태그 id로 스크롤을 복귀시키도록 했습니다. `ScrollView(.horizontal)`은 유지해 태그가 많아지면 좌우 스크롤이 가능합니다. iOS 16.0에서 빌드가 깨지던 `scrollBounceBehavior` 사용은 제거했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다. iPhone 17 Pro 시뮬레이터 홈 캡처는 `/private/tmp/localroutes-home-tag-scroll-final.png`입니다.

2026-06-08 `Register My Route` 화면의 수동 입력 전환을 추가했습니다. 기본 상태에서는 `Ready to record` 카드가 보이고, 카드 하단의 `Enter Manually` 버튼을 누르면 같은 위치가 `Route Description` 입력칸으로 바뀝니다. 기존처럼 `Route Description`이 항상 아래에 중복 표시되던 구조는 제거했습니다. 등록 유효성은 사진 기록이 있거나 설명이 입력된 경우 통과하도록 조정했고, 사진 기록만 있는 경우에는 기본 설명 문구를 저장하도록 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Figma `페이지 완성` 페이지 캡처(`/private/tmp/figma-page-complete.png`)와 비교해 Home 화면을 다시 보정했습니다. Home의 상단 흰 safe-area 여백을 제거해 그라데이션 헤더가 화면 최상단까지 깔리도록 했고, 헤더 높이/검색창/태그 위치를 더 컴팩트하게 조정했습니다. `Best Shortcuts This Week`와 `Trending Route Requests` 섹션의 제목, shortcut 카드, route request 카드의 폰트/높이/간격도 줄여 Figma처럼 한 화면에 더 많은 카드가 보이게 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다. iPhone 17 Pro 최종 Home 캡처는 `/private/tmp/localroutes-home-figma-final.png`입니다.

2026-06-08 `Register My Route`의 `Enter Manually` 흐름에서 다시 사진 기록 카드로 돌아갈 수 있도록 `Back to Record` 버튼을 추가했습니다. 또한 route를 저장했는데 목록에서 안 뜨는 것처럼 보이던 문제를 보정했습니다. `My Routes` 카드가 기존 샘플 제목/작성자/설명/태그를 하드코딩해서 보여주던 부분을 실제 저장된 `Shortcut`의 title, author, routeDescription, tags로 표시하도록 바꿨고, shortcut 개수가 바뀌면 Shortcuts 탭의 검색어와 필터를 초기화해 새로 저장한 route가 필터 때문에 숨지 않게 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Shortcuts 탭에서 `Best Shortcuts This Week`가 실제로 전체 목록을 보여주던 문제를 분리했습니다. `All / Best` 전환 컨트롤을 추가했고, 기본 `All Shortcuts`는 `viewModel.shortcuts` 배열 순서 그대로 표시해 새로 올라온 route가 최신순 맨 위에 보입니다. `Best Shortcuts This Week`는 같은 검색/태그 조건 안에서 `saveCount` 높은 순으로 정렬하고, 동률이면 rating, ratingCount 순으로 정렬합니다. route 개수가 바뀌면 검색어/태그/목록 모드를 `All`로 초기화해 새 저장 route를 바로 확인할 수 있게 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Home 화면에서 Dynamic Island와 헤더 콘텐츠가 가까워 보이는 문제를 줄이기 위해 Home 헤더 내부 요소만 16pt 아래로 내렸습니다. 그라데이션 배경은 계속 화면 최상단까지 깔리고, 캐릭터/말풍선/Local Score/통계/Search/태그 row만 함께 내려가도록 `headerContentOffset`을 추가했습니다. 헤더 높이는 294에서 310으로 늘려 아래 여백이 유지되게 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 `Route Detail > Full Route`의 중간 경유지가 `Central Library`로 하드코딩되어 새로 저장한 route들도 같은 경유지처럼 보이던 문제를 고쳤습니다. 표시용 모델 `RouteStop`을 추가하고 Xcode project Sources에 연결했습니다. `Register My Route`와 `Edit Shortcut`에 `Full Route` 입력 섹션을 추가해 Start Detail, Via(Optional), Via Detail, Destination Detail을 직접 입력/수정할 수 있게 했고, `ShortcutDetailView`는 `shortcut.displayRouteStops`를 렌더링하도록 바꿨습니다. 이번 수정 직후 `xcodebuild`는 Codex 사용량 제한으로 승인 거절되어 실행하지 못했습니다. 대신 `plutil -lint LocalRouteShare.xcodeproj/project.pbxproj`와 `git diff --check`는 통과했습니다. 제한이 풀리면 위 빌드 명령을 다시 실행해야 합니다.

2026-06-08 `Register My Route`의 `Full Route Details` 입력 영역을 `Ready to record`/수동 description 블록 아래로 이동했고, 토글 카드 형태로 변경했습니다. 기본 상태에서는 `Start Detail`과 `Destination Detail`만 보이고, `Add Via`를 누르면 `Via`와 `Via Detail` 입력칸이 나타납니다. 다시 `Remove Via`로 숨기면 via 입력값도 초기화됩니다. `Edit Shortcut`도 같은 토글/Add Via 구조로 맞췄으며, 기존 shortcut에 via가 있으면 처음부터 via 입력칸이 보입니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Home 말풍선 안의 `Top 5% contributor!` 문구가 아래로 치우쳐 보여서, 말풍선 배경과 텍스트를 `ZStack`으로 분리하고 텍스트만 3pt 위로 올렸습니다. 말풍선 위치/크기는 그대로 유지했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

2026-06-08 Home 캐릭터를 살짝 왼쪽으로 이동했습니다(`x: 84 → 76`). 캐릭터를 탭하면 `MascotHeroView`가 눈 깜박임 레이어를 잠깐 표시하고, `mascotWobbleAngle`을 spring animation으로 `7.5 → -6 → 3.5 → 0` 순서로 바꿔 오뚜기처럼 흔들리도록 했습니다. 위 `xcodebuild` 명령으로 다시 확인했고 `BUILD SUCCEEDED`였습니다.

## 새 노트북에서 이어가는 방법

1. 이 폴더 전체를 새 노트북으로 옮깁니다.
2. 특히 아래 둘이 같은 상위 폴더 안에 있어야 합니다.
   - `LocalRouteShare.xcodeproj`
   - `LocalRouteShare/`
3. Codex에서 이 프로젝트 폴더를 열고 이렇게 말하면 됩니다.

```text
CODEX_HANDOFF.md를 먼저 읽고, 이 SwiftUI 앱 작업을 이어서 진행해줘.
```

## 주의

현재 이 환경에서는 `.git` 폴더가 상위 폴더가 아니라 `LocalRouteShare/.git` 안에 있습니다. 따라서 `LocalRouteShare.xcodeproj`가 git 추적 밖에 있을 수 있습니다. 새 노트북에서는 파일 복사 기준으로는 괜찮지만, git으로 관리하려면 Codex에게 “git 루트를 프로젝트 상위 폴더 기준으로 정리해줘”라고 요청하는 것이 좋습니다.
