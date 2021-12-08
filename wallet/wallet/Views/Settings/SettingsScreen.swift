//
//  SettingsScreen.swift
//  SettingsScreen
//
//  Created by Lokesh Sehgal on 08/08/21.
//  Copyright © 2021 Francisco Gindre. All rights reserved.
//

import SwiftUI
import Neumorphic
import BottomSheet
import LocalAuthentication

struct SettingsRowData : Equatable {
    var id: Int
    var title: String
}


enum SettingsDestination: Int {
//    case openLanguage = 0
    case openNotifications = 1
    case handleFaceId = 2
    case openRecoveryPhrase = 3
    case openChangePIN = 4
    case openUnlinkDevice = 5
    case openPrivateServerConfig = 6
    case openiCloudBackup = 7
    case openPrivacyPolicy = 8
    case openlicense = 9
//    case openSupport = 10
    case startRescan = 11
    case openAboutUs = 12
}


struct SettingsScreen: View {
    
    var mVersionDetails = "Build Version: 1.0.0-2-54-g2c852e9 (Beta)"
    
    @State var mURLString = ""
    
    @State var mOpenSafari = false

    var generalSection = [/*SettingsRowData(id:0,title:"Language".localized()),*/SettingsRowData(id:6,title:"Private Server Config".localized()),SettingsRowData(id:11,title:"Rescan Wallet".localized())]//,
//                          SettingsRowData(id:1,title:"Notifications")] // Moved private server config here
    var securitySection = [SettingsRowData(id:2,title:"Biometric ID".localized()),
                           SettingsRowData(id:3,title:"Recovery Phrase".localized()),
                           SettingsRowData(id:4,title:"Change PIN".localized()),
                           SettingsRowData(id:5,title:"Delete Wallet".localized())]
//    var walletSection = [SettingsRowData(id:6,title:"Private Server Config")] //,
//                         SettingsRowData(id:7,title:"iCloud backup")]
    var aboutSection = [SettingsRowData(id:8,title:"Privacy Policy".localized()),
                        SettingsRowData(id:9,title:"License".localized()),
                        SettingsRowData(id:12,title:"About Pirate Wallet".localized())
                        /*,
                        SettingsRowData(id:10,title:"Support".localized())*/]
    
    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    @State var destination: SettingsDestination?
    
//    @State var openLanguageScreen = false
    
    @State var mSelectedSettingsRowData: SettingsRowData?
    
    func aSmallVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.warning)
    }
    
    @State private var tabBar: UITabBar! = nil
    
    var body: some View {
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 10) {
                    Text("Settings".localized())
                        .scaledFont(size: 20).multilineTextAlignment(.center).foregroundColor(.white)

                    ScrollView {

                        SettingsSectionHeaderView(aTitle:"General".localized())
                        VStack {
                            ForEach(generalSection, id: \.id) { settingsRowData in
                                    SettingsRow(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:11)
                                    .onTapGesture {
                                        self.mSelectedSettingsRowData = settingsRowData
                                        openRespectiveScreenBasisSelection()
                                        aSmallVibration()
                                    }
                            }
                            
                        }
                        .modifier(SettingsSectionBackgroundModifier())
                        
                        SettingsSectionHeaderView(aTitle:"Security".localized())
                        VStack {
                            ForEach(securitySection, id: \.id) { settingsRowData in
                                VStack {
                                    
                                    if (settingsRowData.id == 2){
                                        SettingsRowWithToggle(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData)
                                            .onTapGesture {
                                                self.mSelectedSettingsRowData = settingsRowData
                                                openRespectiveScreenBasisSelection()
                                            }
                                    }else{
                                        SettingsRow(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:5)
                                            .onTapGesture {
                                                self.mSelectedSettingsRowData = settingsRowData
                                                openRespectiveScreenBasisSelection()
                                                aSmallVibration()
                                            }
                                    }
                                }
                            }
                        }
                        .modifier(SettingsSectionBackgroundModifier())
                        
                        
                        // Commented out this section for a while
//                        SettingsSectionHeaderView(aTitle:"Manage Wallet")
//                        VStack {
//                            ForEach(walletSection, id: \.id) { settingsRowData in
//                                SettingsRow(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:0)
//                                    .onTapGesture {
//                                        self.mSelectedSettingsRowData = settingsRowData
//                                        openRespectiveScreenBasisSelection()
//                                    }
//                            }
//
//                        }
//                        .modifier(SettingsSectionBackgroundModifier())
                        
                        SettingsSectionHeaderView(aTitle:"About".localized())
                        VStack {
                            ForEach(aboutSection, id: \.id) { settingsRowData in
                               SettingsRow(mCurrentRowData: settingsRowData, mSelectedSettingsRowData: $mSelectedSettingsRowData, noLineAfter:12)
                                .onTapGesture {
                                    self.mSelectedSettingsRowData = settingsRowData
                                    openRespectiveScreenBasisSelection()
                                    aSmallVibration()
                                }
                            }
                        }
                        .modifier(SettingsSectionBackgroundModifier())
                        
                        
                      Text(mVersionDetails).scaledFont(size: 15).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).padding(.bottom,20)

                    }
                    .padding(.bottom,2)
          
                }
                
                NavigationLink(
                    destination: UnlinkDevice().environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true },
                               tag: SettingsDestination.openUnlinkDevice,
                               selection: $destination
                ) {
                   EmptyView()
                }
                
                NavigationLink(
                    destination: PrivateServerConfig().environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
                        ,
                               tag: SettingsDestination.openPrivateServerConfig,
                               selection: $destination
                ) {
                   EmptyView()
                }
                
                NavigationLink(
                    destination: NotificationScreen().environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
                        ,
                               tag: SettingsDestination.openNotifications,
                               selection: $destination
                ) {
                   EmptyView()
                }
                
                
             
                NavigationLink(
                    
                    destination: PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .changePasscode, isChangePinFlow: true).environmentObject(self.appEnvironment)
                        .onAppear { self.tabBar.isHidden = true },
                    tag: SettingsDestination.openChangePIN,
                    selection: $destination
                ) {
                    EmptyView()
                }
                
                
                NavigationLink(
                    destination: InitiateRecoveryKeyPhraseFlow().onAppear { self.tabBar.isHidden = true }
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                               tag: SettingsDestination.openRecoveryPhrase,
                               selection: $destination
                ) {
                   EmptyView()
                }.isDetailLink(false)
                
                NavigationLink(
                    destination: RescanOptionsView(rescanDataViewModel: RescanDataViewModel()).environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                               tag: SettingsDestination.startRescan,
                               selection: $destination
                ) {
                   EmptyView()
                }
                
                NavigationLink(
                    destination: AboutUs().environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                               tag: SettingsDestination.openAboutUs,
                               selection: $destination
                ) {
                   EmptyView()
                }
                
                
