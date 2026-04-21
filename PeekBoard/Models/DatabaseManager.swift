import Foundation
import GRDB

public final class DatabaseManager {
    public static let shared = try! DatabaseManager()
    public let dbWriter: DatabaseWriter

    private init() throws {
        let fileManager = FileManager.default
        let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directoryURL = appSupportURL.appendingPathComponent("PeekBoard", isDirectory: true)
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        
        let dbURL = directoryURL.appendingPathComponent("peekboard.db")
        dbWriter = try DatabasePool(path: dbURL.path)
        
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { db in
            try db.create(table: "clipboard_entries") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("content_text", .text)
                t.column("content_type", .text).notNull()
                t.column("image_thumbnail_data", .blob)
                t.column("source_app_bundle_id", .text)
                t.column("source_app_name", .text)
                t.column("created_at", .real).notNull()
                t.column("is_pinned", .integer).notNull().defaults(to: 0)
                t.column("pin_order", .integer)
            }
            
            try db.create(virtualTable: "clipboard_entries_fts", using: FTS5()) { t in
                t.synchronize(withTable: "clipboard_entries")
                t.column("content_text")
            }
        }
        
        migrator.registerMigration("v2") { db in
            try db.alter(table: "clipboard_entries") { t in
                t.add(column: "alias", .text)
            }
            
            try db.drop(table: "clipboard_entries_fts")
            try db.execute(sql: "DROP TRIGGER IF EXISTS __clipboard_entries_fts_ai")
            try db.execute(sql: "DROP TRIGGER IF EXISTS __clipboard_entries_fts_ad")
            try db.execute(sql: "DROP TRIGGER IF EXISTS __clipboard_entries_fts_au")
            
            try db.create(virtualTable: "clipboard_entries_fts", using: FTS5()) { t in
                t.synchronize(withTable: "clipboard_entries")
                t.column("content_text")
                t.column("alias")
            }
        }
        
        try migrator.migrate(dbWriter)
    }

    public func insertOrUpdate(_ entry: inout ClipboardEntry) throws {
        try dbWriter.write { db in
            try entry.save(db)
            
            let limit = UserDefaults.standard.integer(forKey: UserDefaultsKeys.historyLimit)
            let effectiveLimit = limit == 0 ? 200 : (limit == -1 ? Int.max : limit)
            
            if effectiveLimit != Int.max {
                let unpinnedCount = try ClipboardEntry.filter(Column("is_pinned") == 0).fetchCount(db)
                if unpinnedCount > effectiveLimit {
                    let oldest = try ClipboardEntry
                        .filter(Column("is_pinned") == 0)
                        .order(Column("created_at").asc)
                        .limit(1)
                        .fetchOne(db)
                    
                    if let oldest = oldest {
                        _ = try oldest.delete(db)
                    }
                }
            }
        }
    }
    
    public func updatePinned(_ entry: ClipboardEntry, isPinned: Bool) throws {
        guard let id = entry.id else { return }
        
        let newPinOrder: Int?
        if isPinned {
            newPinOrder = try nextPinOrder()
        } else {
            newPinOrder = nil
        }
        
        try dbWriter.write { db in
            try db.execute(
                sql: "UPDATE clipboard_entries SET is_pinned = ?, pin_order = ? WHERE id = ?",
                arguments: [isPinned ? 1 : 0, newPinOrder, id]
            )
        }
    }
    
    public func updateAlias(_ entry: ClipboardEntry, alias: String?) throws {
        guard let id = entry.id else { return }
        try dbWriter.write { db in
            try db.execute(
                sql: "UPDATE clipboard_entries SET alias = ? WHERE id = ?",
                arguments: [alias, id]
            )
        }
    }
    
    private func nextPinOrder() throws -> Int {
        return try dbWriter.read { db in
            let maxOrder = try Int.fetchOne(db, sql: "SELECT MAX(pin_order) FROM clipboard_entries")
            return (maxOrder ?? 0) + 1
        }
    }
    
    public func fetchRecent() throws -> [ClipboardEntry] {
        return try dbWriter.read { db in
            try ClipboardEntry
                .filter(Column("is_pinned") == 0)
                .order(Column("created_at").desc)
                .fetchAll(db)
        }
    }
    
    public func fetchPinned() throws -> [ClipboardEntry] {
        return try dbWriter.read { db in
            try ClipboardEntry
                .filter(Column("is_pinned") == 1)
                .order(Column("pin_order").asc)
                .fetchAll(db)
        }
    }

    public func search(query: String) throws -> [ClipboardEntry] {
        return try dbWriter.read { db in
            let sql = """
            SELECT clipboard_entries.* FROM clipboard_entries
            JOIN clipboard_entries_fts ON clipboard_entries.id = clipboard_entries_fts.rowid
            WHERE clipboard_entries_fts MATCH ?
            ORDER BY created_at DESC
            """
            // Using a simple FTS pattern matching prefix
            // In a real GRDB we might use FTS3Pattern(matchingAnyToken: query)
            // But manually appending * often works for literal queries if it's alphanumeric.
            // Let's rely on basic query execution
            let ftsQuery = "\(query)*"
            return try ClipboardEntry.fetchAll(db, sql: sql, arguments: [ftsQuery])
        }
    }
    
    public func clearAllHistory() throws {
        try dbWriter.write { db in
            _ = try db.execute(sql: "DELETE FROM clipboard_entries")
        }
    }
    
    public func clearUnpinnedHistory() throws {
        try dbWriter.write { db in
            _ = try db.execute(sql: "DELETE FROM clipboard_entries WHERE is_pinned = 0")
        }
    }
    
    public func deleteEntry(_ entry: ClipboardEntry) throws {
        try dbWriter.write { db in
            _ = try entry.delete(db)
        }
    }
    
    public func deleteEntries(ofType type: String) throws {
        try dbWriter.write { db in
            _ = try db.execute(sql: "DELETE FROM clipboard_entries WHERE content_type = ?", arguments: [type])
        }
    }
}
