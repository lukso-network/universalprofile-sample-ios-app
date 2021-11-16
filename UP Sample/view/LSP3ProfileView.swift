//
//  LSP3ProfileView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import universalprofile_ios_sdk

struct LSP3ProfileView: View {
    
    let profile: IdentifiableLSP3Profile
    
    @State private var didCopyContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0)  {
            createProfileImageView()
            
            Text(profile.id)
                .colorScheme(.light)
                .font(.subheadline.italic())
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            
            Text(profile.lsp3Profile.name)
                .colorScheme(.light)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            
            createProfileDescriptionView()
            createProfileTagsView()
            createProfileLinksView()
        }
        
        //        .onLongPressGesture {
        //            UIPasteboard.general.string = profile.id
        //            didCopyContent = true
        //        }
        .alert(isPresented: $didCopyContent) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.didCopyContent = false
            }
            return Alert(title: Text("Copied profile ID to clipboard"))
        }
    }
    
    @ViewBuilder
    private func createProfileDescriptionView() -> some View {
        if !profile.lsp3Profile.description.isEmpty {
            Text(profile.lsp3Profile.description)
                .colorScheme(.light)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private func createProfileTagsView() -> some View {
        if !profile.lsp3Profile.tags.isEmpty {
            createTagsGrid(profile.lsp3Profile.tags)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    private func createProfileLinksView() -> some View {
        if !profile.lsp3Profile.links.isEmpty {
            ForEach(profile.lsp3Profile.links) { link in
                defaultLinkView(title: link.title, url: link.url)
                    .padding(.top, 16)
            }
        }
    }
    
    @ViewBuilder
    private func createProfileImageView() -> some View {
        ZStack {
            CustomAsyncImage(withURL: profile.lsp3Profile.backgroundImage.first(where: { image in
                image.height != nil && image.height! < 600 &&
                image.width != nil && image.width! < 600
            })?.url ?? "",
                             contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: UIScreen.screenWidth - 32)
                .mask(Rectangle())
            
            CustomAsyncImage(withURL: profile.lsp3Profile.profileImage.first(where: { image in
                image.height != nil && image.height! < 600 &&
                image.width != nil && image.width! < 600
            })?.url ?? "",
                             defaultImage: UIImage(named: "user_profile_icon")!,
                             contentMode: .fill)
                .frame(width: 128, height: 128)
                .mask(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3).blur(radius: 3.0))
        }
    }
}

struct LSP3ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LSP3ProfileView(profile: IdentifiableLSP3Profile.init(id: UUID().uuidString,
                                                              lsp3Profile: LSP3Profile(name: "Preview profile",
                                                                                       description: "Some legnthy description\n\t\t(not really)",
                                                                                       links: [LSP3ProfileLink(title: "Link 1", url: "ipfs://QmMultihash")],
                                                                                       tags: ["tag1", "tag2", "tag3", "tag3000"],
                                                                                       profileImage: [],
                                                                                       backgroundImage: [])))
    }
}

