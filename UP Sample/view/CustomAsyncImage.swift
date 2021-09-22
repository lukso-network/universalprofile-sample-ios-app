//
//  CustomAsyncImage.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI

struct CustomAsyncImage: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image = UIImage()
    @State private var isLoading = true
    private let defaultImage: UIImage?
    private let contentMode: ContentMode
    
    /**
     - Parameters:
        - url: is a pointer to an image on some external/internal repository
        - defaultImage: image to show if the url couldn't be parsed or the resource wasn't found
     */
    init(withURL url: String, defaultImage: UIImage? = nil, contentMode: ContentMode = .fit) {
        imageLoader = ImageLoader(urlString: url)
        self.defaultImage = defaultImage
        self.contentMode = contentMode
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .onReceive(imageLoader.didChange) { data in
                    self.isLoading = false
                    if let data = data, let image = UIImage(data: data) {
                        self.image = image
                    } else if let defaultImage = defaultImage {
                        self.image = defaultImage
                    }
                }
            
            if isLoading {
                ProgressView()
            }
        }
    }
}

struct AsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        CustomAsyncImage(withURL: "https://developer.apple.com/swift/images/swift-og.png")
    }
}
