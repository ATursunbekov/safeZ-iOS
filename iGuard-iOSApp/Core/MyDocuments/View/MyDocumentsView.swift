//
//  MyDocumentsView.swift
//  iGuard-iOSApp
//
//  Created by Aidar Asanakunov on 13/4/23.
//

import SwiftUI
import Kingfisher
import Introspect

struct MyDocumentsView: View {
    @State private var showingImagePickerRegistration = false
    @State private var showingImagePickerInsurance = false
    @State var imageRegistration: UIImage?
    @State var imageInsurance: UIImage?
    @State var showDeleteMenu = false
    @State var isRegistrationImage = true
    @StateObject var documentsViewModel = DocumentsViewModel()
    @Environment (\.presentationMode) private var presentationMode
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State var isPresented = false
    @Binding var showTabBar: Bool
    @State var selectedScanning = "Driver license"
    @State private var uiTabarController: UITabBarController?
    
    var body: some View {
        if !isPresented {
        ScrollView(showsIndicators: false) {
            ActivityIndicatorView(isDisplayed: $documentsViewModel.isLoadingLoader) {
                ZStack {
                    background
                    VStack {
                        DriverLicenseCardView(isPresented: $isPresented)
                        vehicleRegistration
                        carInsurance
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                }
                .navigationTitle("My Documents")
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
            }
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
            }
            .environmentObject(documentsViewModel)
        }
        .overlay(
            VStack {
                if showDeleteMenu {
                    Spacer()
                    DropdownMenuDocument(showMenuDelete: $showDeleteMenu, isRegistrationImage: isRegistrationImage)
                        .offset(y: showDeleteMenu ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 30: UIScreen.main.bounds.height)
                        .animation(.easeInOut(duration: 0.1))
                        .transition(.move(edge: .bottom))
                    //.padding(.horizontal,UIScreen.main.bounds.width *  (13 / 390))
                        .frame(maxWidth: UIScreen.main.bounds.width)
                }
            }
                .background(Color(UIColor.black.withAlphaComponent(showDeleteMenu ? 0.5 : 0)).ignoresSafeArea())
        )
        .onAppear() {
            homeViewModel.getDocuments()
            showTabBar = false
        }
        .environmentObject(documentsViewModel)
    } else {
        VStack(spacing: 24) {
            Text("Scan your DRIVER LICENSE to use SafeZ features to the fullest")
                .multilineTextAlignment(.center)
                .font(.custom(Gilroy.medium.rawValue, size: 16))
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white)
                        .frame(height: 74)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.95, green: 0.95, blue: 0.95), lineWidth: 1)
                        )
                    HStack(spacing: 20) {
                        Image(DocumentsImage.scanBlue.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Step 1")
                                .font(.custom(Gilroy.medium.rawValue, size: 14))
                                .foregroundColor(.secondaryText)
                            Text("Scan Driver license")
                                .font(.custom(Gilroy.semiBold.rawValue, size: 16))
                        }
                        Spacer()
                    }
                    .padding(.leading, 16)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white)
                        .frame(height: 74)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.95, green: 0.95, blue: 0.95), lineWidth: 1)
                        )
                    HStack(spacing: 20) {
                        Image(DocumentsImage.shieldDone.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Step 2")
                                .font(.custom(Gilroy.medium.rawValue, size: 14))
                                .foregroundColor(.secondaryText)
                            Text("Verify information provided")
                                .font(.custom(Gilroy.semiBold.rawValue, size: 16))
                        }
                        Spacer()
                    }
                    .padding(.leading, 16)
                }
                //SelectionIDDropDown(placeholder: "Scan", selectedObject: $selectedScanning)
            }
            
            Spacer()
            
            NavigationLink {
                ScannerScreen(isPresented: $isPresented, selectedScanning: $selectedScanning)
            } label: {
                Text("Start Scan")
                    .foregroundColor(.white)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.size.height / 15.5)
                    .background(Color.customPrimary)
                    .cornerRadius(18)
            }
            .padding(.bottom, 50)
        }
        .padding(.top, 35)
        .padding(.horizontal, 22)
        .navigationTitle("Driver license scan")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Image(ProfileIcons.arrowBack.rawValue)
                        .imageScale(.large)
                        .frame(width: 35, height: 30, alignment: .leading)
                }
                .frame(width: 35, height: 30, alignment: .leading)
            }
        }
    }
    }

    private var vehicleRegistration: some View {
            VStack(spacing: 24) {
                Text("Vehicle registration ")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                VStack(spacing: 16) {
                    if let imageURLRegistration = documentsViewModel.imageURLRegistration {
                        KFImage(imageURLRegistration)
                            .resizable()
                            .frame(height: 215)
                            .cornerRadius(26)
                        HStack(spacing: 16) {
                            Button {
                                isRegistrationImage = true
                                showDeleteMenu = true
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.black)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.size.height / 15.5)
                                    .background(Color.white)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(Color.primarySubtle, lineWidth: 1)
                                    )
                            }
                            Button {
                                showingImagePickerRegistration.toggle()
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.white)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.size.height / 15.5)
                                    .background(Color.customPrimary)
                                    .cornerRadius(18)
                            }
                            
                        }
                    } else {
                        Image(DocumentsImage.vehicleRegistration.rawValue)
                            .resizable()
                            .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                        Button {
                            showingImagePickerRegistration.toggle()
                        } label: {
                            Text("Update Image")
                                .foregroundColor(.white)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                                .background(Color.customPrimary)
                                .cornerRadius(18)
                        }
                    }
                }
                .sheet(isPresented: $showingImagePickerRegistration) {
                    //ImagePicker(image: $imageRegistration, imageType: .carRegistration, isForProfileView: true)
                    showScanner(imageType: .carRegistration)
                        .ignoresSafeArea()
                }
            }
            .padding(.top, 50)
    }
    private var carInsurance: some View {
            VStack(spacing: 24) {
                Text("Automobile Insurance")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                VStack(spacing: 16) {
                    if let imageURLInsurance = documentsViewModel.imageURLInsurance {
                        KFImage(imageURLInsurance)
                            .resizable()
                            .frame(height: 215)
                            .cornerRadius(26)
                            .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                        HStack(spacing: 16) {
                            Button {
                                isRegistrationImage = false
                                showDeleteMenu = true
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.black)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.size.height / 15.5)
                                    .background(Color.white)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(Color.primarySubtle, lineWidth: 1)
                                    )
                            }
                            Button {
                                showingImagePickerInsurance.toggle()
                            } label: {
                                Text("Edit")
                                    .foregroundColor(.white)
                                    .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                    .frame(width: UIScreen.main.bounds.width * 0.43, height: UIScreen.main.bounds.size.height / 15.5)
                                    .background(Color.customPrimary)
                                    .cornerRadius(18)
                            }
                        }
                    } else {
                        Image(DocumentsImage.vehicleRegistration.rawValue)
                            .resizable()
                            .shadow(color: .shadowTFLogin, radius: 5, x: 13, y: 16)
                        Button {
                            showingImagePickerInsurance.toggle()
                        } label: {
                            Text("Update Image")
                                .foregroundColor(.white)
                                .font(.custom(Gilroy.semiBold.rawValue, size: 18))
                                .frame(maxWidth: .infinity)
                                .frame(height: UIScreen.main.bounds.size.height / 15.5)
                                .background(Color.customPrimary)
                                .cornerRadius(18)
                        }
                    }
                }
                .sheet(isPresented: $showingImagePickerInsurance, content: {
                    //ImagePicker(image: $imageInsurance, imageType: .carInsurance, isForProfileView: true)
                    showScanner(imageType: .carInsurance)
                        .ignoresSafeArea()
                })
            }
            .padding(.top, 50)
    }
    private var background: some View {
        GeometryReader { proxy in
            let mult = proxy.safeAreaInsets.bottom == 0 ? 0.9 : 1
            let size = proxy.size.width * 2.5 * mult
            ZStack() {
                Circle()
                    .fill(
                        Color.backgroundLightPurple
                    )
                    .frame(width: size, height: size)
                    .offset(
                        x: proxy.frame(in: .local).midX - size / 2,
                        y: proxy.frame(in: .local).midY * 0.9)
            }
        }
    }

    //MARK: Scanner initialization
    func showScanner(imageType: FolderPath) -> some View {
        DocumentScanner { result in
            switch result {
            case .success(let image):
                if imageType == .carInsurance {
                     imageInsurance = image
                } else if imageType == .carRegistration {
                    imageRegistration = image
                }
                showingImagePickerInsurance = false
                documentsViewModel.uploadImageStorage(path: imageType, image: image) { result in
                    if result {
                        DispatchQueue.main.async {
                            self.documentsViewModel.loadImageUrl()
                            self.homeViewModel.getDocuments()
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            if imageType == .carInsurance {
                showingImagePickerInsurance = false
            } else if imageType == .carRegistration {
                showingImagePickerRegistration = false
            }
        } didCancel: {
            if imageType == .carInsurance {
                showingImagePickerInsurance = false
            } else if imageType == .carRegistration {
                showingImagePickerRegistration = false
            }
        }

    }
    
}
