//
//  Logger.swift
//  Harmony
//
//  Created by Aaron Pearce on 8/06/23.
//
import os.log

extension Logger {

    static let loggingSubsystem: String = "com.pearcemedia.Harmony"

    static let database = Logger(subsystem: Self.loggingSubsystem, category: "Database")
}

extension Harmonic {
    func log(_ message: String, level: OSLogType = .default) {
        logPublisher.send((level, message))
    }
}
