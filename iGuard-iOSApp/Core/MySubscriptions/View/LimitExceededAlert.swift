//
//  LimitExceededAlert.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 12/6/23.
//

import SwiftUI
import FirebaseAuth
import StoreKit
import Combine

struct LimitExceededAlert: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var showWebTOU = false
    @State private var showWebPP = false
    @State private var isMonthlyPressed = false
    @State private var isYearlyPressed = false
    let monthlyProductIdentifier = "app.iguard.monthSub"
    let yearlyProductIdentifier = "app.iguard.yearSub"
    let email = Auth.auth().currentUser?.email
    @State private var purchasedProductCancellable: AnyCancellable?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView{
                HStack() {
                    Spacer()
                    VStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(SubscriptionImage.closeButtonSub.rawValue)
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                }
                VStack(spacing: 10) {
                    Spacer()
                    HStack(spacing: 9) {
                        Text("Upgrade to SafeZ")
                            .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                        ZStack {
                            Rectangle()
                                .foregroundColor(.primarySubtle)
                                .cornerRadius(8)
                            Text("PRO")
                                .font(.custom(Gilroy.semiBold.rawValue, size: 24))
                                .foregroundColor(.white)
                        }
                        .frame(width: 68, height: 49)
                    }
                    .padding(.bottom, 33)
                    VStack(alignment: .center, spacing: 24){
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Unlimited for all SafeZ Users:")
                                .font(.custom(Gilroy.regular.rawValue, size: 14))
                                .foregroundColor(Color.secondaryText)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.backgroundCircleSplash)
                                .cornerRadius(16)
                            HStack(alignment: .center, spacing: 10) {
                                Image(SubscriptionImage.checkmarkImage.rawValue)
                                    .frame(width: 24, height: 24)
                                Text("Assignment of up to 3 Emergency Contacts")
                                    .font(.custom(Gilroy.medium.rawValue, size: 14))
                            }
                            HStack(alignment: .center, spacing: 10) {
                                Image(SubscriptionImage.checkmarkImage.rawValue)
                                    .frame(width: 24, height: 24)
                                Text("Three inquiries within SafeZ AI LLM Chatbot")
                                    .font(.custom(Gilroy.medium.rawValue, size: 14))
                            }
                        }
                        .padding(16)
                        .frame(width: 370, alignment: .center)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.46, green: 0.45, blue: 0.97).opacity(0.27), radius: 15, x: 13, y: 16)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Premium Features for SafeZ Plus:")
                                .font(.custom(Gilroy.regular.rawValue, size: 14))
                                .foregroundColor(Color.secondaryText)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.backgroundLightPurple)
                                .cornerRadius(16)
                            HStack(alignment: .center, spacing: 10) {
                                Image(SubscriptionImage.checkmarkImage.rawValue)
                                    .frame(width: 24, height: 24)
                                Text("Unlimited Assignment of Emergency Contacts")
                                    .font(.custom(Gilroy.medium.rawValue, size: 14))
                            }
                            HStack(alignment: .center, spacing: 10) {
                                Image(SubscriptionImage.checkmarkImage.rawValue)
                                    .frame(width: 24, height: 24)
                                Text("Unlimited inquiries within SafeZ AI LLM Chatbot")
                                    .font(.custom(Gilroy.medium.rawValue, size: 14))
                            }
                        }
                        .padding(16)
                        .frame(width: 370, alignment: .center)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.46, green: 0.45, blue: 0.97).opacity(0.27), radius: 15, x: 13, y: 16)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 23) {
                        Button {
                            isMonthlyPressed = true
                            isYearlyPressed = false
                            if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                                purchaseProduct(at: 1)
                            } else {
                                purchaseProduct(at: 0)
                            }
                        } label: {
                            HStack{
                                VStack(alignment: .leading, spacing: 12){
                                    Text("MONTHLY SUBSCRIPTION")
                                        .font(.custom(Gilroy.regular.rawValue, size: 16))
                                    if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                                        Text("$3.99/month")
                                    } else {
                                        Text("$7.99/month")
                                    }
                                    Text("includes full access to SafeZ's premium features")
                                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                                }
                                .foregroundColor(.black)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                Spacer()
                                Circle()
                                    .stroke(isMonthlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .foregroundColor(Color.customPrimary)
                                            .frame(width: isMonthlyPressed ? 13 : 0, height:  isMonthlyPressed ? 13 : 0)
                                    )
                                    .padding(.trailing, 8)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(isMonthlyPressed ? Color.backgroundCircleSplash : Color.clear)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isMonthlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 1)
                            )
                            
                        }
                        .disabled(isMonthlyPressed)
                        
                        Button {
                            isYearlyPressed = true
                            isMonthlyPressed = false
                            if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                                purchaseProduct(at: 3)
                            } else {
                                purchaseProduct(at: 4)
                            }
                        } label: {
                            HStack{
                                VStack(alignment: .leading, spacing: 12){
                                    Text("ANNUAL SUBSCRIPTION")
                                        .font(.custom(Gilroy.regular.rawValue, size: 16))
                                    if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                                        Text("$39.99/month")
                                    } else {
                                        Text("$79.99 per year")
                                    }
                                    Text("includes full access to SafeZ's premium features")
                                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                                }
                                .foregroundColor(.black)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                Spacer()
                                Circle()
                                    .stroke(isYearlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .foregroundColor(.customPrimary)
                                            .frame(width: isYearlyPressed ? 13 : 0, height:  isYearlyPressed ? 13 : 0)
                                    )
                                    .padding(.trailing, 8)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(isYearlyPressed ? Color.backgroundCircleSplash : Color.clear)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isYearlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 1)
                            )
                            
                        }
                        .disabled(isYearlyPressed)
                        
                        Text("""
                Payment will be charged to the iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period, and the cost of the renewal will be identified. Subscriptions may be managed by the user, and auto-renewal may be turned off by going to the user's Account Settings after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.
                """)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                        .foregroundColor(Color.secondaryText)
                        VStack(alignment: .center, spacing: 18){
                            Button {
                                showWebTOU = true
                                print("tou")
                            } label: {
                                Text("SafeZ Terms of Use")
                                    .font(.custom(Gilroy.regular.rawValue, size: 14))
                                    .foregroundColor(Color.black)
                            }
                            Button {
                                showWebPP = true
                                print("pp")
                            } label: {
                                Text("SafeZ Privacy Policy")
                                    .font(.custom(Gilroy.regular.rawValue, size: 14))
                                    .foregroundColor(Color.black)
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 22)
            }
            .task {
                purchasedProductCancellable = purchaseManager.$purchasedProduct
                    .sink { purchased in
                        if purchased {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                
                do {
                    try await purchaseManager.loadProducts()
                } catch {
                    print(error)
                }
            }
            
        }
        .onAppear {
            print(Auth.auth().currentUser?.email ?? "no email")
            print("onAppear triggered")
            print("purchasedProduct: \(purchaseManager.purchasedProduct)")
            
            if purchaseManager.purchasedProduct == true {
                print("Attempting to dismiss the view")
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        .fullScreenCover(isPresented: $showWebTOU) {
            WebViewWrapper(showWebView: $showWebTOU, urlString: "https://www.iguard.app/termsandconditions")
        }
        .fullScreenCover(isPresented: $showWebPP) {
            WebViewWrapper(showWebView: $showWebPP, urlString: "https://www.iguard.app/privacypolicy")
        }
        .background(
            ShapeCircle(arcHeight: 150, arcPosition: .down)
                .fill(Color.backgroundLightPurple)
                .frame(width: UIScreen.main.bounds.width * 1, height: UIScreen.main.bounds.height * 1)
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.horizontal)
            , alignment: .top
        )
    }
    
    func purchaseProduct(at index: Int) {
        _ = Task<Void, Never> {
            do {
                if index >= 0 && index < purchaseManager.products.count {
                    try await purchaseManager.purchase(purchaseManager.products[index])
                } else {
                    // handle index out of bounds error
                }
            } catch {
                print(error)
            }
        }
    }
}

struct LimitExceededAlert_Previews: PreviewProvider {
    static var previews: some View {
        LimitExceededAlert()
            .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
    }
}
