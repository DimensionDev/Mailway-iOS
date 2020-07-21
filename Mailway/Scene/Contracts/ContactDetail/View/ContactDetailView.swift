//
//  ContactDetailView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct ContactDetailView: View {
    
    @EnvironmentObject var context: AppContext
    @ObservedObject var viewModel: ContactDetailViewModel
    
    var body: some View {
        ProfileView(
            avatar: $viewModel.avatar,
            colorBarColor: .constant(.clear),
            name: $viewModel.name,
            isMyProfile: .constant(false),
            keyID: $viewModel.keyID,
            contactInfoDict: $viewModel.contactInfoDict,
            note: $viewModel.note,
            isPlaceholderHidden: $viewModel.isPlaceholderHidden,
            shareProfileAction: { self.viewModel.shareProfileActionPublisher.send(()) },
            copyKeyIDAction: { self.viewModel.copyKeyIDActionPublisher.send(()) }
        )
//        Form {
//            Section(header:
//                VStack {
//                    Image(systemName: "person.crop.square.fill")
//                        .font(.system(size: 66.0))
//                        .foregroundColor(Color(UIColor.label))
//                        .padding(.top)
//                        .padding(.bottom, 4)
//                    Text(viewModel.contact.name)
//                        .font(.system(size: 22.0, weight: Font.Weight.semibold))
//                        .foregroundColor(Color(UIColor.label))
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding()
//            , content: {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Email")
//                        .font(.system(size: 12, weight: .regular))
//                        .foregroundColor(.secondary)
//                    // Text(viewModel.contact.email)
//                    Text("Alice@gmail.com")
//                }
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Note")
//                        .font(.system(size: 12, weight: .regular))
//                        .foregroundColor(.secondary)
//                    Text("None")
//                        .foregroundColor(.secondary)
//                }
//            })
//            Section {
//                Button(action: {
//                    self.viewModel.removeButtonPressedPublisher.send()
//                }, label: {
//                    Text("Remove")
//                        .foregroundColor(.red)
//                })
//            }
//        }
    }
    
}

#if DEBUG
import CoreData
import CoreDataStack

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let managedObjectContext = AppContext.shared.managedObjectContext
        
        let keypairProperty = Keypair.Property(privateKey: nil, publicKey: "", keyID: "0816fe6c1edebe9fbb83af9102ad9c899abec1a87a1d123bc24bf119035a2853")
        let keypair = Keypair.insert(into: managedObjectContext, property: keypairProperty)
        
        let identityProperty = Contact.Property(name: "Alice", note: "Alice in the Book\nPhone Number: +00 123-456-7890", color: UIColor.pickPanelColors.randomElement()!)
        let channels: [ContactChannel] = [
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .twitter, value: "@alice")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .twitter, value: "@alice1")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .twitter, value: "@alice2")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .facebook, value: "Alice not alice")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .telegram, value: "Alice!")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .discord, value: "Alice#1234")),
            ContactChannel.insert(into: managedObjectContext, property: .init(name: .custom("about.me"), value: "Alice.about.me")),
        ]
        let contact = Contact.insert(into: managedObjectContext, property: identityProperty, keypair: keypair, channels: channels, businessCard: nil)   // empty businessCard only when preview
        
        let viewModel = ContactDetailViewModel(context: AppContext.shared, contact: contact)
        return ContactDetailView(viewModel: viewModel)
            .environmentObject(AppContext.shared)
    }
}
#endif
