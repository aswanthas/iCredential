//
//  iCredentialApp.swift
//  iCredential
//
//  Created by Aswanth K on 26/06/24.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isAuthenticationTriggered = false
}

@main
struct iCredentialApp: App {
    @StateObject var viewModel = ViewModel()
    @StateObject var appState = AppState()  // ObservableObject for app state
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch viewModel.currentView {
                case .lockScreen:
                    LockView()
                case .homeView:
                    ContentView()
                }
            }
            .environmentObject(viewModel)
            .environmentObject(appState)  // Pass it down the view hierarchy
            .onChange(of: scenePhase) { newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            if !appState.isAuthenticationTriggered {
                viewModel.currentView = .lockScreen
                triggerAuthentication()
            }
        case .background:
            appState.isAuthenticationTriggered = false
        default:
            break
        }
    }
    
    private func triggerAuthentication() {
        debugPrint("Triggering authentication...")
        NotificationCenter.default.post(name: NSNotification.Name("TriggerAuthentication"), object: nil)
        appState.isAuthenticationTriggered = true
    }
}
