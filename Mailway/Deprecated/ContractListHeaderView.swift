//
//  ContractListHeaderView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-5-21.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI
import Combine

//class ContractListHeaderViewModel: ObservableObject {
//    let headerViewDidPressPublisher = PassthroughSubject<Void, Never>()
//    @Published var identities: [Contact] = []
//}
//
//struct ContractListHeaderView: View {
//    
//    @EnvironmentObject var viewModel: ContractListHeaderViewModel
//    var isAddMode = false
//    
//    var body: some View {
//        return Button(action: {
//            self.viewModel.headerViewDidPressPublisher.send()
//        }, label: {
//            HStack(spacing: 16) {
//                icon
//                text
//            }
//            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
//        })
//    }
//    
//    var icon: some View {
//        Group {
//            if viewModel.identities.isEmpty || isAddMode {
//                Image(systemName: "person.crop.circle.fill.badge.plus")
//            } else {
//                if viewModel.identities.count > 1 {
//                    Image(systemName: "rectangle.stack.person.crop.fill")
//                } else {
//                    Image(systemName: "person.crop.square.fill")
//                }
//            }
//        }
//        .font(.largeTitle)
//    }
//    
//    var title: String {
//        if viewModel.identities.isEmpty {
//            return "No Idenity"
//        } else {
//            return viewModel.identities.count > 1 ? "My Identities" : "My Identity"
//        }
//    }
//    var prompt: String {
//        if viewModel.identities.isEmpty || isAddMode {
//            return "Tap to add identity"
//        } else {
//            let count = viewModel.identities.count
//            return count > 1 ? "\(count) identities" : "\(count) identity"
//        }
//    }
//    
//    var text: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(title)
//                .font(.subheadline)
//                .fontWeight(.semibold)
//            Text(prompt)
//                .font(.caption)
//                .foregroundColor(Color(UIColor.secondaryLabel))
//        }
//    }
//    
//}
