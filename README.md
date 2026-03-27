# TaskFlow

**올인원 생산성 & 생활 관리 앱** — SwiftUI + SwiftData 기반 iOS/macOS 크로스플랫폼

Things 3 + 열품타 스타일의 태스크 관리, 타이머, 가계부, 노트, 시간표를 하나로.

---

## 주요 기능

### 1. 할 일 & 프로젝트 관리
- **Area → Project → Task** 계층 구조
- 태그(Tag) 기반 분류 (다대다 관계)
- 마감일 설정 및 완료 체크
- 프로젝트별 색상 커스터마이징
- 사이드바에서 우클릭으로 Area/Project 편집·삭제

### 2. 시간 추적 (타이머)
- 태스크별 실시간 타이머 Start/Stop
- 누적 시간 자동 계산 (TimeEntry)
- 앱 재시작 후에도 타이머 상태 유지
- 활성 타이머 배너 (상단 고정)

### 3. 노트 에디터 (블록 기반)
- **텍스트 블록** — 자동 개요 번호 (1. → 1) → (1) → ①), 들여쓰기(Tab), 텍스트 색상, 하이라이트
- **이미지 블록** — 파일 임포트, 드래그 리사이즈, 자유 위치 이동
- **PDF 임포트** — 페이지별 이미지로 자동 분할 삽입
- **텍스트박스** — 자유 배치 가능한 텍스트 영역 (투명 블루 배경)
- **마인드맵** — 노드 추가/삭제/편집, 드래그 이동, 곡선 연결선, 노드 색상
- **포스트잇** — 6색 컬러, 자유 위치, 접힌 모서리 디자인
- 모든 블록 드래그로 자유 이동 & 리사이즈 가능

### 4. 시간표 (주간 고정 스케줄)
- 월~일 시간표 그리드 뷰
- 수업/알바 등 매주 반복 스케줄 등록
- 시작·종료 시간, 장소, 메모, 색상(9종) 설정
- 탭으로 편집, 꾹 눌러서(우클릭) 삭제

### 5. 캘린더
- 월간 캘린더 뷰
- 태스크 마감일 + 시험 일정 표시
- 중간고사/기말고사 D-Day 카운트다운
- Apple Calendar 연동 (EventKit)

### 6. 학습 계획
- 과목별 진도 관리 (전체 단원 수 / 완료 수)
- 기간 설정 (시작일 ~ 종료일)
- 날짜별 학습 세션 기록
- 프로젝트와 연동

### 7. 가계부
- 수입/지출 거래 기록
- 카테고리별 분류 (중고거래, 구독, 의류, 디지털, 문화 등)
- 결제수단 (카드, 현금, 계좌이체, 페이)
- 구매처 추적 (쿠팡, 배민, 무신사, 올리브영 등)
- 월별 예산 설정 & 카테고리별 한도
- 정기 결제 자동 등록 (ScheduledTransaction)
- 적금 관리 (목표 금액, 이율, 만기일, 납입 추적)

### 8. 위시리스트
- 카테고리별 위시 아이템 관리 (전자기기, 패션, 도서 등)
- 가격, 구매처, URL 저장
- 구매 완료 체크

### 9. 통계
- 일간/주간/월간 시간 추적 통계
- 열품타 스타일 캘린더 히트맵 (강도별 색상)
- 프로젝트별 도넛 차트, 요일별 바차트
- Charts 프레임워크 시각화

### 10. 오늘 / Upcoming
- 오늘 할 일 + 지연된 태스크 모아보기
- 프로젝트별 그룹핑
- 인사말 + 날짜 헤더 (오전/오후/저녁)
- 다가오는 일정 날짜별 정렬

---

## 플랫폼

| 플랫폼 | UI 방식 | 탭/메뉴 |
|--------|---------|---------|
| **macOS** | NavigationSplitView (사이드바 + 디테일) | 사이드바: 오늘, Upcoming, 캘린더, 가계부, 위시리스트, 통계, 학습계획, 시간표, Area/Project, 노트 |
| **iOS** | TabView (하단 탭) | 오늘, Upcoming, 캘린더, 통계, 가계부, 위시리스트, 시간표, 노트 |

하나의 코드베이스에서 `#if os(iOS)` / `#if os(macOS)` 분기로 각 플랫폼에 최적화된 UI 제공

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| 플랫폼 | iOS / macOS |
| 프레임워크 | SwiftUI, SwiftData, Charts, PDFKit, EventKit |
| 아키텍처 | MVVM-lite (SwiftData @Model + @Observable) |
| 저장소 | SwiftData → iCloud Drive 자동 동기화 |

---

## 데이터 저장

