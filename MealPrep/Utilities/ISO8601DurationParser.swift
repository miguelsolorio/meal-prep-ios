import Foundation

enum ISO8601DurationParser {
    /// Converts an ISO 8601 duration string like "PT1H30M" to "1h 30m"
    static func parse(_ duration: String) -> String {
        let (hours, minutes) = components(from: duration)
        switch (hours, minutes) {
        case (0, 0): return ""
        case (let h, 0) where h > 0: return "\(h)h"
        case (0, let m) where m > 0: return "\(m)m"
        default: return "\(hours)h \(minutes)m"
        }
    }

    /// Total minutes from an ISO 8601 duration string
    static func totalMinutes(_ duration: String) -> Int {
        let (hours, minutes) = components(from: duration)
        return hours * 60 + minutes
    }

    private static func components(from duration: String) -> (hours: Int, minutes: Int) {
        let pattern = #"PT(?:(\d+)H)?(?:(\d+)M)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: duration,
                range: NSRange(duration.startIndex..., in: duration)
              ) else {
            return (0, 0)
        }

        func int(at group: Int) -> Int {
            guard let range = Range(match.range(at: group), in: duration) else { return 0 }
            return Int(duration[range]) ?? 0
        }

        return (hours: int(at: 1), minutes: int(at: 2))
    }
}
