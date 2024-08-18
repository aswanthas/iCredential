//
//  iCridentialsSaverApp.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var isPresenting: Bool = false
    @State var selectedDetent: PresentationDetent = .medium
    @State private var isShowCridentialDeatil: Bool = false
    @State private var selectedCridential: Cridentials? = nil // Track selected credential
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.colorEDEDED
                        .ignoresSafeArea(.all)
                    ScrollView {
                        VStack {
                            ForEach(viewModel.savedPasswords, id: \.id) { item in
                                CridentialCard(data: item)
                                    .frame(height: 67)
                                    .onTapGesture {
                                        // Select the item and show bottom sheet
                                        viewModel.selectedCridential = item
                                        guard let _ = viewModel.selectedCridential else { return }
                                        viewModel.isShowDetailCridentalView = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                // Toggle bottom sheet for adding new credential
                                viewModel.isShowAddCridentalView.toggle()
                            }, label: {
                                // Button content
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                                .padding(20) // Larger padding for a bigger button
                                .background(Color.blue)
                                .cornerRadius(25) // More rounded corners
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 5, y: 5)
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                    }
                    VStack {
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                    }
                }
                .navigationTitle(Text("Password Manager"))
                // Set navigation bar background color
                
                .alert(item: $viewModel.errorMessage) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(isPresented: $viewModel.isShowAddCridentalView) {
                AddCridentialView(isShown: $isPresenting)
                    .presentationDetents([.large,.medium,.fraction(0.75)])
            }
            // Bottom sheet for adding new credential
//            BottomSheetView(isShown: $isPresenting, cornerRadius: 12) {
//                AddCridentialView(isShown: $isPresenting)
//            }
            .sheet(isPresented: $viewModel.isShowDetailCridentalView, content: {
                CridentialDetailsView()
                    .presentationDetents([.large,.medium,.fraction(0.75)])
            })
            // Bottom sheet for updating selected credential
//            if isShowCridentialDeatil, let selectedCridential = selectedCridential {
//                BottomSheetView(isShown: $isShowCridentialDeatil, cornerRadius: 12) {
//                    CridentialDetailsView(isShown: $isShowCridentialDeatil)
//                }
//            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
