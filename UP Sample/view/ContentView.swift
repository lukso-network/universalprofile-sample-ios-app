//
//  ContentView.swift
//  UP Sample
//
//  Created by JeneaVranceanu.
//  LUKSO Blockchain GmbH © 2021
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            TabView {
                ERC725IdentityView().tabItem {
                    Image("baseline_blur_circular_black_24pt")
                    Text("Anonymous")
                }
                .preferredColorScheme(.light)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                
                LSP3ProfilesListView().tabItem {
                    Image("baseline_people_alt_black_24pt")
                    Text("Cached")
                }
                .preferredColorScheme(.light)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                
                LSP3CreateProfileView().tabItem {
                    Image("baseline_group_add_black_24pt")
                    Text("Create")
                }
                .preferredColorScheme(.light)
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