```
~/Library/Mobile Documents/com~apple~CloudDocs/TaskFlow/AppData/taskflow.sqlite
```

iCloud Drive에 저장되어 맥과 아이폰 간 자동 동기화. iCloud 접근 불가 시 로컬(`Application Support`)에 폴백.

---

## 데이터 모델 (20개)

```
Area, Project, Task, TimeEntry, Tag, SchoolEvent,
Transaction, MonthlyBudget, ScheduledTransaction,
SavingsAccount, SavingsPayment, WishItem,
StudyPlan, StudySession, WeeklySchedule,
NoteDocument, NoteFolder, NoteBlock,
SpreadsheetCell, MindMapNode
```

### 관계도
```
Area (영역: 학교, 회사, 개인)
└── Project (프로젝트: 과목, 업무)
    ├── Task (태스크)
    │   ├── TimeEntry (타이머 기록)
    │   └── Tag (태그, 다대다)
    ├── NoteDocument (노트)
    │   ├── NoteBlock (텍스트/이미지/텍스트박스/마인드맵/포스트잇)
    │   │   └── MindMapNode (마인드맵 노드)
    │   └── SpreadsheetCell (스프레드시트 셀)
    └── NoteFolder (노트 폴더)

WeeklySchedule (주간 고정 스케줄 - 독립)
StudyPlan → StudySession (학습 계획)
Transaction / MonthlyBudget / ScheduledTransaction (가계부)
SavingsAccount → SavingsPayment (적금)
WishItem (위시리스트)
SchoolEvent (학교 행사)
```

---

## 프로젝트 구조

```
TaskFlow/
├── TaskFlowApp.swift          # 앱 진입점, ModelContainer & iCloud 설정
├── Models.swift               # 전체 데이터 모델 (20개)
├── ContentView.swift          # 메인 레이아웃 (iOS TabView / macOS Sidebar)
├── TodayView.swift            # 오늘 뷰 - 태스크 목록, 타이머
├── UpcomingView.swift         # 다가오는 일정
├── CalendarView.swift         # 캘린더 뷰
├── StatsView.swift            # 통계 (히트맵, 차트)
├── SpendingView.swift         # 가계부
├── WishlistView.swift         # 위시리스트
├── WeeklyScheduleView.swift   # 시간표 (주간 고정 스케줄)
├── Studyplanview.swift        # 학습 계획
├── NotesView.swift            # 노트 목록
├── NoteEditorView.swift       # 노트 에디터 (블록 기반)
├── Extensions.swift           # Color(hex:), 날짜 유틸리티
├── TimeManager.swift          # 타이머 매니저 (@Observable)
├── Sheets.swift               # 공통 시트 (Add Area/Project/Task)
├── TagViews.swift             # 태그 관리 뷰
└── CalendarManager.swift      # Apple Calendar 연동 (EventKit)
```

---

## 설치 방법

### macOS
Xcode에서 프로젝트 열기 → 상단 디바이스 `My Mac` 선택 → ⌘R

### iPhone (무료, 개발자 계정 불필요)
1. **Xcode → Settings → Accounts** → Apple ID 로그인
2. 프로젝트 → **Signing & Capabilities** → Team을 본인 Personal Team 선택
3. **Bundle Identifier**를 고유하게 변경 (예: `com.yourname.TaskFlow`)
4. 아이폰 USB 연결 → 디바이스 선택 → ⌘R
5. 아이폰 **설정 → 일반 → VPN 및 기기 관리** → 신뢰

> 무료 계정은 7일마다 Xcode에서 재빌드 필요

---

## 디자인 방향

- **Things 3** 스타일: 깔끔한 리스트, 인라인 편집, 미니멀 아이콘
- **열품타** 스타일: 캘린더 히트맵, 시간 통계
- iOS: 뮤트 파스텔톤 컬러 팔레트
- 폰트: SF Pro (system), 주요 수치는 `.rounded` 디자인
- 앱 아이콘: 인디고-퍼플 그라디언트 + 흰색 흐르는 곡선

---

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-03-19 | 프로젝트 초기 설정 (SwiftData) |
| 2026-03-20 | Things 3 스타일 UI, StatsView 히트맵, Apple Calendar 연동, 앱 아이콘 |
| 2026-03-27 | 노트 에디터 전면 개편 — 블록 기반 (이미지/텍스트박스/마인드맵/포스트잇), PDF 임포트 |
| 2026-03-27 | 시간표 (WeeklySchedule) 추가 — 주간 고정 스케줄 |
| 2026-03-27 | 가계부 & 위시리스트 추가 |
| 2026-03-27 | iOS 탭 지원 (시간표, 노트 탭 추가) |
| 2026-03-27 | 사이드바 Area/Project 우클릭 편집·삭제 |
