//
//  EncodeFailureTracker.swift
//  Harmony
//

import CloudKit
import os

/// Remembers which records failed to encode during this app session.
///
/// A record that fails to encode stays pending, so CKSyncEngine asks for it again on every send.
/// Only the first failure per record should be reported as an error; repeats would just be noise.
final class EncodeFailureTracker: Sendable {
    private let failedRecordIDs = OSAllocatedUnfairLock(initialState: Set<CKRecord.ID>())

    /// Records a failure and returns `true` if this is the first one for `recordID` in this session.
    func recordFailure(for recordID: CKRecord.ID) -> Bool {
        failedRecordIDs.withLock { $0.insert(recordID).inserted }
    }
}
