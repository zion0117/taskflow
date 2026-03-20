import Foundation
import SwiftUI

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

extension Color {
    /// Color → hex 문자열 (RRGGBB)
    func toHex() -> String {
        #if os(iOS)
        let ui = UIColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        ns.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return String(format: "%02X%02X%02X",
                      Int(r.clamped(to: 0...1) * 255),
                      Int(g.clamped(to: 0...1) * 255),
                      Int(b.clamped(to: 0...1) * 255))
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
