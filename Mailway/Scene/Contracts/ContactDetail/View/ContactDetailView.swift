//
//  ContactDetailView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-6-11.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import CoreDataStack

struct ContactDetailView: View {
    
    @ObservedObject var viewModel: ContactDetailViewModel
    
    var body: some View {
        Form {
            Section(header:
                VStack {
                    Image(systemName: "person.crop.square.fill")
                        .font(.system(size: 66.0))
                        .foregroundColor(Color(UIColor.label))
                        .padding(.top)
                        .padding(.bottom, 4)
                    Text(viewModel.contact.name)
                        .font(.system(size: 22.0, weight: Font.Weight.semibold))
                        .foregroundColor(Color(UIColor.label))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            , content: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                    // Text(viewModel.contact.email)
                    Text("Alice@gmail.com")
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                    Text("None")
                        .foregroundColor(.secondary)
                }
            })
            Section {
                Button(action: {
                    self.viewModel.removeButtonPressedPublisher.send()
                }, label: {
                    Text("Remove")
                        .foregroundColor(.red)
                })
            }
        }
    }
    
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let contact = Contact.insert(into: context, property: Contact.Property(name: "Alice"))
        
        let viewModel = ContactDetailViewModel(contact: contact)
        return ContactDetailView(viewModel: viewModel)
    }
}
