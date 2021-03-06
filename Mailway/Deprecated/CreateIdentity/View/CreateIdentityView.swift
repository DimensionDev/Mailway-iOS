//
//  CreateIdentityView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine
import CoreDataStack

final class CreateIdentityViewModel: ObservableObject {
    
    var disposeBag = Set<AnyCancellable>()
    
    // Input
    @Published var name = ""
    @Published var email = ""   // optional
    @Published var note = ""    // optional
    
    // output
    let contactProperty = CurrentValueSubject<Contact.Property?, Never>(nil)
    
    init() {
        Publishers.CombineLatest3($name, $email, $note)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name, email, note in
                guard let `self` = self else { return }
                
                let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else {
                    self.contactProperty.value = nil
                    return
                }
                
                let contactProperty = Contact.Property(name: name)
                //var contact = Contact()
                //contact.name = name
                //contact.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                //contact.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
                //contact.isIdentity = true
                
                self.contactProperty.value = contactProperty
            }
            .store(in: &disposeBag)
    }

}

struct CreateIdentityView: View {
    
    @ObservedObject var viewModel = CreateIdentityViewModel()
    @State var nameTextFieldDidBecomeFirstResponder = false
    
    var body: some View {
        Form {
            Section {
                AutoFocusTextField(text: $viewModel.name, didBecomeFirstResponder: nameTextFieldDidBecomeFirstResponder, placeholder: "Name")
            }
            Section(header: Text("Optional")) {
                TextField("Email", text: $viewModel.email)
                TextField("Note", text: $viewModel.note)
            }
        }
        .onAppear {
            if !self.nameTextFieldDidBecomeFirstResponder {
                self.nameTextFieldDidBecomeFirstResponder = true
            }
        }
    }
    
}

struct CreateIdentityView_Previews: PreviewProvider {
    static var previews: some View {
        CreateIdentityView()
    }
}
