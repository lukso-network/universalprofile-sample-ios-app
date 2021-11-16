//
//  DefaultViewsFactory.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI

func defaultTextField(_ hint: String = "", text: Binding<String>) -> some View {
    return TextField(hint, text: text)
        .padding(16)
        .background(NeomorphicStyle.TextField.standard)
}

func defaultTitleText(_ title: String = "", _ font: Font = .caption2) -> some View {
    return Text(title)
        .font(font)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
        .padding(.leading, 24)
}

func defaultTagText(_ tag: String = "") -> some View {
    return Text(tag)
        .font(.subheadline)
        .foregroundColor(Color.white)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(LinearGradient(Color.purple.opacity(0.5), Color.blue)))
}

func defaultLinkView(title: String?, url: String?) -> some View {
    return
        VStack(alignment: .leading, spacing: 0) {
            Text(title ?? "-")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black.opacity(0.8))
                .font(.subheadline.bold())
                .padding(.top, 12)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            
            Text(url ?? "-")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.blue)
                .font(.subheadline)
                .padding(.bottom, 12)
                .padding(.leading, 16)
                .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .onTapGesture {
            if let rawUrl = url,
               let parsedUrl = URL(string: rawUrl),
               UIApplication.shared.canOpenURL(parsedUrl) {
                UIApplication.shared.open(parsedUrl, options: [:], completionHandler: nil)
            }
        }
}

func createTagsGrid(_ tags: [String]) -> some View {
    return LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible())],
                     alignment: .leading,
                     spacing: 36) {
        ForEach(tags) { tag in
            defaultTagText(tag)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

func createTagsGrid(_ tags: [LSP3ProfileTag]) -> some View {
    return createTagsGrid(tags.map { $0.tag })
}
