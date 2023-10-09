//
//  DropdownMenuCancelPlan.swift
//  iGuard-iOSApp
//
//  Created by Nurzhan Ababakirov on 11/7/23.
//

import SwiftUI

struct DropdownMenuCancelPlan: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showCancelPlan: Bool
    @Binding var showTabBar: Bool
    @State private var offset = CGSize.zero
    
    var body: some View {
        VStack(alignment: .center, spacing: 14){
            Capsule()
                .fill(Color.colorDate)
                .frame(width: 40, height: 2)
                .offset(y: -10)
            HStack{
                VStack(alignment: .center, spacing: 24){
                    Text("How do I cancel my plan? ")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 22))
                        .frame(maxWidth: .infinity, minHeight: 26, maxHeight: 26, alignment: .leading )
                    Text("""
 You can cancel your SafeZ subscription at any time. When you cancel your Pro subscription, you’ll still have access to Pro content for the period you have already paid for and your subscription will not automatically renew for the next period.
 Please, check out the link below to cancel your subscription:
 """)
                    .lineSpacing(10)
                    .font(.custom(Gilroy.regular.rawValue, size: 16))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text("https://support.apple.com/en-us/")
                        .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                        .frame(maxWidth: .infinity, minHeight: 24, maxHeight: 24, alignment: .topLeading)
                }
                .padding(0)
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .top)
            }
        }
        .padding(.top, 30)
        .padding(.horizontal,16)
        .padding(.bottom,(UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30)
        .background(Color.white)
        .cornerRadius(30, corners: [.topLeft, .topRight])
        .frame(maxWidth: UIScreen.main.bounds.width)
        .offset(y: max(offset.height, 0))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                        if offset.height > 80 {
                            showCancelPlan = false
                            showTabBar = true
                        } else {
                            withAnimation {
                                offset = .zero
                            }
                        }
                }
        )
    }
}
