//
//  ChatView.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 17/4/23.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
    @StateObject var chatViewModel: ChatViewModel = ChatViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Binding var showBar : Bool
    let currentUser = Auth.auth().currentUser?.uid
    
    let initialMessage: String = """
Hello! How can I assist you today?
You can select any of the following items:

"""
    
    init(showBar: Binding<Bool>) {
        _showBar = showBar
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: Gilroy.semiBold.rawValue, size: 18)!]
    }

    var body: some View {
        NavigationView{
            VStack(){
                ScrollViewReader { scrollView in
                    ScrollView(showsIndicators: false) {
                        VStack {
                            initialMessageView(message: initialMessage)
                            
                            ForEach(chatViewModel.chatMessages.indices, id: \.self) { index in
                                let message = chatViewModel.chatMessages[index]
                                let previousMessage = index > 0 ? chatViewModel.chatMessages[index - 1] : nil
                                
                                VStack {
                                    if DateHelper.shouldShowDateSeparator(for: message, previousMessage: previousMessage) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.backgroundLightPurple)
                                            .overlay(
                                                Text(DateHelper.dateSeparator(date: message.dateCreated))
                                                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                                                    .foregroundColor(Color.secondaryText)
                                                    .lineLimit(nil)
                                            )
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .frame(height: 40)
                                            .frame(width: 120)
                                    }
                                    messageView(message: message, index: index)
                                }
                                .id(message.id)
                            }
                            
                            if chatViewModel.isTyping {
                                HStack {
                                    Image(SplashImage.logoForSplash.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                        .padding(.trailing, 8)
                                    
                                    Text("Typing...")
                                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                                        .foregroundColor(.gray)
                                        .baselineOffset(3)
                                        .padding(.trailing, 8)
                                        .padding(.top, 11)
                                        .padding(.bottom, 4)
                                }
                                .id("typingIndicator")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.clear)
                                .onAppear {
                                    scrollView.scrollTo("typingIndicator", anchor: .bottom)
                                }
                            }
                        }
                        
                        .onChange(of: chatViewModel.chatMessages) { _ in
                            if chatViewModel.chatMessages.last?.id == chatViewModel.chatMessages.first?.id {
                                scrollView.scrollTo("typingIndicator", anchor: .bottom)
                            } else {
                                scrollView.scrollTo(chatViewModel.chatMessages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                Divider()
                    .frame(width: UIScreen.main.bounds.width, height: 1)
                Spacer()
                HStack {
                    TextField("Ask a question...", text: $chatViewModel.messageText)
                        .padding(.leading)
                        .font(.custom(Gilroy.regular.rawValue, size: 16))
                        .padding(.trailing, 0)
                        .dismissKeyboardOnDrag()
                    
                    Button(action: {
                        chatViewModel.sendMessageBut()
                    }) {
                        Image(ChatImage.sendMessage.rawValue)
                            .foregroundColor(Color.customPrimary)
                    }
                    .frame(width: 40, height: 20)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(chatViewModel.isGeneratingResponse)
                }
                .padding()
                .background(Color.backgroundCircleSplash)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.backgroundStrokeSend, lineWidth: 2)
                )
                .padding(.top, 12)
                .padding(.trailing, 4.0)
                .padding(.leading, 4.0)
                
                Spacer()
            }
            .padding()
            .padding(.top, -20)
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            
            .onAppear{
                chatViewModel.loadMessagesFromFirestore()
            }
        }
        .fullScreenCover(isPresented: $chatViewModel.showLimitExceededAlert) {
            LimitExceededAlert()
                .environmentObject(entitlementManager)
                .environmentObject(purchaseManager)
        }
    }

    func messageView(message: ChatMessage, index: Int) -> some View {
        let swipeGesture = DragGesture(minimumDistance: 30)
            .onChanged { gesture in
                if gesture.translation.width < 0 && message.senderID == Auth.auth().currentUser?.uid {
                    chatViewModel.swipedMessageIndex = index
                } else if gesture.translation.width < 0 && message.senderID == "assistant" {
                    chatViewModel.swipedMessageIndex = index
                }
            }
        
            .onEnded { gesture in
                if gesture.translation.width > 0 {
                    chatViewModel.swipedMessageIndex = nil
                }
            }
        
        return HStack {
            VStack(alignment: message.senderID == currentUser ? .trailing : .leading, spacing: 4) {
                HStack{
                    VStack(alignment: message.senderID == currentUser ? .trailing : .leading, spacing: 4) {
                        Text(message.content)
                            .font(.custom(Gilroy.regular.rawValue, size: 14))
                            .foregroundColor(message.senderID == currentUser ? .colorDate : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        
                        Text(message.formattedDate)
                            .font(.custom(Gilroy.lightItalic.rawValue, size: 10))
                            .foregroundColor(message.senderID == currentUser ? .colorDate : .white)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 16)
                    }
                    .background(message.senderID == currentUser ? Color.backgroundCircleSplash : .backkgroundForMessage)
                    .cornerRadius(12, corners: message.senderID == currentUser ? [.topRight,.topLeft,.bottomLeft] : [.topRight,.topLeft,.bottomRight])
                    .contentShape(Rectangle())
                    .animation(.easeOut(duration: 0.3))
                    
                    if chatViewModel.swipedMessageIndex == index && (message.senderID == currentUser || message.senderID == "assistant") {
                        
                        GeometryReader { geometry in
                            Spacer()
                            deleteButton(index: index, messageHeight: geometry.size.height)
                        }
                        .frame(width: 61)
                        .transition(.move(edge: .trailing))
                    }
                }
                
                HStack {
                    if message.senderID == "assistant" {
                        Image(SplashImage.logoForSplash.rawValue)
                            .resizable()
                            .frame(width: 32,height: 32)
                            .padding(.trailing, 12)
                            .padding(.top, 11)
                            .padding(.bottom, 4)
                            .alignmentGuide(.leading) { _ in
                                0
                            }
                        Spacer()
                    } else if message.senderID == currentUser {
                        Spacer()
                    }
                }
            }
        }
        .padding(.trailing, message.senderID == "assistant" ? 40 : 0)
        .padding(.bottom, message.senderID == "assistant" ? 8 : 8)
        .gesture(swipeGesture)
    }
    
    @ViewBuilder
        func initialMessageView(message: String) -> some View {

            HStack {
                VStack(alignment: .leading) {
                    Text(initialMessage)
                        .font(.custom(Gilroy.regular.rawValue, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                    
                    Text(locationManager.firstMessage)
                        .underline()
                        .font(.custom(Gilroy.regular.rawValue, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            chatViewModel.messageText = ""
                            chatViewModel.messageText = locationManager.firstMessage.replacingOccurrences(of: "1.", with: "")
                        }
                    
                    Text(locationManager.secondMessage)
                        .underline()
                        .font(.custom(Gilroy.regular.rawValue, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .onTapGesture {
                            chatViewModel.messageText = ""
                            chatViewModel.messageText = locationManager.secondMessage.replacingOccurrences(of: "2.", with: "")
                        }
                    
                    
                    Text(getTime())
                        .font(.custom(Gilroy.lightItalic.rawValue, size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                }.padding(.vertical, 8)
            }
            .background(Color.backkgroundForMessage)
            .cornerRadius(12, corners: [.topRight, .topLeft, .bottomRight])
            .contentShape(Rectangle())
            .padding(.top, 16)
            .padding(.trailing, 40)
        }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    @ViewBuilder
    func deleteButton(index: Int, messageHeight: CGFloat) -> some View {
        Button(action: {
            chatViewModel.deleteMessageFromFirestore(index: index)
            chatViewModel.swipedMessageIndex = nil
            }){
            ZStack {
                Image(ChatImage.deleteButton.rawValue)
                    .foregroundColor(.red)
                    .padding(10)
                    .frame(width: 24, height: 24)
            }
            .frame(width: 61, height: messageHeight)
            .background(Color.backgroundForDelete)
            .contentShape(Rectangle())
            .cornerRadius(12, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        }
        .background(Color.white)
        .padding(.trailing, 8)
        .animation(.easeOut(duration: 0.3))
    }
}

struct ChatView_Previews: PreviewProvider {
    @State static var show = true
    static var previews: some View {
        ChatView(showBar: $show)
    }
}
