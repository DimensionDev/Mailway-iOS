//
//  LargeRoundedButtonStyle.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-9.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct LargeRoundedButtonStyle: ButtonStyle {
    
    @State var title: String = ""
    
    func makeBody(configuration: Configuration) -> some View {
        Text(title)
            .foregroundColor(.white)
            .padding()
            .frame(maxHeight: 44)
            .background(
                configuration.isPressed ? Color(Asset.Color.Background.blue.color.withAlphaComponent(0.8)) : Color(Asset.Color.Background.blue.color)
            )
            .cornerRadius(44 * 0.5)
    }
    
}
