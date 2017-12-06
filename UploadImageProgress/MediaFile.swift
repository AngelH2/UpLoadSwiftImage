import Foundation
import UIKit

struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forkey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "\(arc4random())" //Name of file
        guard let data = UIImageJPEGRepresentation(image, 0.0) else {return nil}
        self.data = data
    }
}













