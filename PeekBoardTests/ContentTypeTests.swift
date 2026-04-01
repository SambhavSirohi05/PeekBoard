import XCTest
@testable import PeekBoard

final class ContentTypeTests: XCTestCase {
    func testHexColor() {
        XCTAssertEqual(ContentType.detect(from: "#FFFFFF"), .hexColor)
        XCTAssertEqual(ContentType.detect(from: "#fff"), .hexColor)
        XCTAssertEqual(ContentType.detect(from: "rgb(255, 255, 255)"), .hexColor)
    }
    
    func testURL() {
        XCTAssertEqual(ContentType.detect(from: "https://apple.com"), .url)
        XCTAssertEqual(ContentType.detect(from: "mailto:test@example.com"), .url)
    }
    
    func testEmail() {
        XCTAssertEqual(ContentType.detect(from: "hello@world.com"), .email)
        // Ensure email doesn't get picked up as URL since mailto: wasn't in the string
    }
    
    func testPhone() {
        XCTAssertEqual(ContentType.detect(from: "+1 (555) 123-4567"), .phone)
        XCTAssertEqual(ContentType.detect(from: "18005551234"), .text) // Without formatting/plus, default to text or phone based on regex
    }
    
    func testCode() {
        let codeSnippet = """
        func test() {
          let a = 1;
          return a;
        }
        """
        XCTAssertEqual(ContentType.detect(from: codeSnippet), .code)
    }
    
    func testText() {
        XCTAssertEqual(ContentType.detect(from: "Just a regular text string"), .text)
    }
}
