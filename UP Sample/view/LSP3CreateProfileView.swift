//
//  LSP3CreateProfileView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct LSP3CreateProfileView: View {
    private let disposeBag = DisposeBag()
    @ObservedObject private var viewModel = DependencyInjectorContainer.resolve(LSP3CreateProfileViewModel.self)!
    @State private var showingProfileImagePicker = false
    @State private var showingBackdropImagePicker = false
    @State private var profileImage: UIImage? = nil
    @State private var backdropImage: UIImage? = nil
    @State private var username: String = ""
    @State private var description: String = ""
    @State private var newLinkTitle: String = ""
    @State private var newLinkUrl: String = ""
    @State private var newTag: String = ""
    
    @State private var showToastAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var showCreatingProfileProgress = false
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    // Name, description group
                    Group {
                        defaultTitleText("Name")
                        
                        defaultTextField("Must not be empty", text: $username)
                            .textContentType(.name)
                            .keyboardType(.alphabet)
                            .autocapitalization(.words)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .disableAutocorrection(true)
                        
                        defaultTitleText("Description")
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100, maxHeight: .infinity)
                            .padding(.leading, 24)
                            .padding(.trailing, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .background(NeomorphicStyle.TextField.standard
                                            .padding(.leading, 16)
                                            .padding(.trailing, 16))
                    }
                    
                    // Images group
                    Group {
                        defaultTitleText("Profile image")
                        
                        HStack(alignment: .top, spacing: 0) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .mask(RoundedRectangle(cornerRadius: 12)
                                            .frame(maxWidth: 200, maxHeight: 200))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                    .opacity(0.25)
                                    .frame(width: 200, height: 200)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 3, y: 3)
                                    .shadow(color: .white.opacity(0.7), radius: 6, x: -3, y: -3)
                                    .grayscale(1)
                            }
                            
                            Button(action: {
                                showingProfileImagePicker = true
                            }) {
                                Image("baseline_photo_library_black_24pt")
                            }
                            .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                            .sheet(isPresented: $showingProfileImagePicker, onDismiss: loadImage) {
                                ImagePicker(pickedImage: $profileImage) { imageDataDictionary in
                                    self.viewModel.setProfileImage(imageDataDictionary)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        defaultTitleText("Backdrop image")
                        
                        HStack(alignment: .top, spacing: 0) {
                            if let backdropImage = backdropImage {
                                Image(uiImage: backdropImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .mask(RoundedRectangle(cornerRadius: 12)
                                            .frame(maxWidth: 200, maxHeight: 200))
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                                    .opacity(0.25)
                                    .frame(width: 200, height: 200)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                    .shadow(color: .black.opacity(0.2), radius: 6, x: 3, y: 3)
                                    .shadow(color: .white.opacity(0.7), radius: 6, x: -3, y: -3)
                            }
                            
                            Button(action: {
                                showingBackdropImagePicker = true
                            }) {
                                Image("baseline_photo_library_black_24pt")
                            }
                            .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                            .sheet(isPresented: $showingBackdropImagePicker, onDismiss: loadImage) {
                                ImagePicker(pickedImage: $backdropImage) { imageDataDictionary in
                                    self.viewModel.setBackdropImage(imageDataDictionary)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Tags
                    Group {
                        defaultTitleText("Tags")
                        
                        defaultTextField("New tag (use , to separate tags)", text: $newTag)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            if newTag.isEmpty {
                                alertTitle = "Invalid new tag"
                                alertMessage = "New tag cannot be empty"
                                showToastAlert = true
                            } else {
                                newTag.split(separator: ",").forEach { tag in
                                    viewModel.appendNewTag(String(tag).trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                                newTag = ""
                            }
                        }) {
                            Text("Add new tag")
                        }
                        .frame(alignment: .trailing)
                        .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                        
                        if !viewModel.tags.isEmpty {
                            Divider()
                            
                            ForEach(viewModel.tags) { tag in
                                HStack(alignment: VerticalAlignment.center, spacing: 0) {
                                    defaultTagText(tag.tag)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 24)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                    Button(action: {
                                        if viewModel.deleteTag(tag) {
                                            NSLog("Tag \(tag.id) successfully deleted")
                                        }
                                    }) {
                                        Image("delete")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                                    .padding(.trailing, 16)
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    // Links
                    Group {
                        defaultTitleText("Links")
                        
                        VStack {
                            defaultTextField("New link title", text: $newLinkTitle)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                            defaultTextField("New link URL", text: $newLinkUrl)
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        Button(action: {
                            if newLinkTitle.isEmpty {
                                alertTitle = "Invalid new link"
                                alertMessage = "Link title should not be empty"
                                showToastAlert = true
                            } else if URL(string: newLinkUrl) == nil {
                                alertTitle = "Invalid new link"
                                alertMessage = "Link URL is invalid (cannot be parsed)"
                                showToastAlert = true
                            } else {
                                viewModel.appendNewLink(newLinkTitle, newLinkUrl)
                                newLinkTitle = ""
                                newLinkUrl = ""
                            }
                        }) {
                            Text("Add new link")
                        }
                        .frame(alignment: .trailing)
                        .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                        
                        if !viewModel.links.isEmpty {
                            Divider()
                            
                            ForEach(viewModel.links) { link in
                                HStack(alignment: VerticalAlignment.center, spacing: 0) {
                                    defaultLinkView(title: link.title, url: link.url)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if viewModel.deleteLink(link) {
                                            NSLog("Link \(link.id) successfully deleted")
                                        }
                                    }) {
                                        Image("delete")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        if username.isEmpty {
                            alertTitle = "Error"
                            alertMessage = "Username must not be empty"
                            showToastAlert = true
                        } else {
                            viewModel.createLsp3RequestBuilder.name = username
                            viewModel.createLsp3RequestBuilder.description = description
                            viewModel.create()
                        }
                    }) {
                        ZStack(alignment: .trailing) {
                            Text("Create new profile")
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.blue)
                            
                            if showCreatingProfileProgress {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(showCreatingProfileProgress)
                    .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                    .padding(16)
                }
//                .padding(.top, getTopPadding() + 16)
//                .padding(.bottom, getBottomPadding() + 16)
            }
            .alert(isPresented: $showToastAlert, content: {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Got it!")) {
                        showToastAlert = false
                    }
                )
            })
            
            if showCreatingProfileProgress {
                Color.black.opacity(0.25)
            }
        }
        .disabled(showCreatingProfileProgress)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
            
            viewModel.progress
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { progress in
                    self.showCreatingProfileProgress = progress
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.errorEvent
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    self.alertTitle = "Error"
                    self.alertMessage = error.description()
                    self.showToastAlert = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.lsp3Profile
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { createdProfileEvent in
                    if let _ = createdProfileEvent?.getIfNotConsumed() {
                        self.alertTitle = "Success!"
                        self.alertMessage = "Profile created successfully. You now should be able to see it in a \"Cached\" tab."
                        self.showToastAlert = true
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        }
    }
    
    func loadImage() {
        if let image = viewModel.getProfileUIImage() {
            profileImage = image
        }
        if let image = viewModel.getBackdropUIImage() {
            backdropImage = image
        }
    }
}

struct LSP3CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3CreateProfileView()
    }
}
