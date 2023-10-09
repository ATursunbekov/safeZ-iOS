//
//  SubscriptionView.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 11/7/23.
//

import SwiftUI
import StoreKit
import FirebaseAuth

struct SubscriptionView: View {
    @EnvironmentObject
    private var entitlementManager: EntitlementManager
    
    @EnvironmentObject
    private var purchaseManager: PurchaseManager
    
    @Environment (\.presentationMode) private var presentationMode
    
    @State private var showCancelPlan = false
    @State private var showChangePlan = false
    @Binding var showTabBar: Bool
    @State private var cancelButton = ""
    @State private var subscriptionType: String = ""
    @State private var purchasedProductIDs = Set<String>()
    @State private var isMonthlyPressed = false
    @State private var isYearlyPressed = false
    let email = Auth.auth().currentUser?.email
    let monthlyProductIdentifier = "app.iguard.monthSub"
    let yearlyProductIdentifier = "app.iguard.yearSub"
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
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
                                    Text("$3.99 per month")
                                } else {
                                    Text("$7.99 per month")
                                }
                            }
                            .foregroundColor(.black)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                            
                            Spacer()
                            
                            if purchaseManager.purchasedProductIDs.contains("app.iguard.monthSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.monthDisSub") {
                                Text("Cancel")
                                    .font(.custom(Gilroy.medium.rawValue, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .frame(width: 119 ,height: 39)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.customGray)
                                    )
                                    .onTapGesture{
                                        showCancelPlan = true
                                        
                                    }
                            } else {
                                Circle()
                                    .stroke(purchaseManager.purchasedProductIDs.contains("app.iguard.monthSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.monthDisSub") || isMonthlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .foregroundColor(Color.customPrimary)
                                            .frame(width: isMonthlyPressed ? 13 : 0, height:  isMonthlyPressed ? 13 : 0)
                                    )
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(purchaseManager.purchasedProductIDs.contains("app.iguard.monthSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.monthDisSub") || isMonthlyPressed ? Color.backgroundCircleSplash : Color.clear)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(purchaseManager.purchasedProductIDs.contains("app.iguard.monthSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.monthDisSub") || isMonthlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 1)
                                .overlay(
                                    Group {
                                        HStack {
                                            Image(SubscriptionImage.filledCheckmark.rawValue)
                                                .resizable()
                                                .foregroundColor(Color.customPrimary)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
                                                .background(Color.white)
                                                .padding(.leading,-10)
                                                .opacity(purchaseManager.purchasedProductIDs.contains("app.iguard.monthSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.monthDisSub") ? 1 : 0)
                                            
                                            Spacer()
                                        }
                                    }
                                )
                        )
                    }
                    .disabled(isMonthlyPressed)
                    
                    Button {
                        isYearlyPressed = true
                        isMonthlyPressed = false
                        if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                            purchaseProduct(at: 3)
                        } else {
                            purchaseProduct(at: 2)
                        }
                    } label: {
                        HStack{
                            VStack(alignment: .leading, spacing: 12){
                                Text("ANNUAL SUBSCRIPTION")
                                    .font(.custom(Gilroy.regular.rawValue, size: 16))
                                if let email = Auth.auth().currentUser?.email, email.contains(".edu") {
                                    Text("$39.99 per year")
                                } else {
                                    Text("$79.99 per year")
                                }
                            }
                            .foregroundColor(.black)
                            .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                            
                            Spacer()
                            
                            if purchaseManager.purchasedProductIDs.contains("app.iguard.yearSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.yearDisSub") {
                                Text("Cancel")
                                    .font(.custom(Gilroy.medium.rawValue, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .frame(width: 119 ,height: 39)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.customGray)
                                    )
                                    .onTapGesture{
                                        showCancelPlan = true
                                        
                                    }
                            } else {
                                Circle()
                                    .stroke(purchaseManager.purchasedProductIDs.contains("app.iguard.yearSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.yearDisSub") || isYearlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .foregroundColor(.customPrimary)
                                            .frame(width: isYearlyPressed ? 13 : 0, height:  isYearlyPressed ? 13 : 0)
                                    )
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(isYearlyPressed ? Color.backgroundCircleSplash : Color.clear)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(purchaseManager.purchasedProductIDs.contains("app.iguard.yearSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.yearDisSub") || isYearlyPressed ? Color.customPrimary : Color.primarySubtle, lineWidth: 1)
                                .overlay(
                                    Group {
                                        HStack {
                                            Image(SubscriptionImage.filledCheckmark.rawValue)
                                                .resizable()
                                                .foregroundColor(Color.customPrimary)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 24, height: 24)
                                                .background(Color.white)
                                                .padding(.leading,-10)
                                                .opacity(purchaseManager.purchasedProductIDs.contains("app.iguard.yearSub") || purchaseManager.purchasedProductIDs.contains("app.iguard.yearDisSub") ? 1 : 0)
                                            
                                            Spacer()
                                        }
                                    }
                                )
                        )
                        
                    }
                    .disabled(isYearlyPressed)

                }
                
                Button {
                    _ = Task<Void, Never> {
                        do {
                            try await AppStore.sync()
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .foregroundColor(.white)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: 58, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.customPrimary)
                        )
                }
            }
            .onAppear {
                purchasedProductIDs = purchaseManager.purchasedProductIDs
            }
            .task {
                _ = Task<Void, Never> {
                    do {
                        try await purchaseManager.loadProducts()
                    } catch {
                        print(error)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }) {
                HStack {
                    Spacer()
                    Text("Change plan")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 58, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.customPrimary)
                )
            }
            .padding(.bottom, 20)
        }
        .overlay(
            VStack(spacing: 4) {
                if purchaseManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1.5)
                        .padding(20)
                        .background(Color.clear)
                        .cornerRadius(16)
                }
            }
        )
        .padding(.top, 36)
        .padding(.horizontal, 20)
        .navigationTitle("My Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(ProfileIcons.arrowBack.rawValue)
                        .imageScale(.large)
                        .frame(width: 35, height: 30, alignment: .leading)
                }
                .frame(width: 35, height: 30, alignment: .leading)
            }
        }
        .overlay(
            VStack(spacing: 4){
                Spacer()
                if showCancelPlan{
                    DropdownMenuCancelPlan(showCancelPlan: $showCancelPlan, showTabBar: $showTabBar).offset(y: showCancelPlan ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                        .ignoresSafeArea()
                }
            }.background(Color(UIColor.black.withAlphaComponent(showCancelPlan || showChangePlan ? 0.5 : 0)).ignoresSafeArea(.all))
                .frame(maxWidth: UIScreen.main.bounds.width)
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
//
//struct SubscriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SubscriptionView()
//            .environmentObject(EntitlementManager())
//            .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
//    }
//    
//}
