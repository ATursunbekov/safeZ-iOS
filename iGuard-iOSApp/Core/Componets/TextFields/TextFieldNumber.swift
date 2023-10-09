//
//  TextFieldNumber.swift
//  iGuard-iOSApp
//
//  Created by Alikhan Tursunbekov on 16/4/23.
//

import SwiftUI

struct TextFieldNumber: View {
    let placeholder: String
    @Binding var number: String
    @State var temp = ""
    @Binding var pastedNumber: Bool
    var showError: Bool
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                if number != "" {
                    Text(placeholder)
                        .foregroundColor(.blackAlpha60)
                        .font(.custom(Gilroy.regular.rawValue, size: 12))
                    Spacer()
                        .frame(height: 4)
                }
                
                HStack(alignment: .center) {
                    Image(ContactImage.usa.rawValue)
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("+1")
                        .frame(alignment: .bottom)
                        .font(.custom(Gilroy.regular.rawValue, size: 16))
                    Divider()
                        .frame(width: 2, height: 18)
                        .overlay(Color.gray.opacity(0.4))
                    if #available(iOS 15, *) {
                        TextField(placeholder, text: $number)
                            .keyboardType(.numberPad)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Spacer()
                                }
                                ToolbarItem(placement: .keyboard) {
                                    Button("Done") {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                            }
                            .frame(alignment: .bottom)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .font(.custom(Gilroy.regular.rawValue, size: 16))
                            .placeholder(when: number.isEmpty) {
                                Text(placeholder)
                                    .font(.custom(Gilroy.regular.rawValue, size: 16))
                                    .foregroundColor(.blackAlpha60)
                            }
                    } else {
                        TextField(placeholder, text: $number)
                            .frame(alignment: .bottom)
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .font(.custom(Gilroy.medium.rawValue, size: 12))
                            .placeholder(when: number.isEmpty) {
                                Text(placeholder)
                                    .foregroundColor(.blackAlpha60)
                                    .font(.custom(Gilroy.regular.rawValue, size: 12))
                            }
                    }
                }
                .onChange(of: number, perform: {val in
                    if pastedNumber {
                        number = formatPhoneNumber(removeSymbolsAndFirstNumber(from: number))
                        temp = number
                        pastedNumber = false
                    } else {
                        if temp < number {
                            if number.count == 3 {
                                number += "-"
                            } else if number.count == 7 {
                                number += "-"
                            }
                        } else if temp > number{
                            if number != "" && !number.last!.isNumber {
                                number = String(number.dropLast(1))
                            }
                        }
                        if number.count > 12 {
                            let index = number.index(number.startIndex, offsetBy: 12)
                            number = String(number[..<index])
                        }
                        temp = number
                    }
                })
            }
            .padding(.vertical, 8)
        }
        .autocapitalization(.none)
        .autocorrectionDisabled(true)
        .foregroundColor(.black)
        .frame(height: 54)
        .padding(.horizontal, 18)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(lineWidth: 1)
                .foregroundColor(showError && number.isEmpty ? Color.red : Color.primarySubtle)
        )
    }
    
    func removeSymbolsAndFirstNumber(from text: String) -> String {
        let symbolSet = CharacterSet(charactersIn: "0123456789").inverted
        
        let textWithoutSymbols = text.components(separatedBy: symbolSet).joined()
        if let range = textWithoutSymbols.rangeOfCharacter(from: .decimalDigits) {
            let firstNumberIndex = textWithoutSymbols.distance(from: textWithoutSymbols.startIndex, to: range.lowerBound)
            return String(textWithoutSymbols.suffix(from: textWithoutSymbols.index(textWithoutSymbols.startIndex, offsetBy: firstNumberIndex + 1)))
        } else {
            return ""
        }
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        
        var formattedNumber = phoneNumber
        let index1 = formattedNumber.index(formattedNumber.startIndex, offsetBy: 3)
        let index2 = formattedNumber.index(formattedNumber.startIndex, offsetBy: 7)
        formattedNumber.insert("-", at: index1)
        formattedNumber.insert("-", at: index2)
        return formattedNumber
    }
}


struct das: PreviewProvider {
    static var previews: some View {
        VStack {
            //TextFieldNumber(placeholder: "Phone Number", number: .constant(""), pastedNumber: false, showError: false)
            ContactTextField(placeholder: "Email Addresses", text: .constant(""), isEditable: true, showError: false, autocapitalizationType: .allCharacters)
        }
    }
}
