import CloudKit
import XCTest
@testable import Harmony

private struct TestRecord: HRecord {
    var id = UUID()
    var archivedRecordData: Data?
    var payload: Data

    var zoneID: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: "TestRecord", ownerName: CKCurrentUserDefaultName)
    }
}

final class HarmonyTests: XCTestCase {
    func testEncodeRecordSucceedsForSmallRecord() throws {
        let record = try TestRecord(payload: Data(count: 10)).encodeRecord()
        XCTAssertEqual(record["payload"] as? Data, Data(count: 10))
    }

    func testEncodeRecordThrowsForOversizedRecord() {
        let oversized = TestRecord(payload: Data(count: 2 * 1024 * 1024))

        XCTAssertThrowsError(try oversized.encodeRecord()) { error in
            guard case EncodingError.invalidValue(_, let context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertTrue(context.debugDescription.contains("too large"))
            XCTAssertTrue(context.debugDescription.contains("Largest fields: payload"))
        }
    }

    func testEncodeFailureTrackerReportsOnlyFirstFailurePerRecord() {
        let tracker = EncodeFailureTracker()
        let first = CKRecord.ID(recordName: "TestRecord|1")
        let second = CKRecord.ID(recordName: "TestRecord|2")

        XCTAssertTrue(tracker.recordFailure(for: first))
        XCTAssertFalse(tracker.recordFailure(for: first))
        XCTAssertTrue(tracker.recordFailure(for: second))
    }
}
