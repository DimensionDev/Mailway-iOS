//
//  String.swift
//  Mailway
//
//  Created by Cirno MainasuK on 2020-7-1.
//  Copyright © 2020 Dimension. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
    func toQRCode() -> UIImage? {
        guard let asciiData = self.data(using: .ascii) else { return nil }
        let qrCodeGenerator =  CIFilter.qrCodeGenerator()
        qrCodeGenerator.message = asciiData
        qrCodeGenerator.correctionLevel = "M"   // medium (L M Q H)

        let transform = CGAffineTransform(scaleX: 6, y: 6)  // 600 * 600
        guard let output = qrCodeGenerator.outputImage?.transformed(by: transform),
        let cgImage = CIContext().createCGImage(output, from: output.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
        
        return image
    }
}


extension String {
    
    static var encryptionMessageFileExtension: String {
        return "mem"
    }
    
    static var bizcardFileExtension: String {
        return "mbc"
    }
    
    static var identityProfileFileExtension: String {
        return "mip"
    }
    
    static var applicationBackupFileExtension: String {
        return "mbackup"
    }
    
}
