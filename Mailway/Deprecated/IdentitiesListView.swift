//
//  IdentitiesListView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-22.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

//struct IdentitiesListView: View {
//    
//    @EnvironmentObject var context: AppContext
//    @Binding var identities: [Contact]
//    
//    @State var isPushToIdentityDetailView = false
//    
//    var body: some View {
//        List {
//            ContractListHeaderView(identities: $identities, isAddMode: true)
//                .frame(maxWidth: .infinity)
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    self.context.viewStateStore.contactsView.createIdentityViewDisplayTriggerSubject.send()
//                }
//            ForEach(identities, id: \.self) { identity in
//                NavigationLink(destination: IdentityDetailView(identity: identity)) {
//                    HStack {
//                        Image(systemName: "person.crop.circle.fill")
//                            .font(.system(size: 44))
//                        VStack {
//                            Text("\(identity.name)")
//                                .font(.subheadline)
//                                .fontWeight(.bold)
//                            Text("")
//                            Text("")
//                        }
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
//                }
//            }
//        }   // end List
//        .navigationBarTitle(Text("My Identity"), displayMode: .inline)
//    }
//    
//}
//
//struct IdentitiesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        IdentitiesListView(identities: .constant(Contact.samples))
//            .environmentObject(AppContext())
//    }
//}
