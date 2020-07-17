//
//  DiagonalStack.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct DiagonalStack<Element, Content: View> {
    var data: [Element]
    var scale: CGFloat = 0.7
    var content: (Element) -> Content
}


extension DiagonalStack: View {
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(self.data.indices, content: { ix in
                    self.content(self.data[ix])
                        .frame(width: 0.7 * proxy.size.width, height: 0.7 * proxy.size.height)
                        .offset(self.computeOffset(index: ix, total: self.data.count, scale: self.scale, size: proxy.size))
                })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func computeOffset(index: Int, total: Int, scale: CGFloat, size: CGSize) -> CGSize {
        guard total > 1, index < total else {
            return .zero
        }
        
        let itemSize = CGSize(width: scale * size.width, height: scale * size.height)
        
        let begin = CGSize(width: 0.5 * (size.width - itemSize.width), height: 0.5 * (size.height - itemSize.height))
        let end = CGSize(width: -0.5 * (size.width - itemSize.width), height: -0.5 * (size.height - itemSize.height))
        
        // Interpolation
        let offset = CGSize(
            width: begin.width + (end.width - begin.width) * CGFloat(index) / CGFloat(total - 1),
            height: begin.height + (end.height - begin.height) * CGFloat(index) / CGFloat(total - 1)
        )
        
        return offset
    }
}

#if DEBUG
struct DiagonalStack_Previews: PreviewProvider {
    
    static let colors: [Color] = [.red, .green, .blue]
    
    static var previews: some View {
        Group {
            DiagonalStack(data: [Color.green, Color.red]) { item in
                Rectangle()
                    .fill(item)
            }
            .border(Color.black)
            .previewDisplayName("DiagonalStack - 2")
            
            DiagonalStack(data: colors) { item in
                Rectangle()
                    .fill(item)
            }
            .border(Color.black)
            .previewDisplayName("DiagonalStack - 3")
            
        }
        .frame(width: 100, height: 100)
        .previewLayout(.fixed(width: 150, height: 150))
    }
}
#endif

