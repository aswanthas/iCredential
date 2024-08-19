import SwiftUI

struct CridentialDetailsView: View {
//    var data: Cridentials
    @EnvironmentObject var viewModel: ViewModel // Inject ViewModel
    @State private var isEditing: Bool = false
    @State private var editedAccountName: String = ""
    @State private var editedUserName: String = ""
    @State private var editedPassword: String = ""
    @State private var passwordToggle: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Details")
                .foregroundColor(.color3F7DE3)
                .font(Font.system(size: 19, weight: .bold, design: .rounded))
            
            // Account Name
            VStack(alignment:.leading) {
                Text("Account Name")
                    .font(Font.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.colorCCCCCC)
                if isEditing {
                    TextField("Account Name", text: $editedAccountName)
                        .font(Font.system(size: 16, weight: .bold, design: .rounded))
                } else {
                    Text(viewModel.selectedCridential?.accountName ?? "")
                        .font(Font.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            // Username/Email
            VStack(alignment:.leading) {
                Text("Username/Email")
                    .font(Font.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.colorCCCCCC)
                if isEditing {
                    TextField("Username/Email", text: $editedUserName)
                        .font(Font.system(size: 16, weight: .bold, design: .rounded))
                } else {
                    Text(viewModel.selectedCridential?.userName ?? "")
                        .font(Font.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            // Password
            VStack(alignment:.leading) {
                Text("Password")
                    .foregroundColor(.colorCCCCCC)
                    .font(Font.system(size: 11, weight: .bold, design: .rounded))

                HStack {
                    if isEditing {
                        SecureField("******", text: $editedPassword)
                            .font(.headline)
                    } else {
                        if passwordToggle {
                            Text(viewModel.decryptedPassword(data: viewModel.selectedCridential?.password ?? ""))
                                .font(.headline)
                        } else {
                            SecureField("******", text: Binding<String>(
                                get: { "******" },
                                set: { _ in }
                            ))
                            .font(.headline)
                            .disabled(!isEditing)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if !isEditing {
                            passwordToggle.toggle()
                        }
                    }) {
                        Image(systemName: passwordToggle ? "eye" : "eye.slash")
                            .foregroundColor(.colorCCCCCC)
                    }
                    .padding(.trailing, 20)
                }
            }
            HStack {
                if isEditing {
                    Button(action: {
                        // Cancel editing
                        editedAccountName = viewModel.selectedCridential?.accountName ?? ""
                        editedUserName = viewModel.selectedCridential?.userName ?? ""
                        editedPassword = ""
                        isEditing = false
                        viewModel.isShowDetailCridentalView = false // Dismiss the view
                    }) {
                        Text("Cancel")
                            .font(Font.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 154)
                            .background(.color2C2C2C)
                            .cornerRadius(20)
                    }
                    Spacer()
                    Button(action: {
                        // Save changes
                        viewModel.updateCridential(data: viewModel.selectedCridential, accountName: editedAccountName, userName: editedUserName, password: editedPassword)
                        isEditing = false
                        viewModel.isShowDetailCridentalView = false // Dismiss the view
                    }) {
                        Text("Update")
                            .font(Font.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 154)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                } else {
                    Button(action: {
                        // Edit action
                        isEditing = true
                        editedAccountName = viewModel.selectedCridential?.accountName ?? ""
                        editedUserName = viewModel.selectedCridential?.userName ?? ""
                        editedPassword = ""
                    }) {
                        Text("Edit")
                            .font(Font.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 154)
                            .background(.color2C2C2C)
                            .cornerRadius(20)
                    }
                    Spacer()
                    Button(action: {
                        // Delete action
                        viewModel.deleteCridential(data: viewModel.selectedCridential)
                        viewModel.isShowDetailCridentalView = false // Dismiss the view
                    }) {
                        Text("Delete")
                            .font(Font.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 154)
                            .background(.colorF04646)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
