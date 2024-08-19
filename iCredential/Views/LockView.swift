//
//  LockView.swift
//  iCredential
//
//  Created by Aswanth K on 19/08/24.
//

import SwiftUI
import LocalAuthentication

struct LockView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var isUnlocked = false
    @State private var authenticationError: String?
    
    var body: some View {
        VStack {
            if isUnlocked {
                Text("Welcome, you're authenticated!")
                    .font(.largeTitle)
                    .padding()
            } else {
                Text("Please authenticate using Face ID")
                    .font(.title2)
                    .padding()
                
                if let error = authenticationError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: authenticate) {
                    Text("Authenticate")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear(perform: authenticate)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TriggerAuthentication"))) { _ in
                    authenticate()
                }
    }

    func authenticate() {
            let context = LAContext()
            var error: NSError?

            // Check if Face ID is available
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "We need to authenticate you with Face ID."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self.isUnlocked = true
                            viewModel.currentView = .homeView
                        } else {
                            self.authenticationError = "Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")"
                        }
                    }
                }
            } else {
                // No biometrics available
                self.authenticationError = "Face ID not available on this device."
            }
        }
}

#Preview {
    LockView()
}
