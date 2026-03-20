# TaskFlow

Things 3 + 열품타 스타일의 태스크 & 집중 타이머 앱 (iOS / macOS)

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| 플랫폼 | iOS 17+ / macOS 14+ |
| 프레임워크 | SwiftUI, SwiftData, Charts |
| 아키텍처 | MVVM-lite (SwiftData @Model + ObservableObject) |
| 저장소 | SwiftData (로컬, iCloud 동기화 가능) |

---

## 프로젝트 구조

```
TaskFlow/
├── TaskFlowApp.swift       # 앱 진입점, ModelContainer 설정
├── Models.swift            # SwiftData 모델 정의
├── ContentView.swift       # iOS TabView / macOS NavigationSplitView
├── TodayView.swift         # 오늘 탭 - 태스크 목록, 타이머
├── StatsView.swift         # 통계 탭 - 캘린더 히트맵, 차트
├── CalendarView.swift      # 캘린더 탭
├── Studyplanview.swift     # 학습 계획
├── Sheets.swift            # 추가/편집 시트
├── TimeManager.swift       # 타이머 로직
└── Extensions.swift        # Calendar, Color 등 확장
```

---

## 데이터 모델

```
Area (영역)
└── Project (프로젝트)
    └── Task (태스크)
        └── TimeEntry (타이머 기록)

StudyPlan (학습 계획)
└── StudySession (세션)
```

---

## 주요 기능

### 오늘 탭 (TodayView)
- 프로젝트별 오늘 할 일 목록
- 태스크 클릭 → 인라인 메모 + 날짜 설정 (Things 3 스타일)
- 태스크별 타이머 (play/pause)
- 활성 타이머 배너 (상단 고정)
- 인사말 + 날짜 헤더 (오전/오후/저녁)

### 통계 탭 (StatsView)
- 월별 캘린더 히트맵 (열품타 스타일)
  - 날짜별 집중 시간 표시
  - 강도별 주황 색상 (0h → 4h → 7h → 10h → 12h+)
- 일간 / 주간 / 월간 탭
  - 일간: 총 공부시간, 최대 집중, 시작·종료시간, 도넛 차트
  - 주간: 요일별 바차트, 프로젝트별 진행바
  - 월간: 요약 카드, 프로젝트 도넛 차트

### macOS 사이드바 (ContentView)
- Things 3 스타일 사이드바
- Area > Project 계층
- 프로젝트 상세 (인라인 태스크 추가)

### 학습 계획 (StudyPlanView)
- 강의/챕터 단위 계획 생성
- 날짜별 세션 배분
- 진행률 트래킹

---

## 디자인 방향

- **Things 3** 스타일: 깔끔한 리스트, 인라인 편집, 미니멀 아이콘
- **열품타** 스타일: 캘린더 히트맵, 시간 통계
- **스크린타임** 스타일: 오늘 집중 시간 히어로 카드
- iOS: `.ultraThinMaterial` 카드, 투명도 기반 레이어링
- 폰트: SF Pro (system), 주요 수치는 `.rounded` 디자인

---

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-03-20 | 프로젝트 초기 설정 (SwiftData 템플릿) |
| 2026-03-20 | Things 3 스타일 UI 구현 (TodayView, ContentView, StatsView 기본) |
| 2026-03-20 | GitHub 연결, SSH 설정 |
| 2026-03-20 | TodayView 투명도(ultraThinMaterial) 적용 |
| 2026-03-20 | 전체 폰트 크기·간격 확대 (iOS 기준) |
| 2026-03-20 | StatsView 전면 개편 — 열품타 캘린더 히트맵, 도넛 차트, 일간/주간/월간 탭 |
