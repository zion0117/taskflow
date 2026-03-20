import SwiftUI
import SwiftData
import Charts

// MARK: - StatsView
struct StatsView: View {
    @Query private var projects: [Project]
    @State private var currentMonth = Date()
    @State private var selectedDate: Date? = Calendar.current.startOfDay(for: Date())
    @State private var selectedTab: StatTab = .daily

    enum StatTab: String, CaseIterable { case daily = "일간"; case weekly = "주간"; case monthly = "월간" }

    var allEntries: [TimeEntry] { projects.flatMap { $0.tasks }.flatMap { $0.timeEntries } }

    var monthTotal: Int {
        let cal = Calendar.current
        return allEntries.filter { cal.isDate($0.startedAt, equalTo: currentMonth, toGranularity: .month) }
            .reduce(0) { $0 + $1.seconds }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Month nav
                HStack(spacing: 16) {
                    Button {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                    } label: {
                        Image(systemName: "chevron.left").font(.system(size: 15, weight: .semibold))
                    }
                    .buttonStyle(.plain)

                    Text(monthString(currentMonth))
                        .font(.system(size: 18, weight: .bold))
                        .frame(minWidth: 60, alignment: .center)

                    Button {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    } label: {
                        Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("\(monthString(currentMonth)): \(fmtHM(monthTotal))")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.background)

                // MARK: Calendar heatmap
                MonthCalendarView(
                    month: currentMonth,
                    allEntries: allEntries,
                    selectedDate: $selectedDate
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .background(.background)

                // MARK: Legend
                HStack(spacing: 6) {
                    ForEach(zip(["0+","4+","7+","10+","12+"], heatColors).map { $0 }, id: \.0) { label, color in
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 12, height: 12)
                            Text(label).font(.system(size: 10)).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.background)

                Divider()

                // MARK: Tab selector
                HStack(spacing: 0) {
                    ForEach(StatTab.allCases, id: \.self) { tab in
                        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } } label: {
                            VStack(spacing: 6) {
                                Text(tab.rawValue)
                                    .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .regular))
                                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.primary : Color.clear)
                                    .frame(height: 2)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .background(.background)

                Divider()

                // MARK: Tab content
                Group {
                    switch selectedTab {
                    case .daily:
                        DailyStatsView(date: selectedDate ?? Date(), allEntries: allEntries, projects: projects)
                    case .weekly:
                        WeeklyStatsView(allEntries: allEntries, projects: projects)
                    case .monthly:
                        MonthlyStatsView(month: currentMonth, allEntries: allEntries, projects: projects)
                    }
                }
                .background(Color.secondary.opacity(0.06))
            }
        }
        .background(Color.secondary.opacity(0.06))
    }

    var heatColors: [Color] {
        [Color.secondary.opacity(0.12), Color.orange.opacity(0.25), Color.orange.opacity(0.5), Color.orange.opacity(0.75), Color.orange]
    }

    func monthString(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ko_KR"); f.dateFormat = "M월"
        return f.string(from: d)
    }
}

// MARK: - Month Calendar
struct MonthCalendarView: View {
    var month: Date
    var allEntries: [TimeEntry]
    @Binding var selectedDate: Date?

    var cal: Calendar { Calendar.current }
    let weekdayLabels = ["월","화","수","목","금","토","일"]

