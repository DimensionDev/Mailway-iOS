//
//  AvatarView.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import Foundation
import SwiftUI

struct AvatarView: View {
    
    @State var infos: [Info] = []
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(Asset.Color.Background.blue.color))
        }
    }
}

extension AvatarView {
    struct Info {
        let name: String
        let image: UIImage?
    }
}

#if DEBUG
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
            .previewLayout(.fixed(width: 40, height: 40))
    }
}
#endif
