//
//  ExtensionDate.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 19/6/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Algorithms

class DateHelper {
    
    static func shouldShowDateSeparator(for message: ChatMessage, previousMessage: ChatMessage?) -> Bool {
        guard let previousMessage = previousMessage else {
            return true
        }

        let currentComponents = Calendar.current.dateComponents([.day], from: message.dateCreated)
        let previousComponents = Calendar.current.dateComponents([.day], from: previousMessage.dateCreated)

        return currentComponents.day != previousComponents.day
    }

    static func dateSeparator(date: Date) -> String {
        return date.formattedDate()
    }
    func formatDate(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM" 
        
        let date = timestamp.dateValue()
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date)
        return components1 == components2
    }

    func formattedDate() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let dateString: String
        if calendar.isDateInToday(self) {
            dateString = "Today"
        } else if calendar.isDateInYesterday(self) {
            dateString = "Yesterday"
        } else {
            dateString = formatter.string(from: self)
        }

        return dateString
    }
}