    var firstDay: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: month))!
    }

    var daysGrid: [[Date?]] {
        let range = cal.range(of: .day, in: .month, for: firstDay)!
        var wd = cal.component(.weekday, from: firstDay) - 2
        if wd < 0 { wd = 6 }
        var flat: [Date?] = Array(repeating: nil, count: wd)
        for d in range {
            flat.append(cal.date(byAdding: .day, value: d - 1, to: firstDay))
        }
        while flat.count % 7 != 0 { flat.append(nil) }
        return stride(from: 0, to: flat.count, by: 7).map { Array(flat[$0..<$0+7]) }
    }

    func secondsOn(_ date: Date) -> Int {
        allEntries.filter { cal.isDate($0.startedAt, inSameDayAs: date) }.reduce(0) { $0 + $1.seconds }
    }

    func heatColor(_ date: Date) -> Color {
        let h = Double(secondsOn(date)) / 3600
        if h == 0   { return Color.secondary.opacity(0.08) }
        if h < 4    { return Color.orange.opacity(0.25) }
        if h < 7    { return Color.orange.opacity(0.5) }
        if h < 10   { return Color.orange.opacity(0.75) }
        return Color.orange
    }

    func shortTime(_ s: Int) -> String {
        let h = s / 3600; let m = (s % 3600) / 60
        return String(format: "%02d:%02d", h, m)
    }

    var body: some View {
        VStack(spacing: 2) {
            // Weekday header
            HStack(spacing: 2) {
                ForEach(weekdayLabels, id: \.self) { d in
                    Text(d).font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 6)

            // Rows
            ForEach(daysGrid.indices, id: \.self) { ri in
                HStack(spacing: 2) {
                    ForEach(0..<7) { ci in
                        if let date = daysGrid[ri][ci] {
                            let s = secondsOn(date)
                            let isSelected = selectedDate.map { cal.isDate($0, inSameDayAs: date) } ?? false
                            let isToday = cal.isDateInToday(date)

                            Button { selectedDate = date } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(s > 0 ? heatColor(date) : Color.secondary.opacity(0.06))
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)

                                    VStack(spacing: 2) {
                                        Text("\(cal.component(.day, from: date))")
                                            .font(.system(size: 12, weight: isToday ? .bold : .regular))
                                            .foregroundStyle(isToday ? Color.blue : Color.primary)
                                        if s > 0 {
                                            Text(shortTime(s))
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundStyle(.primary.opacity(0.85))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 46)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Daily Stats
struct DailyStatsView: View {
    var date: Date
    var allEntries: [TimeEntry]
    var projects: [Project]

    var cal: Calendar { Calendar.current }

    var dayEntries: [TimeEntry] { allEntries.filter { cal.isDate($0.startedAt, inSameDayAs: date) } }
    var totalSeconds: Int { dayEntries.reduce(0) { $0 + $1.seconds } }
    var maxFocusSeconds: Int { dayEntries.map { $0.seconds }.max() ?? 0 }
    var startTime: Date? { dayEntries.map { $0.startedAt }.min() }
    var endTime: Date? { dayEntries.compactMap { $0.endedAt }.max() }

    var breakdown: [(Project, Int)] {
        projects.compactMap { proj -> (Project, Int)? in
            let s = proj.tasks.flatMap { $0.timeEntries }
                .filter { cal.isDate($0.startedAt, inSameDayAs: date) }
                .reduce(0) { $0 + $1.seconds }
            return s > 0 ? (proj, s) : nil
        }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(spacing: 14) {
            Text(dateLabel(date))
                .font(.system(size: 15, weight: .semibold))
                .padding(.top, 16)

            // 4-cell stats grid
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    StatCell(label: "총 공부시간", value: hhmmss(totalSeconds), accent: .orange)
                    StatCell(label: "최대 집중 시간", value: hhmmss(maxFocusSeconds), accent: .orange)
                }
                HStack(spacing: 1) {
                    StatCell(label: "시작시간", value: ampm(startTime), accent: .secondary)
                    StatCell(label: "종료시간", value: ampm(endTime), accent: .secondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)

            // Donut + list
            if !breakdown.isEmpty {
                HStack(alignment: .center, spacing: 20) {
                    Chart(breakdown, id: \.0.id) { proj, secs in
                        SectorMark(
                            angle: .value("시간", secs),
                            innerRadius: .ratio(0.58),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color(hex: proj.colorHex) ?? .blue)
                        .cornerRadius(3)
                    }
                    .frame(width: 110, height: 110)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(breakdown, id: \.0.id) { proj, secs in
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: proj.colorHex) ?? .blue)
                                    .frame(width: 4, height: 18)
                                Text(proj.name).font(.system(size: 13)).lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(fmtHMS(secs)).font(.system(size: 12, weight: .semibold))
                                    let pct = totalSeconds > 0 ? Int(Double(secs)/Double(totalSeconds)*100) : 0
                                    Text("\(pct)%").font(.system(size: 11)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars").font(.system(size: 32)).foregroundStyle(.secondary.opacity(0.5))
                    Text("이 날 기록이 없어요").font(.system(size: 15)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }

            // Time block chart
            TimeBlockChart(date: date, allEntries: allEntries)
                .padding(.horizontal, 16)

            Spacer().frame(height: 40)
        }
    }

    func hhmmss(_ s: Int) -> String { String(format: "%02d:%02d:%02d", s/3600, (s%3600)/60, s%60) }
    func fmtHMS(_ s: Int) -> String { String(format: "%d:%02d:%02d", s/3600, (s%3600)/60, s%60) }
    func ampm(_ d: Date?) -> String {
        guard let d else { return "--:--" }
        let f = DateFormatter(); f.locale = Locale(identifier: "ko_KR"); f.dateFormat = "a h:mm"
        return f.string(from: d)
    }
    func dateLabel(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ko_KR"); f.dateFormat = "M월 d일 (E)"
        return f.string(from: d)
    }
}

// MARK: - Time Block Chart
struct TimeBlockChart: View {
    var date: Date
    var allEntries: [TimeEntry]

    var cal: Calendar { Calendar.current }

    // 해당 날의 TimeEntry + 프로젝트 색상
    var dayPairs: [(TimeEntry, Color)] {
        allEntries.compactMap { entry in
            guard cal.isDate(entry.startedAt, inSameDayAs: date) else { return nil }
            let hex = entry.task?.project?.colorHex ?? "8E8E93"
            return (entry, Color(hex: hex) ?? .blue)
        }
    }

    // 표시할 시간 범위
    var hourRange: [Int] {
        guard !dayPairs.isEmpty else { return Array(8...22) }
        let starts = dayPairs.map { cal.component(.hour, from: $0.0.startedAt) }
        let ends = dayPairs.compactMap { $0.0.endedAt }.map { cal.component(.hour, from: $0) }
        let lo = max(0, (starts.min() ?? 8))
        let hi = min(23, (ends.max() ?? 22) + 1)
        return Array(lo...hi)
    }

    // 특정 10분 블록의 색상 반환
    func color(hour: Int, block: Int) -> Color? {
        guard let blockStart = cal.date(bySettingHour: hour, minute: block * 10, second: 0, of: date) else { return nil }
        let blockEnd = blockStart.addingTimeInterval(600)
        for (entry, color) in dayPairs {
            let end = entry.endedAt ?? Date()
            if entry.startedAt < blockEnd && end > blockStart { return color }
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("타임 블록")
                .font(.system(size: 15, weight: .semibold))

            if dayPairs.isEmpty {
                Text("기록 없음").font(.system(size: 14)).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        // 시간 레이블
                        VStack(alignment: .trailing, spacing: 0) {
                            ForEach(hourRange, id: \.self) { h in
                                Text(h < 12 ? "오전\(h)" : (h == 12 ? "오후12" : "오후\(h-12)"))
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .frame(height: 22, alignment: .center)
                            }
                        }
                        // 블록 그리드
                        VStack(spacing: 2) {
                            ForEach(hourRange, id: \.self) { h in
                                HStack(spacing: 2) {
                                    ForEach(0..<6, id: \.self) { b in
                                        let c = color(hour: h, block: b)
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(c ?? Color.secondary.opacity(0.08))
                                            .frame(maxWidth: .infinity, minHeight: 18)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Cell
struct StatCell: View {
    var label: String
    var value: String
    var accent: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label).font(.system(size: 12, weight: .medium)).foregroundStyle(accent)
            Text(value).font(.system(size: 21, weight: .bold, design: .monospaced))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(.background)
    }
}

// MARK: - Weekly Stats
struct WeeklyStatsView: View {
    var allEntries: [TimeEntry]
    var projects: [Project]

    var cal: Calendar { Calendar.current }

    var weekDays: [Date] {
        let today = Date()
        let wd = cal.component(.weekday, from: today)
        let monday = cal.date(byAdding: .day, value: -(wd - 2), to: today)!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }

    func secondsOn(_ d: Date) -> Int {
        allEntries.filter { cal.isDate($0.startedAt, inSameDayAs: d) }.reduce(0) { $0 + $1.seconds }
    }

    var totalWeek: Int { weekDays.reduce(0) { $0 + secondsOn($1) } }
    var maxDay: Int { weekDays.map { secondsOn($0) }.max() ?? 1 }

    var breakdown: [(Project, Int)] {
        projects.compactMap { proj -> (Project, Int)? in
            let s = proj.tasks.flatMap { $0.timeEntries }
                .filter { cal.isDateInThisWeek($0.startedAt) }
                .reduce(0) { $0 + $1.seconds }
            return s > 0 ? (proj, s) : nil
        }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(spacing: 14) {
            // Weekly bar
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("이번 주 합계").font(.system(size: 13)).foregroundStyle(.secondary)
                    Spacer()
                    Text(fmtHM(totalWeek)).font(.system(size: 15, weight: .bold))
                }

                Chart {
                    ForEach(weekDays, id: \.self) { day in
                        BarMark(x: .value("요일", dayLabel(day)), y: .value("분", secondsOn(day) / 60))
                            .foregroundStyle(cal.isDateInToday(day) ? Color.orange : Color.orange.opacity(0.35))
                            .cornerRadius(6)
                    }
                }
                .chartYAxis {
                    AxisMarks { val in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.12))
                        AxisValueLabel {
                            if let v = val.as(Int.self) {
                                Text(v >= 60 ? "\(v/60)h" : "\(v)m").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 130)
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Project breakdown
            if !breakdown.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("과목별").font(.system(size: 15, weight: .semibold))
                    ForEach(breakdown, id: \.0.id) { proj, secs in
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: proj.colorHex) ?? .blue).frame(width: 10, height: 10)
                            Text(proj.name).font(.system(size: 14))
                            Spacer()
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3).fill(Color.secondary.opacity(0.12)).frame(height: 5)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(hex: proj.colorHex) ?? .blue)
                                        .frame(width: geo.size.width * (totalWeek > 0 ? Double(secs)/Double(totalWeek) : 0), height: 5)
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .frame(width: 80, height: 20)
                            Text(fmtHM(secs)).font(.system(size: 13, weight: .medium)).foregroundStyle(.secondary).frame(width: 56, alignment: .trailing)
                        }
                    }
                }
                .padding(16)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }

            Spacer().frame(height: 40)
        }
    }

    func dayLabel(_ d: Date) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "ko_KR"); f.dateFormat = "E"
        return f.string(from: d)
    }
}

// MARK: - Monthly Stats
struct MonthlyStatsView: View {
    var month: Date
    var allEntries: [TimeEntry]
    var projects: [Project]

    var cal: Calendar { Calendar.current }

    var monthEntries: [TimeEntry] {
        allEntries.filter { cal.isDate($0.startedAt, equalTo: month, toGranularity: .month) }
    }
    var total: Int { monthEntries.reduce(0) { $0 + $1.seconds } }
    var activeDays: Int {
        Set(monthEntries.map { cal.startOfDay(for: $0.startedAt) }).count
    }
    var dailyAvg: Int { activeDays > 0 ? total / activeDays : 0 }

    var breakdown: [(Project, Int)] {
        projects.compactMap { proj -> (Project, Int)? in
            let s = proj.tasks.flatMap { $0.timeEntries }
                .filter { cal.isDate($0.startedAt, equalTo: month, toGranularity: .month) }
                .reduce(0) { $0 + $1.seconds }
            return s > 0 ? (proj, s) : nil
        }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(spacing: 14) {
            // Summary cells
            VStack(spacing: 1) {
                HStack(spacing: 1) {
                    StatCell(label: "월 총 시간", value: fmtHM(total), accent: .orange)
                    StatCell(label: "일 평균", value: fmtHM(dailyAvg), accent: .orange)
                }
                HStack(spacing: 1) {
                    StatCell(label: "활동 일수", value: "\(activeDays)일", accent: .secondary)
                    StatCell(label: "프로젝트", value: "\(breakdown.count)개", accent: .secondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Donut + list
            if !breakdown.isEmpty {
                HStack(alignment: .center, spacing: 20) {
                    Chart(breakdown, id: \.0.id) { proj, secs in
                        SectorMark(
                            angle: .value("시간", secs),
                            innerRadius: .ratio(0.58),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color(hex: proj.colorHex) ?? .blue)
                        .cornerRadius(3)
                    }
                    .frame(width: 110, height: 110)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(breakdown, id: \.0.id) { proj, secs in
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: proj.colorHex) ?? .blue)
                                    .frame(width: 4, height: 18)
                                Text(proj.name).font(.system(size: 13)).lineLimit(1)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 1) {
                                    Text(fmtHM(secs)).font(.system(size: 12, weight: .semibold))
                                    let pct = total > 0 ? Int(Double(secs)/Double(total)*100) : 0
                                    Text("\(pct)%").font(.system(size: 11)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
            }

            Spacer().frame(height: 40)
        }
    }
}

// MARK: - Helpers
func fmtHM(_ s: Int) -> String {
    let h = s / 3600; let m = (s % 3600) / 60
    if h > 0 { return "\(h)h \(m)m" }
    if m > 0 { return "\(m)m" }
    return "0m"
}
