//
//  Date+Extension.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation

extension Date {
    
    init(_ millisec: Int64) {
        self.init(timeIntervalSince1970: Double(millisec) / 1000)
    }
    
    init(_ millisec: UInt64) {
        self.init(timeIntervalSince1970: Double(millisec) / 1000)
    }
    
    func toMillisec() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func getMonthFirstDate() -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }
    
    func withFormat(_ dateFormat: DateFormat) -> String {
        return withFormat(dateFormat.rawValue)
    }
    
    func withFormat(_ stringFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = stringFormat
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    func isSameMonth(_ millisec: Int64) -> Bool {
        return Calendar.current.isDate(self,
                                       equalTo: Date(millisec),
                                       toGranularity: .month)
    }
    
    func isSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
}

/// Intentionally used delimiter-separated words to represent
/// more accuratelly the actual format stored in constants.
enum DateFormat: String {
    case DD_MMMM_HH_mm = "dd MMMM HH:mm",
         HH_mm = "HH:mm",
         LLLL_yyyy = "LLLL yyyy",
         DD_MM_yyyy_HH_mm_ss = "dd/MM/yyyy HH:mm:ss",
         HHmmss_dd_MMM_yyyy = "HH:mm:ss, dd MMM yyyy",
         DD_MM_yyyy_HH_mm_ss_file_system_safe = "dd_MM_yyyy_HH_mm_ss"
         
}
