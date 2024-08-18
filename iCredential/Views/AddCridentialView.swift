//
//  AddCridentialView.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import SwiftUI

struct AddCridentialView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var isShown: Bool
    @State private var accountName: String = ""
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false // To control showing validation alert

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 24) {
                EmptyView()
                TextField("AccountName", text: $accountName)
                    .textFieldStyle(.roundedBorder)
                TextField("UserName/Email", text: $userName)
                    .textFieldStyle(.roundedBorder)
                TextField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    // Perform input validation
                    if isValidInput() {
                        viewModel.addNewCridential(accountName: accountName, userName: userName, password: password)
                        viewModel.isShowAddCridentalView = false // Dismiss the view
                    } else {
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Add New Account")
                            .font(Font.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                            .padding()
                        Spacer()
                    }
                    .frame(height: 44)
                    .background(Color.black)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Validation Error"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
            }
        }
        .background(Color.colorF9F9F9)
    }

    private func isValidInput() -> Bool {
        return !accountName.isEmpty && !userName.isEmpty && !password.isEmpty
    }
}