//                Group {
//
//                    NavigationLink(
//                        destination: OpenInAppBrowser(aURLString: "privacyURL".localized(),aTitle: "Privacy Policy".localized()).environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
//                            ,
//                                   tag: SettingsDestination.openPrivacyPolicy,
//                                   selection: $destination
//                    ) {
//                       EmptyView()
//                    }
                    
//                    NavigationLink(
//                        destination: OpenInAppBrowser(aURLString: "licenseURL".localized(),aTitle: "License".localized()).environmentObject(self.appEnvironment)
//                            .onAppear { self.tabBar.isHidden = true }
//                            ,
//                                   tag: SettingsDestination.openlicense,
//                                   selection: $destination
//                    ) {
//                       EmptyView()
//                    }
//
//                 }
                
//                NavigationLink(
//                    destination: OpenInAppBrowser(aURLString: "supportURL".localized(),aTitle: "Support".localized()).environmentObject(self.appEnvironment).onAppear { self.tabBar.isHidden = true }
//                        ,
//                               tag: SettingsDestination.openSupport,
//                               selection: $destination
//                ) {
//                   EmptyView()
//                }
//
            }.background(TabBarAccessor { tabbar in
                self.tabBar = tabbar
            })
            .sheet(isPresented: $mOpenSafari) {
                CustomSafariView(url:URL(string: self.mURLString)!)
            }
//            .actionSheet(isPresented: $showActionSheet) {
//                       ActionSheet(
//                           title: Text(""),
//                           message: Text("Do you want to Re-scan your wallet?".localized()),
//                        buttons: [
//                            .default(Text("Quick Re-Scan".localized()), action: {
//                                self.appEnvironment.synchronizer.quickRescan()
//                            }),
//                            .default(Text("Later".localized()))
//                        ]
//                       )
//               }
            .navigationBarHidden(true)
//            .bottomSheet(isPresented: $openLanguageScreen,
//                          height: 500,
//                          topBarHeight: 0,
//                          topBarCornerRadius: 20,
//                          showTopIndicator: true) {
//                SelectLanguage().environmentObject(appEnvironment)
//            }
            .onAppear(){
//                NotificationCenter.default.addObserver(forName: NSNotification.Name("DismissSettings"), object: nil, queue: .main) { (_) in
//                    openLanguageScreen = false
//                }
                
                if self.tabBar != nil {
                    self.tabBar.isHidden = false
                }
            }.onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
                switch output {
                case .failed(_), .userFailed:
                    print("SOME ERROR OCCURRED")
//                    UserSettings.shared.isBiometricDisabled = true
//                    NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)

                case .success:
                    print("SUCCESS IN SETTINGS")
                    UserSettings.shared.biometricInAppStatus = true
                    UserSettings.shared.isBiometricDisabled = false
                case .userDeclined:
                    print("DECLINED AND SHOW SOME ALERT HERE")
                    UserSettings.shared.biometricInAppStatus = false
                    UserSettings.shared.isBiometricDisabled = true
                    NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)

                    break
                }
            }
    }
    
    func openRespectiveScreenBasisSelection(){
        self.destination = SettingsDestination(rawValue: self.mSelectedSettingsRowData?.id ?? 0)
        
        
        switch(self.mSelectedSettingsRowData?.id){
//            case SettingsDestination.openLanguage.rawValue:
//                openLanguageScreen.toggle()
//            break
        case SettingsDestination.openlicense.rawValue:
            self.mURLString  = "licenseURL".localized()
            mOpenSafari = true
            break
        case SettingsDestination.openPrivacyPolicy.rawValue:
            self.mURLString  = "privacyURL".localized()
            mOpenSafari = true
            break
            default:
                print("Something else is tapped")
        }
        
    }
    
}



