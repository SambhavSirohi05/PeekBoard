import Foundation
import GRDB

public struct ClipboardEntry: Identifiable, Codable, Equatable, FetchableRecord, PersistableRecord {
    public var id: Int64?
    public var contentText: String?
    public var contentType: String
    public var imageThumbnailData: Data?
    public var sourceAppBundleId: String?
    public var sourceAppName: String?
    public var createdAt: Double
    public var isPinned: Bool
    public var pinOrder: Int?
    
    public enum CodingKeys: String, CodingKey {
        case id
        case contentText = "content_text"
        case contentType = "content_type"
        case imageThumbnailData = "image_thumbnail_data"
        case sourceAppBundleId = "source_app_bundle_id"
        case sourceAppName = "source_app_name"
        case createdAt = "created_at"
        case isPinned = "is_pinned"
        case pinOrder = "pin_order"
    }
    
    public static let databaseTableName = "clipboard_entries"
    
    public init(
        id: Int64? = nil,
        contentText: String? = nil,
        contentType: String,
        imageThumbnailData: Data? = nil,
        sourceAppBundleId: String? = nil,
        sourceAppName: String? = nil,
        createdAt: Double = Date().timeIntervalSince1970,
        isPinned: Bool = false,
        pinOrder: Int? = nil
    ) {
        self.id = id
        self.contentText = contentText
        self.contentType = contentType
        self.imageThumbnailData = imageThumbnailData
        self.sourceAppBundleId = sourceAppBundleId
        self.sourceAppName = sourceAppName
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.pinOrder = pinOrder
    }
}
