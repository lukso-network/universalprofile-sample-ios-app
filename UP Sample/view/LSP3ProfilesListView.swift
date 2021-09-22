//
//  LSP3ProfilesListView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct LSP3ProfilesListView: View {
    let disposeBag = DisposeBag()
    let viewModel = DependencyInjectorContainer.resolve(LSP3ProfileListViewModel.self)!
    
    @State private var fileHash: String = "QmaufE68Q6cdnFJk6VQvvkXgqP3x8Hfp8bhqrjijeRHrnh"
    @State private var isSearchButtonEnabled = true
    @State private var profiles: [LSP3Profile] = []
    
    @State private var showAlert = false
    @State private var alertMessage: String? = nil
    @State private var showProgress = false
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
            
            VStack {
                HStack {
                    TextField("Hash", text: $fileHash) { isEditing in
                        // Ignored
                    } onCommit: {
                        isSearchButtonEnabled = !fileHash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .padding(.leading, 32)
                    .padding(.trailing, 32)
                    .background(NeomorphicStyle.TextField.standard)
                    
                    Button(action: {
                        viewModel.searchProfile(fileHash)
                    }, label: {
                        Text("Search").foregroundColor(.black.opacity(0.7))
                    }).disabled(!isSearchButtonEnabled)
                    .buttonStyle(NeomorphicStyle.Button.standardRoundedRect)
                    .padding(.trailing, 16)
                }
                
                Divider().padding(.leading, 16).padding(.trailing, 16)
                
                Group {
                    Text("Cached profiles")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                    
                    ScrollView{
                        ForEach(profiles, id: \.self) { profile in
                            LSP3ProfileRow(profile: profile).listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .padding(.top, getTopPadding())
            .padding(.bottom, getBottomPadding())
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.progress
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isInProgress in
                    self.showProgress = isInProgress
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            viewModel.lsp3Profiles
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { profiles in
                    self.profiles = profiles
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            viewModel.errorEvent
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { error in
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
            
            viewModel.load()
        }
    }
}

struct LSP3ProfileRow: View {
    var profile: LSP3Profile
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MyAsyncImage(withURL: profile.backgroundImage.first(where: { image in
                    image.height != nil && image.height! < 600 &&
                        image.width != nil && image.width! < 600
                })?.url ?? "")
                .frame(height: 200)
                .mask(Rectangle())
                
                MyAsyncImage(withURL: profile.profileImage.first(where: { image in
                    image.height != nil && image.height! < 600 &&
                        image.width != nil && image.width! < 600
                })?.url ?? "", defaultImage: UIImage(named: "user_profile_icon")!)
                .frame(width: 128, height: 128)
                .mask(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3).blur(radius: 3.0))
            }
            
            Text(profile.id)
                .colorScheme(.light)
                .font(.subheadline.italic())
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            Text(profile.name)
                .colorScheme(.light)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            
            if !profile.description.isEmpty {
                Text(profile.description)
                    .colorScheme(.light)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
            }
            
            if !profile.tags.isEmpty {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible())], alignment: HorizontalAlignment.center, spacing: 4 ) {
                    ForEach(profile.tags) { tag in
                        defaultTagText(tag)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }.padding(.all, 16)
//                Text(profile.tags.joined(separator: ","))
//                    .colorScheme(.light)
//                    .font(.caption2.italic())
//                    .foregroundColor(.black.opacity(0.8))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.top, 8)
//                    .padding(.leading, 16)
//                    .padding(.trailing, 16)
            }
            
            if !profile.links.isEmpty {
                Text(profile.links.map { "[\($0.title!), \($0.url!)]" }.joined(separator: ","))
                    .colorScheme(.light)
                    .foregroundColor(.black.opacity(0.8))
                    .font(.caption2.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 9))
        .background(RoundedRectangle(cornerRadius: 9).fill(Color.lightStart)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 3, y: 3)
                        .shadow(color: .white.opacity(0.7), radius: 10, x: -2, y: -2))
        .padding(8)
    }
}

struct LSP3ProfilesListView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfilesListView()
    }
}


