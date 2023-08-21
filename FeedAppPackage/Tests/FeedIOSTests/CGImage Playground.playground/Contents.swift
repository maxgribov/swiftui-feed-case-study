import Foundation
import CoreGraphics
import ImageIO

extension CGImage {
    
    static func onePixelImage(withColor colorData: UInt32) -> CGImage? {
        
        var bitmap = [colorData]
        return bitmap.withUnsafeMutableBytes { ptr in
            
            let ctx = CGContext(
                data: ptr.baseAddress,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 8,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue + CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            return ctx?.makeImage()
        }
    }
    
    var pngData: Data? {
        
        guard let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else {
            
            return nil
        }
        
        CGImageDestinationAddImage(destination, self, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            
            return nil
        }
        
        return mutableData as Data
    }
    
    static func image(fromPng pngData: Data) -> CGImage? {
        
        guard let data = pngData as CFData?,
              let dataProvider: CGDataProvider = CGDataProvider(data: data) else {
            
            return nil
        }
        
        return CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}

let image = CGImage.onePixelImage(withColor: 0xffff0000)
let imageData = image?.pngData
let imageFromPng = CGImage.image(fromPng: imageData!)

imageData == imageFromPng?.pngData

