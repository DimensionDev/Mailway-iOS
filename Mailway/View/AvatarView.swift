//
//  AvatarView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import SwiftUI

final class AvatarViewModel: ObservableObject {
    @Published var infos: [Info] = []
    
    init(infos: [Info] = []) {
        self.infos = infos
    }
}

extension AvatarViewModel {
    struct Info {
        let name: String
        let image: UIImage?
    }
}

struct AvatarView: View {
    
    @ObservedObject var viewModel: AvatarViewModel
    
    var body: some View {
        Group {
            if viewModel.infos.count <= 1 {
                ZStack {
                    Circle()
                        .foregroundColor(Color(Asset.Color.Background.blue.color))
                    Text(String((viewModel.infos.first?.name ?? "A").prefix(1)))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            if viewModel.infos.count == 2 {
                EmptyView()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil)
            ]))
            .previewLayout(.fixed(width: 40, height: 40))
            .previewDisplayName("Single")
            
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil),
                AvatarViewModel.Info(name: "Bob", image: nil),
            ]))
            .previewLayout(.fixed(width: 40, height: 40))
            .previewDisplayName("Double")
            
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil),
                AvatarViewModel.Info(name: "Bob", image: nil),
                AvatarViewModel.Info(name: "Eve", image: nil),
            ]))
            .previewLayout(.fixed(width: 40, height: 40))
            .previewDisplayName("Multiple")
        }
    }
}
#endif