struct SettingsSectionHeaderView : View {
    @State var aTitle: String = ""

    var body: some View {
        
        ZStack {
            
            VStack(alignment: .trailing, spacing: 6) {

              Text(aTitle)
                .scaledFont(size: 20).foregroundColor(Color.zSettingsSectionHeader)
                                .foregroundColor(Color.white)
              .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
             
            }
            .frame(width: 380)
           
        }
    }
}

struct SettingsRow: View {

    var mCurrentRowData:SettingsRowData
   
    @Binding var mSelectedSettingsRowData: SettingsRowData?
    
    var noLineAfter = 0

    var body: some View {
//
        VStack {
            HStack{
                Text(mCurrentRowData.title)
                    .multilineTextAlignment(.leading)
                    .scaledFont(size: 16).foregroundColor(Color.textTitleColor)
                    .frame(height: 22,alignment: .leading)
                                .foregroundColor(Color.white)
                    .padding()
                Spacer()
                Image("arrow_right").resizable().frame(width: 20, height: 20, alignment: .trailing)
                .padding()
            }.contentShape(Rectangle())
            
            if mCurrentRowData.id < noLineAfter {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            }
        }
    }
}

struct SettingsRowWithToggle: View {

    var mCurrentRowData:SettingsRowData
   
    @Binding var mSelectedSettingsRowData: SettingsRowData?
    
    @State var isFaceIdEnabled = UserSettings.shared.biometricInAppStatus
    
    @State var isDisableBioMetric = false // Disable on simulator
    
    @State var isPermissionDenied = false // Disable on simulator
    
    var body: some View {

        VStack {
            HStack{
                Text(mCurrentRowData.title).multilineTextAlignment(.leading)
                    .scaledFont(size: 16).foregroundColor(Color.textTitleColor)
                                .frame(width: 200, height: 22,alignment: .leading)
                                .foregroundColor(Color.white)
                    .padding()
                
                Spacer()
                
                Toggle("", isOn: $isFaceIdEnabled)
                    .onChange(of: isFaceIdEnabled, perform: { isEnabled in
                        
                            UserSettings.shared.biometricInAppStatus = isEnabled
                            isFaceIdEnabled = isEnabled

                            if (isFaceIdEnabled){
                                
                                initiateLocalAuthenticationFlow()
                                
                            }else{
                                isFaceIdEnabled = false
                                isPermissionDenied  = true
                            }
                        
                    })
                    .multilineTextAlignment(.trailing)
                    .toggleStyle(ColoredToggleStyle()).labelsHidden()
                    .disabled(isDisableBioMetric)
                    .onAppear(){
                                #if targetEnvironment(simulator)
                                isDisableBioMetric = true
                                #endif
                        
                        
                                NotificationCenter.default.addObserver(forName: NSNotification.Name("BioMetricStatusUpdated"), object: nil, queue: .main) { (_) in
                                    
                                    if !UserSettings.shared.isBiometricDisabled {
                                        initiateLocalAuthenticationFlow()
                                    }else{
                                        isFaceIdEnabled = false
                                        isPermissionDenied  = true
                                    }
                                }
                    }
            }
            .alert(isPresented: $isPermissionDenied) {
                Alert(title: Text("Permission Denied".localized()), message: Text("Please enable the Biometric ID permission in the settings.".localized()), dismissButton: .default(Text("Ok".localized())))
            }
            
            Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            
        }
    }
    
    func initiateLocalAuthenticationFlow(){
        if UserSettings.shared.biometricInAppStatus {
                       authenticate()
        }
    }
    
    func authenticate() {
         if UserSettings.shared.biometricInAppStatus {
             AuthenticationHelper.authenticate(with: "Authenticate Biometric ID".localized())
         }
     }
}


struct ColoredToggleStyle: ToggleStyle {
    var onColor = Color.onColor
    var offColor = Color.offColor
    var thumbOnColor = Color.thumbOnColor
    var thumbOffColor = Color.thumbOffColor
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 40, height: 29)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? thumbOnColor : thumbOffColor)
                        .shadow(radius: 1, x: 0, y: 1)
                        .padding(1.5)
                        .offset(x: configuration.isOn ? 10 : -10))
                .animation(Animation.easeInOut(duration: 0.2))
                .onTapGesture { configuration.isOn.toggle() }
        }
        .font(.title)
        .padding(.horizontal)
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}

struct SettingsSectionBackgroundModifier: ViewModifier {

        var backgroundColor = Color(.systemBackground)

        func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                        .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
}


struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
    }

    typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}
