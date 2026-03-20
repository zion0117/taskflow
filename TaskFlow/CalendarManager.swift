import EventKit
import Observation

@Observable
class CalendarManager {
    static let shared = CalendarManager()

    private let store = EKEventStore()
    var isAuthorized = false

    private init() {
        checkStatus()
    }

    // MARK: - 권한 확인
    func checkStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .fullAccess || status == .writeOnly)
    }

    // MARK: - 권한 요청
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestWriteOnlyAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            print("Calendar 권한 요청 실패: \(error)")
            return false
        }
    }

    // MARK: - 태스크 → Apple Calendar 이벤트 추가
    @discardableResult
    func addEvent(title: String, dueDate: Date, notes: String = "") async -> String? {
        if !isAuthorized {
            let granted = await requestAccess()
            guard granted else { return nil }
        }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.notes = notes.isEmpty ? nil : notes
        event.startDate = dueDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: dueDate)!
        event.calendar = store.defaultCalendarForNewEvents
        event.alarms = [EKAlarm(relativeOffset: -3600)] // 1시간 전 알림

        do {
            try store.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            print("이벤트 저장 실패: \(error)")
            return nil
        }
    }

    // MARK: - 이벤트 삭제
    func removeEvent(identifier: String) {
        guard let event = store.event(withIdentifier: identifier) else { return }
        try? store.remove(event, span: .thisEvent)
    }
}
