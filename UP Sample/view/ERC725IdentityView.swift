//
//  ERC725IdentityView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import universalprofile_ios_sdk

struct ERC725IdentityView: View {
    
    @StateObject private var viewModel = DependencyInjectorContainer.resolve(IdentityProviderBaseFlowViewModel.self)!
    
    private let lsp3SearchView = LSP3ProfileSearchView()
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Group {
                                
                                Text("ERC725Key")
                                    .font(.title3)
                                    .padding(.top, 16)
                                // TODO: Why address is here?
                                Text(viewModel.address)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("ERC725Address")
                                    .font(.title3)
                                // TODO: Why public key is here?
                                Text(viewModel.publicKey)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .font(.body)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            
                            Divider()
                            
                            Group {
                                Text("Result")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(Color.black.opacity(0.8))
                                    .padding(.top, 12)
                                    .padding(.bottom, 16)
                                    .font(.headline.italic())
                                
                                Text("ERC725Key")
                                    .font(.title3)
                                Text(viewModel.myInfo?.erc725Key ?? "...")
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                                    .font(.body)
                                    .frame(maxHeight: .infinity)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("ERC725Address")
                                    .font(.title3)
                                Text(viewModel.myInfo?.erc725Address ?? "...")
                                    .frame(maxHeight: .infinity)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("IsAnonymous")
                                Text(isAnonymous())
                                    .frame(maxHeight: .infinity)
                                    .foregroundColor(Color.black.opacity(0.75))
                                    .padding()
                                    .font(.body)
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            
                            Button(action: {
                                if viewModel.myInfo == nil {
                                    viewModel.signIn()
                                } else {
                                    viewModel.callMe()
                                }
                            }) {
                                ZStack(alignment: .trailing) {
                                    Text(viewModel.myInfo == nil ? "Sign in" : "Call me again")
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.blue)
                                    
                                    if viewModel.showProgress {
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(viewModel.showProgress)
                            .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                            .padding(.top, 32)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                        }
                        .mask(RoundedRectangle(cornerRadius: 9))
                        .background(RoundedRectangle(cornerRadius: 9)
                                        .fill(Color.lightStart)
                                        .shadow(color: .black.opacity(0.2), radius: 10, x: 3, y: 3)
                                        .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2))
                        .padding(.leading, 16)
                        .padding(.trailing, 16)
                        
                        Divider()
                            .padding(.top, 16)
                        
                        defaultTitleText("Search LSP3 profiles", .headline)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        
                        defaultTitleText("Note: this is a standalone UI element that can be basically drag & dropped into a place where it is needed. It is easy as writing `LSP3ProfileSearchView()`.",
                                         .system(size: 10).italic())
                            .padding(.top, 8)
                            .padding(.trailing, 16)
                            .padding(.bottom, 4)
                        
                        lsp3SearchView
                        
                        Spacer()
                    }
                }
                .alert(isPresented: $viewModel.showToastAlert, content: {
                Alert(
                    title: Text("Message"),
                    message: Text(viewModel.toastMessage ?? ""),
                    dismissButton: .default(Text("Close"))
                )
            })
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    private func isAnonymous() -> String {
        if viewModel.myInfo == nil {
            return "..."
        } else {
            return String.init(describing: viewModel.myInfo!.isAnonymous)
        }
    }
}


struct ERC725IdentityView_Previews: PreviewProvider {
    static var previews: some View {
        ERC725IdentityView()
    }
}
