//
//  LSP3ProfileDetailsView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift
import universalprofile_ios_sdk

struct LSP3ProfileDetailsView: View {
    
    private let disposeBag = DisposeBag()
    @State private var profile: LSP3Profile? = nil
    
    let viewModel = LSP3ProfileDetailsViewModel(DependencyInjectorContainer.resolve(LSP3ProfileRepository.self)!) 
    
    /// Hash in a following form: QmecrGejUQVXpW4zS948pNvcnQrJ1KiAoM6bdfrVcWZsn5
    let lsp3ProfileCid: String
    
    var body: some View {
        ZStack {
            LinearGradient(.lightStart, .lightEnd)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                if viewModel.progress {
                    ProgressView()
                        .frame(width: UIScreen.screenWidth,
                               height: UIScreen.screenHeight,
                               alignment: .center)
                } else if let error = viewModel.errorEvent.getIfNotConsumed() {
                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(Color.red.opacity(0.75))
                        .padding()
                } else if let profile = profile {
                    createProfileView(profile)
                }
                
                Divider()
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                
                Text(viewModel.rawProfileJson ?? "")
                    .padding()
                    .font(.body)
                    .foregroundColor(Color.gray)
            }
        }
        .disabled(viewModel.progress)
        .onAppear {
            viewModel.lsp3Profile
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { profile in
                    self.profile = profile
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
                
            viewModel.load(lsp3ProfileCid)
        }
    }
    
    private func createProfileView(_ profile: LSP3Profile) -> some View {
        return VStack(alignment: .leading, spacing: 0) {
            ZStack {
                CustomAsyncImage(withURL: profile.backgroundImage.first(where: { image in
                    image.height != nil && image.height! < 600 &&
                        image.width != nil && image.width! < 600
                })?.url ?? "",
                contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: UIScreen.screenWidth)
                .mask(Rectangle())
                
                CustomAsyncImage(withURL: profile.profileImage.first(where: { image in
                    image.height != nil && image.height! < 600 &&
                        image.width != nil && image.width! < 600
                })?.url ?? "",
                defaultImage: UIImage(named: "user_profile_icon")!,
                contentMode: .fill)
                .frame(width: 128, height: 128)
                .mask(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3).blur(radius: 3.0))
            }
            
            Text(profile.id)
                .colorScheme(.light)
                .font(.subheadline.italic())
                .foregroundColor(.gray)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            Text(profile.name)
                .colorScheme(.light)
                .font(.title3.bold())
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            
            if !profile.description.isEmpty {
                Text(profile.description)
                    .colorScheme(.light)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
            }
            
            if !profile.tags.isEmpty {
                createTagsGrid(profile.tags).padding(.all, 16)
            }
            
            if !profile.links.isEmpty {
                ForEach(profile.links) { link in
                    defaultLinkView(title: link.title, url: link.url)
                }.padding(.bottom, 16)
            }
        }
    }
}

struct LSP3ProfileDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfileDetailsView(lsp3ProfileCid: "QmecrGejUQVXpW4zS948pNvcnQrJ1KiAoM6bdfrVcWZsn5")
    }
}
