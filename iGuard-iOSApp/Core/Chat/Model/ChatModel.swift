//
//  ChatModel.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 2/5/23.
//

import Foundation

struct OpenAICompletionsBody: Encodable {
    let model: String
    let messages: [[String: String]]
    let temperature: Float?
    let max_tokens: Int

    private enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case max_tokens
    }
}

struct OpenAICompletionsResponse: Decodable {
    let id: String?
    let choices: [OpenAICompletionsChoice]
}

struct OpenAICompletionsChoice: Decodable {
    let message: OpenAICompletionsMessage
}

struct OpenAICompletionsMessage: Decodable {
    let role: String
    let content: String
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let content: String
    let dateCreated: Date
    let senderID: String
    let isInitialMessage: Bool
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: dateCreated)
    }
}

extension ChatMessage: Equatable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}


enum MessageSender: Codable {
    case user
    case assistan
}
