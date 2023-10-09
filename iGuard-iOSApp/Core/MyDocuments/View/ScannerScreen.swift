import SwiftUI
import AVFoundation

struct ScannerScreen: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    let stateDictionary = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "FL": "Florida",
        "GA": "Georgia",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PA": "Pennsylvania",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
    @Binding var isPresented : Bool
    @Binding var selectedScanning: String
    
    @State private var scannedValue: String = ""
    @State private var isScanning: Bool = true
    @State var selectedClass = "B"
    @State var selectedState = "Alabama"
    @State var showErrorName = false
    @State var showErrorLastName = false
    @State var showErrorDateOfBirth = false
    @State var showErrorIssueDate = false
    @State var showErrorExpirationDate = false
    @State var showErrorDocumentID = false
    @State var showErrorState = false
    @State var showSaveMenu = false
    @StateObject private var viewModel: DocumentsViewModel = DocumentsViewModel()
    
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View {
            VStack {
                if isScanning {
                    ZStack(alignment: .center) {
                        ScannerView { scannedValue in
                            self.scannedValue = scannedValue
                            self.isScanning = false
                        }
                        .scaledToFill()
                        .ignoresSafeArea(edges: [.leading, .bottom])
                        .offset(x: -5)
                        VStack(spacing: 178) {
                            HStack(spacing: 290) {
                                Image(DocumentsImage.scannerAngle.rawValue)
                                    .frame(width: 22.74194, height: 22.74194)
                                Image(DocumentsImage.scannerAngle.rawValue)
                                    .frame(width: 22.74194, height: 22.74194)
                                    .rotationEffect(Angle(degrees: 90))
                            }
                            HStack(spacing: 290) {
                                Image(DocumentsImage.scannerAngle.rawValue)
                                    .frame(width: 22.74194, height: 22.74194)
                                    .rotationEffect(Angle(degrees: 270))
                                Image(DocumentsImage.scannerAngle.rawValue)
                                    .frame(width: 22.74194, height: 22.74194)
                                    .rotationEffect(Angle(degrees: 180))
                            }
                        }
                        .padding(.horizontal, 37)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ScannerTextField(placeholder: "First Name", text: $viewModel.dataArray[0], showError: $showErrorName)
                            ScannerTextField(placeholder: "Last Name", text: $viewModel.dataArray[1], showError: $showErrorLastName)
                            ScannerDateTextField(placeholder: "Date of Birth", text: $viewModel.dataArray[3], showError: $showErrorDateOfBirth)
                            ScannerDateTextField(placeholder: "Issue Date", text: $viewModel.dataArray[4], showError: $showErrorIssueDate)
                            ScannerDateTextField(placeholder: "Expiration Date", text: $viewModel.dataArray[5], showError: $showErrorExpirationDate)
                            ScannerTextField(placeholder: "Document ID", text: $viewModel.dataArray[6], showError: $showErrorDocumentID)
                            ScannerDropdown(placeholder: "State", selectedObject: $selectedState, isState: true)
                            if selectedScanning != "ID" {
                                ScannerDropdown(placeholder: "Driving Privileges", selectedObject: $selectedClass, isState: false)
                            }
                        }
                        .padding()
                        Spacer()
                        Button {
                            if viewModel.dataArray[0].isEmpty {
                                showErrorName = true
                            } else if viewModel.dataArray[1].isEmpty{
                                showErrorLastName = true
                            } else if viewModel.dataArray[3].isEmpty || viewModel.dataArray[3].count != 10{
                                showErrorDateOfBirth = true
                            } else if viewModel.dataArray[4].isEmpty || viewModel.dataArray[4].count != 10{
                                showErrorIssueDate = true
                            } else if viewModel.dataArray[5].isEmpty || viewModel.dataArray[5].count != 10{
                                showErrorExpirationDate = true
                            } else if viewModel.dataArray[6].isEmpty{
                                showErrorDocumentID = true
                            } else if viewModel.dataArray[7].isEmpty{
                                showErrorState = true
                            } else {
                                showSaveMenu = true
                            }
                        } label: {
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                                .background(Color.customPrimary)
                                .cornerRadius(18)
                        }
                        .padding(.horizontal, 22)
                    }
                    .overlay(
                        VStack {
                            if showSaveMenu {
                                Spacer()
                                DropdownMenuScannedInfo(showSaveMenu: $showSaveMenu, selectedState: selectedState, selectedClass: selectedClass, isPresented: $isPresented)
                                    .offset(y: showSaveMenu ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                                    .animation(.easeInOut(duration: 0.1))
                                    .transition(.move(edge: .bottom))
                                    .frame(maxWidth: UIScreen.main.bounds.width)
                                    .environmentObject(viewModel)
                            }
                        }
                            .background(Color(UIColor.black.withAlphaComponent(showSaveMenu ? 0.5 : 0)).ignoresSafeArea())
                    )
                }
            }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(isScanning ? "Scan \(selectedScanning == "ID" ? "ID" : "Driver license")" : "Verification")
        .navigationBarTitleDisplayMode(.inline)
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
        .onChange(of: isScanning) { newValue in
            if !isScanning && !scannedValue.isEmpty {
                getStrings(scannedInfo: scannedValue)
            }
        }
    }
    
    func getStrings(scannedInfo: String) {
        print(scannedInfo)
        let neeededString: [String] = ["DAC", "DAB", "DAD", "DBB", "DBD", "DBA", "DCF", "DAJ", "DCA"]
        let nameCode = "DCS"
        //1+2/
        var resString: [String] = []
        for code in neeededString {
            var checkName = code
            if code == "DAB" {
                if scannedInfo.contains(nameCode) {
                    checkName = nameCode
                } else {
                    checkName = code
                }
            }
            if let range = scannedInfo.range(of: checkName) {
                let startIndex = range.upperBound
                   let extractedSubstring = scannedInfo[startIndex...]
                   let characterSet = CharacterSet(charactersIn: " \n")
                   if let endIndex = extractedSubstring.rangeOfCharacter(from: characterSet)?.lowerBound {
                       let finalSubstring = String(extractedSubstring[..<endIndex])
                       resString.append(finalSubstring)// Output: "khan"
                   } else {
                       print(extractedSubstring.trimmingCharacters(in: characterSet)) // Output: "khan"
                   }
            } else {
                resString.append("?")
            }
        }
        viewModel.dataArray = resString
        selectedState = stateDictionary[viewModel.dataArray[7]] ?? "Alabama"
        if viewModel.dataArray.count == 9 && viewModel.dataArray.last != "?" {
            selectedClass = viewModel.dataArray.last ?? "B"
        }
    }
}
