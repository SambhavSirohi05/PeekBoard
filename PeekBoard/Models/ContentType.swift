import Foundation

public enum ContentType: String, Codable, CaseIterable {
    case text
    case url
    case code
    case hexColor = "hex_color"
    case email
    case phone
    case image
    
    public static func detect(from text: String) -> ContentType {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. HEX COLOR
        let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let rgbPattern = "^rgb\\(\\s*\\d+\\s*,\\s*\\d+\\s*,\\s*\\d+\\s*\\)$"
        if trimmed.range(of: hexPattern, options: .regularExpression) != nil ||
           trimmed.range(of: rgbPattern, options: .regularExpression) != nil {
            return .hexColor
        }
        
        // 2. URL
        if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased() {
            if ["http", "https", "ftp", "mailto"].contains(scheme) {
                return .url
            }
        }
        
        // 3. EMAIL
        let emailPattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        if trimmed.range(of: emailPattern, options: [.regularExpression, .caseInsensitive]) != nil {
            return .email
        }
        
        // 4. PHONE
        let phonePattern = "^(\\+?\\d[\\d\\s\\-\\(\\)]{7,}\\d)$"
        if trimmed.range(of: phonePattern, options: .regularExpression) != nil {
            return .phone
        }
        
        // 5. CODE
        var codeScore = 0
        if text.contains("{") || text.contains("}") { codeScore += 1 }
        if text.contains("=>") || text.contains("->") { codeScore += 1 }
        
        let codeKeywords = ["func", "def", "class", "const", "var", "let", "import", "return", "if (", "for ("]
        if codeKeywords.contains(where: { text.contains($0) }) { codeScore += 1 }
        
        if text.contains(";") { codeScore += 1 }
        
        let lines = text.components(separatedBy: .newlines)
        var indentCount = 0
        for line in lines {
            if line.hasPrefix("  ") || line.hasPrefix("\t") {
                indentCount += 1
            }
        }
        if indentCount >= 2 { codeScore += 1 }
        
        if codeScore >= 2 {
            return .code
        }
        
        return .text
    }
}
