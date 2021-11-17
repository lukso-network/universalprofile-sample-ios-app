//
//  IdenticonsGridView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import Foundation
import SwiftUI
import universalprofile_ios_sdk

struct IdenticonsGridView: View {
    
    @StateObject private var identiconsSelector = DependencyInjectorContainer.resolve(IdenticonSelectorViewModel.self)!
    let identicon: Binding<Identicon?>
    
    private var isPreviousButtonDisabled: Bool {
        return !identiconsSelector.hasPrevious() || !identiconsSelector.canCreateIdenticons()
    }
    private var isNextButtonDisabled: Bool {
        return !identiconsSelector.canCreateIdenticons()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: {
                if identiconsSelector.hasPrevious() {
                    identiconsSelector.getPreviousPage()
                }
            }, label: {
                Image("arrow.left")
                    .resizable()
                    .scaledToFit()
            })
                .foregroundColor(isPreviousButtonDisabled ? Color.black.opacity(0.6) : Color.black)
                .frame(width: 24, height: 24, alignment: .center)
                .disabled(isPreviousButtonDisabled)
                .padding(.trailing, 12)
            
            if identiconsSelector.canCreateIdenticons() {
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())],
                          alignment: .center,
                          spacing: 40) {
                    ForEach(identiconsSelector.currentPageIdenticons) { identicon in
                        Image(uiImage: identicon.identiconData.createIdenticon())
                            .resizable()
                            .scaledToFit()
                            .mask(Circle())
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: getIdenticonStrokeWidth(identicon))
                            )
                            .shadow(color: Color(red: 43/255, green: 55/255, blue: 64/255).opacity(0.2), radius: 28, x: 0, y: 8)
                            .onTapGesture {
                                identiconsSelector.select(identicon)
                                withAnimation {
                                    self.identicon.wrappedValue = identicon
                                }
                            }
                    }
                }.frame(minWidth: 248, maxWidth: 300, minHeight: 248, maxHeight: 248)
            } else {
                VStack(alignment: .center, spacing: 0){
                    ProgressView()
                }.frame(width: 208, height: 208, alignment: .center)
            }
            
            Button(action: {
                identiconsSelector.getNextPage()
            }, label: {
                Image("arrow.right")
                    .resizable()
                    .scaledToFit()
            })
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(isNextButtonDisabled ? Color.black.opacity(0.6) : Color.black)
                .disabled(isNextButtonDisabled)
                .padding(.leading, 12)
        }
    }
    
    func getIdenticonStrokeWidth(_ identicon: Identicon) -> CGFloat {
        if identicon.isSelected {
            return 2
        } else {
            return 0
        }
    }
}
