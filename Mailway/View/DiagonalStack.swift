//
//  DiagonalStack.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-17.
//  Copyright © 2020 Dimension. All rights reserved.
//

import SwiftUI

struct DiagonalStack<Element, Content: View> {
    let data: [Element]
    var scale: CGFloat = 0.7
    var content: (Element) -> Content
}


extension DiagonalStack: View {
    
    var body: some View {
        let count = data.count
        return GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(Array(self.data.enumerated()), id: \.offset, content: { index, element in
                    self.content(element)
                        .frame(width: self.scale * proxy.size.width, height: self.scale * proxy.size.height)
                        .mask(Circle().inset(by: 1))
                        .mask(
                            self.computeMask(index: index, total: count, scale: self.scale, size: proxy.size)
                            .fill(style: FillStyle(eoFill: true))
                        )
                        .offset(self.computeOffset(index: index, total: count, scale: self.scale, size: proxy.size))
                    
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
    
    func computeMask(index: Int, total: Int, scale: CGFloat, size: CGSize) -> Path {
        let contentSize = CGSize(width: scale * size.width, height: scale * size.height)
        let contentFrame = CGRect(origin: .zero, size: contentSize)
        guard index != total - 1 else {
            return Circle().path(in: contentFrame)
        }
        
        let currentOffset = computeOffset(index: index, total: total, scale: scale, size: size)
        let nextOffset = computeOffset(index: index + 1, total: total, scale: scale, size: size)

        var shape = Circle().path(in: contentFrame)
        
        shape.addPath(
            Circle()
                .offset(x: nextOffset.width - currentOffset.width,
                        y: nextOffset.height - currentOffset.height)
                .path(in:
                    contentFrame
                        .insetBy(dx: -UIScreen.main.scale, dy: -UIScreen.main.scale)
                )
        )
        return shape
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

