//
//  iCridentialsSaverApp.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var isPresenting: Bool = false
    @State var selectedDetent: PresentationDetent = .medium
    @State private var isShowCridentialDeatil: Bool = false
    @State private var selectedCridential: Cridentials? = nil
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.colorEDEDED
                        .ignoresSafeArea(.all)
                    if viewModel.savedPasswords.isEmpty {
                        Text("**Save your credential here**")
                            .foregroundStyle(.color2C2C2C)
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(viewModel.savedPasswords, id: \.id) { item in
                                    CridentialCard(data: item)
                                        .frame(height: 67)
                                        .onTapGesture {
                                            viewModel.selectedCridential = item
                                            guard let _ = viewModel.selectedCridential else { return }
                                            viewModel.isShowDetailCridentalView = true
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.isShowAddCridentalView.toggle()
                            }, label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                                .padding(20)
                                .background(Color.blue)
                                .cornerRadius(25)
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
                .alert(item: $viewModel.errorMessage) { error in
                    Alert(
                        title: Text("Warnning"),
                        message: Text(error.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(isPresented: $viewModel.isShowAddCridentalView) {
                AddCredentialView(isShown: $isPresenting)
                    .presentationDetents([.large,.medium,.fraction(0.75)])
            }
            .sheet(isPresented: $viewModel.isShowDetailCridentalView, content: {
                CridentialDetailsView()
                    .presentationDetents([.large,.medium,.fraction(0.75)])
            })
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
