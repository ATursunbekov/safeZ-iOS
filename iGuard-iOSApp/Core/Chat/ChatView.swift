//
//  ChatView.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 17/4/23.
//

import SwiftUI

struct ChatView: View {
    @State var chatMessages: [ChatMessage] = ChatMessage.sampleMessage
    @State var messageText: String = ""
    
    var body: some View {
        VStack{
            Text("Chat")
                .font(.custom("Gilory-Medium", size: 20))
                .bold()
                .padding()
            ScrollView{
                LazyVStack{
                    ForEach(chatMessages, id: \.id) { message in
                        messageView(message: message)
                    }
                }
            }
            Divider()
            HStack{
                TextField("Ask a question...", text: $messageText)
                    .padding()
                    .background(Color(hex: "#F8FCEC"))
                    .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#AFB2B84D"), lineWidth: 2)
                        )
                    .overlay(Image(systemName: "paperplane.fill")
                        .foregroundColor(Color(hex: "#51245F"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8))
                    .cornerRadius(12)
                
            }
        }
        .padding()
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack{
            if message.sender == .me { Spacer() }
            VStack(alignment: message.sender == .me ? .trailing : .leading) {
                Text(message.content)
                    .foregroundColor(message.sender == .me ? .black : .white)
                    .padding()
                    .background(message.sender == .me ? Color(hex: "#F8FCEC") : Color(hex: "#444653"))
                    .cornerRadius(16)
                
                HStack {
                    if message.sender == .gpt {
                        Image("icon_pantera")
                            .font(.custom("Gilroy-Regular", size: 14))
                            .padding(.trailing, 8)
                        
                        Text(message.formattedDate)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                    else {
                        Spacer()
                        
                        Text(message.formattedDate)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                    }
                }
            }
            if message.sender == .gpt { Spacer() }
        }
    }



}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

struct ChatMessage {
    let id: String
    let content: String
    let creationDate: Date
    let sender: MessageSender
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: creationDate)
    }
}


enum MessageSender{
    case me
    case gpt
}

extension ChatMessage{
    static let sampleMessage = [
        ChatMessage(id: UUID().uuidString, content: "Hello", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint?", creationDate: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "What to do if police stopped me?", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "If you are stopped by the police, it’s important to remain calm and follow their instructions. Here are some general guidelines on what to do", creationDate: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "This is a test message 👋", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "This is a test message 😄", creationDate: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "Hello", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint?", creationDate: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "What to do if police stopped me?", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "If you are stopped by the police, it’s important to remain calm and follow their instructions. Here are some general guidelines on what to do", creationDate: Date(), sender: .gpt),
        ChatMessage(id: UUID().uuidString, content: "This is a test message 👋", creationDate: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "This is a test message 😄", creationDate: Date(), sender: .gpt)
        ]
}
