//
//  ChatViewModel.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 2/5/23.
//

import Foundation
import Alamofire
import Combine
import FirebaseAuth
import Firebase
import FirebaseFirestore
import SwiftUI
    
class ChatViewModel: ObservableObject {
    @ObservedObject private var entitlementManager = EntitlementManager()
    @Published var chatMessages: [ChatMessage] = []
    @Published var isChatEmpty = false
    @Published var scrollToBottom = false
    @Published var isTyping: Bool = false
    @Published var messageText: String = ""
    @Published var isMessageSent = false
    @Published public var swipedMessageIndex: Int? = nil
    @Published public var isSwipeBack: Bool = false
    @Published var isGeneratingResponse = false
    @Published public var lastQuestionDate: Date?
    @Published var isFieldEmpty: Bool = false
    @Published public var showLimitExceededAlert = false
    let isTrialActive = UserDefaults.standard.bool(forKey: "isTrialActive")
    let expirationDate = UserDefaults.standard.object(forKey: "trialExpirationDate") as? Date
    let currentUser = Auth.auth().currentUser?.uid
    let maxQuestionsPerDay = 3
    let baseURL = "https://api.openai.com"
    
    var currentUserID: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        checkQuestionLimit()
    }
    
    func checkQuestionLimit() {
        let currentDate = Date()
        let userDefaults = UserDefaults.standard
        let lastQuestionDate = userDefaults.object(forKey: "lastQuestionDate") as? Date

        if let lastQuestionDate = lastQuestionDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: lastQuestionDate, to: currentDate)

            if let daysPassed = components.day, daysPassed >= 1 {
                userDefaults.set(0, forKey: "questionCount")
            }
        } else {
            userDefaults.set(0, forKey: "questionCount")
        }

        let questionCount = userDefaults.integer(forKey: "questionCount")
        userDefaults.set(questionCount, forKey: "questionCount")

        userDefaults.set(questionCount, forKey: "questionCount")
        userDefaults.set(currentDate, forKey: "lastQuestionDate")
    }
    
    func saveMessageToFirestore(message: ChatMessage) {
       
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "id": message.id,
            "content": message.content,
            "dateCreated": message.dateCreated,
            "senderID": message.senderID]
        db.collection("messages")
            .document(currentUser ?? "userID")
            .collection("messages")
            .document(message.id)
            .setData(data) { error in
                if let error = error {
                    print("Error writing message document: \(error)")
                }
            }
    }
    
    func loadMessagesFromFirestore() {

        let db = Firestore.firestore()

        chatMessages = []
        db.collection("messages")
            .document(currentUser ?? "userID")
            .collection("messages")
            .order(by: "dateCreated", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error reading message document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self?.chatMessages.removeAll()
                self?.chatMessages = documents.compactMap { queryDocumentSnapshot -> ChatMessage? in
                    let data = queryDocumentSnapshot.data()
                    guard let id = data["id"] as? String,
                          let content = data["content"] as? String,
                          let dateCreated = (data["dateCreated"] as? Timestamp)?.dateValue(),
                          let senderID = data["senderID"] as? String
                    else { return nil }

                    let message = ChatMessage(id: id, content: content, dateCreated: dateCreated, senderID: senderID, isInitialMessage: false)
                    return message
                }

                self?.isChatEmpty = self?.chatMessages.isEmpty ?? false
                self?.scrollToBottom = true
            }
    }
    
    func incrementQuestionCount() {
        let userDefaults = UserDefaults.standard
        let questionCount = userDefaults.integer(forKey: "questionCount") + 1
        userDefaults.set(questionCount, forKey: "questionCount")
        userDefaults.set(Date(), forKey: "lastQuestionDate")
    }
    
    func deleteMessageFromFirestore(index: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard index >= 0 && index < chatMessages.count else {
            return
        }
        
        let message = chatMessages[index]
        
        let db = Firestore.firestore()
        let messageRef = db.collection("messages")
            .document(userID)
            .collection("messages")
            .document(message.id)
        
        messageRef.delete() { error in
            if let error = error {
                print("Error deleting message document: \(error)")
            } else {
                self.chatMessages.removeAll(keepingCapacity: true)
                self.loadMessagesFromFirestore()
            }
        }
    }
    
    func sendMessageBut() {
        isTyping = true
        scrollToBottom = true
        isGeneratingResponse = true
        
        checkQuestionLimit()
        
        let userDefaults = UserDefaults.standard
        let questionCount = userDefaults.integer(forKey: "questionCount")
        
        if !isFieldEmpty {
            isMessageSent = false
            isTyping = false
            isGeneratingResponse = false
        }
        
        if entitlementManager.hasPro || isTrialActive || questionCount < maxQuestionsPerDay {
            guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            
            let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), senderID: currentUser ?? "user", isInitialMessage: false)
            
            if chatMessages.contains(where: { $0.id == myMessage.id }) {
                return
            }
            
            chatMessages.append(myMessage)
            sendMessage(message: messageText)
                .sink { completion in
                    self.isTyping = false
                    self.isGeneratingResponse = false
                } receiveValue: { response in
                    guard let textResponse = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else { return }
                    let gptMessage = ChatMessage(id: response.id!, content: textResponse, dateCreated: Date(), senderID: "assistant", isInitialMessage: false)
                    self.chatMessages.append(gptMessage)
                    self.saveMessageToFirestore(message: myMessage)
                    self.saveMessageToFirestore(message: gptMessage)
                    self.isGeneratingResponse = false
                }
                .store(in: &cancellables)
            
            incrementQuestionCount()
            messageText = ""
        } else {
            showLimitExceededAlert = true
            isMessageSent = false
            isTyping = false
            isGeneratingResponse = false
        }
    }


    func sendMessage(message: String) -> AnyPublisher<OpenAICompletionsResponse, Error> {
        isGeneratingResponse = true
        isTyping = true
        
        var chatMessages: [[String: String]] = []
        
        for chatMessage in self.chatMessages {
            let role = chatMessage.senderID == currentUser ? "user" : "assistant"
            let content = chatMessage.content
            let message = ["role": role, "content": content]
            chatMessages.append(message)
        }
        
        chatMessages.append(["role": "user", "content": message])
        
        let parameters = OpenAICompletionsBody(
            model: "gpt-3.5-turbo",
            messages: chatMessages,
            temperature: nil,
            max_tokens: 256
                
        )
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIAPIKey)"
        ]
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            AF.request(self.baseURL + "/v1/chat/completions", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
                .validate()
                .responseDecodable(of: OpenAICompletionsResponse.self) { response in
                    
                    self.isGeneratingResponse = false
                    self.isTyping = false
                    
                    switch response.result {
                    case .success(let result):
                        promise(.success(result))
                        
                    case .failure(let error):

                        if let data = response.data, let errorMessage = String(data: data, encoding: .utf8) {
                            print("Error message: \(errorMessage)")
                        }
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
