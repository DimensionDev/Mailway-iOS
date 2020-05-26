//
//  Chats.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import SwiftUI

struct ChatsView: View {
    
    @EnvironmentObject var context: AppContext
    
    var body: some View {
        NavigationView {
            List(context.documentStore.chats, id: \.self) { chat in
                Text("hi")
            }
            .navigationBarTitle(Text("Chats"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.context.viewStateStore.chatsView.isCreateChatViewDisplay = true
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                })
                .padding([.leading, .top, .bottom])
            )
        }
        .sheet(isPresented: $context.viewStateStore.chatsView.isCreateChatViewDisplay) {
            CreateChatView()
        }
    }
    
}
