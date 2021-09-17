//
//  ContentView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI
import RxSwift

struct ContentView: View {
    
    var body: some View {
            TabView {
                ERC725IdentityView().tabItem {
                    Image("baseline_blur_circular_black_24pt")
                    Text("Anonymous")
                }
                .preferredColorScheme(.light)
                
                LSP3ProfilesListView().tabItem {
                    Image("baseline_people_alt_black_24pt")
                    Text("Cached")
                }
                .preferredColorScheme(.light)
                
                LSP3CreateProfileView().tabItem {
                    Image("baseline_group_add_black_24pt")
                    Text("Create")
                }
                .preferredColorScheme(.light)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
