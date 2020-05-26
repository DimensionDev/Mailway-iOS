//
//  SettingsView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var context: AppContext
    
    var body: some View {
        NavigationView {
            List {
                Text("Settings")
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
        }
    }
}
