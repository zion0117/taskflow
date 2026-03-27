import SwiftUI
import SwiftData

@main
struct TaskFlowApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Area.self, Project.self, Task.self, TimeEntry.self,
            StudyPlan.self, StudySession.self, SchoolEvent.self,
            WishItem.self, Transaction.self, MonthlyBudget.self,
            SavingsAccount.self, SavingsPayment.self,
            ScheduledTransaction.self,
            NoteDocument.self, NoteFolder.self, NoteBlock.self,
            SpreadsheetCell.self, MindMapNode.self,
            WeeklySchedule.self,
            Tag.self
        ])
        let storeURL = Self.resolveStoreURL()
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }

        // 첫 실행 시 "학교" Area 기본 생성
        if !UserDefaults.standard.bool(forKey: "didSeedSchoolArea") {
            let ctx = ModelContext(container)
            let school = Area(name: "학교", order: 0)
            ctx.insert(school)
            try? ctx.save()
            UserDefaults.standard.set(true, forKey: "didSeedSchoolArea")
        }

        // 시간표 시드 데이터
        if !UserDefaults.standard.bool(forKey: "didSeedWeeklySchedule") {
            let ctx = ModelContext(container)
            let schedules: [(String, Int, Int, Int, Int, Int, String, String)] = [
                // (제목, 요일, 시작시, 시작분, 종료시, 종료분, 색상, 장소)
                // 월요일 (0)
                ("Network Security",      0, 9, 0, 11, 0, "3B82F6", "공학b151"),
                ("신화·상상력·문화",         0, 11, 0, 12, 0, "22C55E", "캠b146"),
                // 화요일 (1)
                ("국가안보론",              1, 11, 0, 12, 0, "8B5CF6", "학754"),
                ("북한학",                 1, 12, 0, 14, 0, "F97316", "학754"),
                ("4차산업혁명과창의적인재",   1, 14, 0, 15, 0, "06B6D4", "학109"),
                ("SW리더십과기업가정신",     1, 17, 0, 18, 0, "EC4899", "공학b153"),
                // 목요일 (3)
                ("Network Security",      3, 11, 0, 12, 0, "3B82F6", "공학b151"),
                ("신화·상상력·문화",         3, 12, 0, 14, 0, "22C55E", "캠b146"),
                // 금요일 (4)
                ("국가안보론",              4, 11, 0, 12, 0, "8B5CF6", "학754"),
                ("북한학",                 4, 14, 0, 15, 0, "F97316", "학754"),
                ("4차산업혁명과창의적인재",   4, 15, 0, 17, 0, "06B6D4", "학109"),
            ]
            for s in schedules {
                let item = WeeklySchedule(
                    title: s.0, dayOfWeek: s.1,
                    startHour: s.2, startMinute: s.3,
                    endHour: s.4, endMinute: s.5,
                    colorHex: s.6, location: s.7
                )
                ctx.insert(item)
            }
            try? ctx.save()
            UserDefaults.standard.set(true, forKey: "didSeedWeeklySchedule")
        }
    }

    static func resolveStoreURL() -> URL {
        let fm = FileManager.default
        // iCloud Drive 안 TaskFlow 폴더에 데이터 저장
        let iCloudData = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/TaskFlow/AppData")
        do {
            try fm.createDirectory(at: iCloudData, withIntermediateDirectories: true)
            return iCloudData.appendingPathComponent("taskflow.sqlite")
        } catch {
            // iCloud Drive 접근 실패 시 로컬로 fallback
            let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            return appSupport.appendingPathComponent("taskflow.sqlite")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
