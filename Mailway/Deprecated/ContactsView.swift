//
//  ContactsView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-20.
//  Copyright © 2020 Dimension. All rights reserved.
//

import os
import SwiftUI
import Combine

//class ContactsViewModel: ObservableObject {
//    
//    var disposeBag = Set<AnyCancellable>()
//    
//    @Published var identities: [Contact] = []
//    @Published var contacts: [String: [Contact]] = [:]
//        
//    let contactsSubject = PassthroughSubject<[Contact], Never>()
//    var contactsSubscription: AnyCancellable?
//    
//    init() {
//        contactsSubject
//            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//            .map { contacts in
//                contacts
//                    .filter { $0.isIdentity }
//                    .sorted(by: { $0.name < $1.name })
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.identities, on: self)
//            .store(in: &disposeBag)
//        
//        contactsSubject
//            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//            .map { contacts in contacts.filter { !$0.isIdentity } }
//            .map { contacts in
//                Dictionary(grouping: contacts, by: { String($0.name.first ?? "#") })
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.contacts, on: self)
//            .store(in: &disposeBag)
//    }
//    
//}
//
//struct ContactsView: View {
//    
//    @EnvironmentObject var context: AppContext
//    @ObservedObject var viewModel = ContactsViewModel()
//    
//    @State var contactsListPushIdentitiesList = false
//    
//    var body: some View {
//        self.viewModel.contactsSubscription = self.context.documentStore.$contacts
//            .sink(receiveValue: { contacts in
//                self.viewModel.contactsSubject.send(contacts)
//            })
//        
//        return NavigationView {
//            List {
//                NavigationLink(destination: IdentitiesListView(identities: .constant([Contact()])), isActive: self.$contactsListPushIdentitiesList) {
//                    EmptyView()
//                }.hidden()
//                Section() {
//                    ContractListHeaderView(identities: $viewModel.identities)
//                        .frame(maxWidth: .infinity)
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            if self.viewModel.identities.isEmpty {
//                                // trigger create identity
//                                self.context.viewStateStore.contactsView.createIdentityViewDisplayTriggerSubject.send()
//                            } else {
//                                self.contactsListPushIdentitiesList = true
//                            }
//                    }
//                }
//                ForEach(Array(viewModel.contacts.keys).sorted(), id: \.self) { key in
//                    Section(header: Text(key)) {
//                        ForEach(self.viewModel.contacts[key] ?? [], id: \.id) { contact in
//                            Text(contact.name)
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle(Text("Contacts"), displayMode: .inline)
//            .navigationBarItems(trailing:
//                Button(action: {
//                    // self.context.viewStateStore.chatsView.isCreateChatViewDisplay = true
//                }, label: {
//                    Image(systemName: "plus")
//                        .font(.system(size: 20))
//                })
//                    .padding([.leading, .top, .bottom])
//            )
//        }
//    }
//    
//}
//
//struct ContactsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactsView()
//            .environmentObject(AppContext())
//    }
//}
