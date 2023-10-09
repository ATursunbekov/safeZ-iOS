//
//  StoreKitViewModel.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 13/7/23.
//

import StoreKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class StoreKitViewModel: NSObject, ObservableObject {
    @Published var products: [SKProduct] = []
    @Published var isSubscribed: Bool = false
    @Published var isPurchased: Bool = false
    
    @EnvironmentObject
    private var entitlementManager: EntitlementManager

    @EnvironmentObject
    private var purchaseManager: PurchaseManager
    
    let currentUser = Auth.auth().currentUser?.uid
    let subscriptionDataManager = SubscriptionDataManager()
    
    let monthlyProductIdentifier = "app.iguard.monthSub"
    let yearlyProductIdentifier = "app.iguard.yearSub"
    
    private var productsRequest: SKProductsRequest?
    private var subscriptionEndDate: Date?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        subscriptionDataManager.fetchSubscriptionStatus { [weak self] isSubscribed, startDate, endDate, subscriptionType in
            DispatchQueue.main.async {
                self?.isSubscribed = isSubscribed
                self?.subscriptionEndDate = endDate
            }
        }
        
        checkSubscriptionStatus()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func showLimitExceededAlert() {
        let limitExceededAlert = LimitExceededAlert()
        
        let hostingController = UIHostingController(rootView: limitExceededAlert)
        hostingController.modalPresentationStyle = .fullScreen
        
        if let currentViewController = UIApplication.shared.windows.first?.rootViewController {
            currentViewController.present(hostingController, animated: true, completion: nil)
        }
    }
    
    func getProducts(productIdentifiers: Set<String>) {
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        isPurchased = true
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func cancelPurchase() {
        guard let currentSubscription = SKPaymentQueue.default().transactions.first(where: { $0.transactionState == .purchased }) else {
            return
        }
        
        SKPaymentQueue.default().finishTransaction(currentSubscription)
        
        subscriptionDataManager.saveSubscriptionStatus(
            isSubscribed: false,
            startDate: nil,
            endDate: nil,
            subscriptionType: nil
        )
    }
    
    private func checkSubscriptionStatus() {
        if let endDate = subscriptionEndDate, endDate < Date() {
            isSubscribed = false
            subscriptionDataManager.saveSubscriptionStatus(
                isSubscribed: false,
                startDate: nil,
                endDate: nil,
                subscriptionType: nil
            )
        }
    }
}

extension StoreKitViewModel: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // Handle error during products request
    }
}

extension StoreKitViewModel: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("purchsing")
                break
            case .purchased:
                completeTransaction(transaction)
                isSubscribed = true
                
                var subscriptionType: String?
                if transaction.payment.productIdentifier == monthlyProductIdentifier {
                    subscriptionType = "monthly"
                } else if transaction.payment.productIdentifier == yearlyProductIdentifier {
                    subscriptionType = "yearly"
                }
                
                let startDate = transaction.transactionDate
                let endDate = transaction.transactionDate?.addingTimeInterval(transaction.payment.productIdentifier == monthlyProductIdentifier ? 2592000 : 31536000)
                
                subscriptionDataManager.saveSubscriptionStatus(
                    isSubscribed: true,
                    startDate: startDate,
                    endDate: endDate,
                    subscriptionType: subscriptionType
                )
                
                subscriptionEndDate = endDate
                checkSubscriptionStatus()
                
                break
            case .restored:
                completeTransaction(transaction)
                isSubscribed = true
                
                let startDate: Date? = nil
                let endDate: Date? = nil
                let subscriptionType: String? = nil
                
                subscriptionDataManager.saveSubscriptionStatus(
                    isSubscribed: true,
                    startDate: startDate,
                    endDate: endDate,
                    subscriptionType: subscriptionType
                )
                break
            case .failed:
                failedTransaction(transaction)
                print("failed")
                break
            case .deferred:
                isSubscribed = false
                subscriptionDataManager.saveSubscriptionStatus(
                    isSubscribed: false,
                    startDate: nil,
                    endDate: nil,
                    subscriptionType: nil
                )
                
                showDeferredAlert()
                break
            @unknown default:
                break
            }
        }
    }
    
    private func showDeferredAlert() {
        let alertController = UIAlertController(
            title: "Subscription Pending",
            message: "Your subscription is pending approval. Please wait for the approval process to complete.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let currentViewController = UIApplication.shared.windows.first?.rootViewController {
            currentViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
            print(error)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
