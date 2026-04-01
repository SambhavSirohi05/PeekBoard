import Foundation

public struct TimeAgoFormatter {
    public static func string(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        let diff = Int(now.timeIntervalSince(date))
        
        if diff < 60 {
            return "just now"
        } else if diff < 3600 {
            let m = diff / 60
            return "\(m)m ago"
        } else if diff < 86400 {
            let h = diff / 3600
            return "\(h)h ago"
        } else {
            let d = diff / 86400
            return "\(d)d ago"
        }
    }
}
