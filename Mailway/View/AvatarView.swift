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
    
    static let backgroundColors: [Color]  = [
        Color(Asset.Color.Background.blue.color),
        Color(Asset.Color.Background.blue400.color),
        Color(Asset.Color.Background.blue300.color),
    ]
    
    @Published var infos: [Info] = []
    
    init(infos: [Info] = []) {
        self.infos = infos
    }
    
    static func backgroundColor(at index: Int, total: Int) -> Color {
        guard index < total, index < backgroundColors.count else {
            return backgroundColors.first!
        }
        
        return backgroundColors.prefix(total).reversed()[index]
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
                    if viewModel.infos.first?.image != nil {
                        GeometryReader { proxy in
                            Image(uiImage: self.viewModel.infos.first?.image ?? UIImage.placeholder(color: .systemFill))
                                .resizable()
                                .cornerRadius(proxy.size.width * 0.5)
                        }
//                        Circle()
//                            .overlay(
//                            )
                    } else {
                        Circle()
                            .foregroundColor(Color(Asset.Color.Background.blue.color))
                        Text(String((viewModel.infos.first?.name ?? "A").prefix(1)))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            if viewModel.infos.count > 1 {
                DiagonalStack(data: Array(viewModel.infos.enumerated()), scale: 0.7) { i, item in
                    ZStack {
                        if self.viewModel.infos.first?.image != nil {
                            GeometryReader { proxy in
                                Image(uiImage: self.viewModel.infos.first?.image ?? UIImage.placeholder(color: .systemFill))
                                    .resizable()
                                    .cornerRadius(proxy.size.width * 0.5)
                            }
                        } else {
                            Rectangle()
                                .foregroundColor(AvatarViewModel.backgroundColor(at: i, total: self.viewModel.infos.count))
                            Text(String((item.name).prefix(1)))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct AvatarView_Previews: PreviewProvider {
    
    static let colors: [Color] = [.red, .green, .blue]
    
    static var previews: some View {
        Group {
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil)
            ]))
            .previewDisplayName("Single")
            
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil),
                AvatarViewModel.Info(name: "Bob", image: nil),
            ]))
            .previewDisplayName("Double")
            
            AvatarView(viewModel: AvatarViewModel(infos: [
                AvatarViewModel.Info(name: "Alice", image: nil),
                AvatarViewModel.Info(name: "Bob", image: nil),
                AvatarViewModel.Info(name: "Eve", image: nil),
            ]))
            .previewDisplayName("Multiple")
            
            DiagonalStack(data: colors) { item in
                Rectangle()
                    .fill(item)
            }
            .frame(width: 100, height: 100)
            .border(Color.black)
            .previewDisplayName("DiagonalStack")
        
        }
        .frame(width: 40, height: 40)
        .previewLayout(.fixed(width: 100, height: 100))
    }
}
#endif


