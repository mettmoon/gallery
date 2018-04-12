//
//  GettyManager.swift
//  gallery
//
//  Created by Peter Moon on 12/04/2018.
//  Copyright © 2018 Peter. All rights reserved.
//

import UIKit
import Kanna


//gettyimagesgallery.com 사이트의 이미지 정보
struct GettyItem {
    var title:String
    var imageURL:URL
    var pageURL:URL
}
//과제 URL
let kTestURL = URL(string:"http://www.gettyimagesgallery.com/collections/archive/slim-aarons.aspx")!

//GettyImageGallery에서 이미지정보를 당겨와 관리하는 클래스
class GettyManager: NSObject {
    //http응답으로 부터 이미지정보들을 반환
    func loadGetty(completion:(([GettyItem]?) -> ())) {
        guard let doc = try? HTML(url: kTestURL, encoding: .utf8) else {
            NSLog("HTML 파싱 실패")
            completion(nil)
            return
        }
        let divs = doc.body!.css("div").filter { (element:XMLElement) -> Bool in return element["class"] == "gallery-item-group exitemrepeater" }
        var items:[GettyItem] = []
        for div in divs {
            guard let pageURLString = div.css("a").first?["href"],
                let title = div.css("a")[1].innerHTML,
                let imageURLString = div.css("img").first?["src"]
                else{
                    NSLog("파싱 실패")
                    continue
            }
            
            guard let imageURL = URL(string: imageURLString, relativeTo: kTestURL),
                let pageURL = URL(string: pageURLString, relativeTo: kTestURL) else{
                    NSLog("유효하지 않은 URL")
                    continue
            }
            let item = GettyItem(title: title, imageURL: imageURL, pageURL: pageURL)
            items.append(item)
        }
        completion(items)

    }

}
class ImageDownloader:NSObject {
    let imageCache = NSCache<NSString, UIImage>()
    static let shared = ImageDownloader()
}
extension URL {
    func cachedImage() -> UIImage? {
        return ImageDownloader.shared.imageCache.object(forKey: self.absoluteString as NSString)
    }
    func downloadImage(_ completion: ((UIImage?, Error?) -> Void)?) {
        
        if let cachedImage = self.cachedImage() {
            completion?(cachedImage, nil)
        } else {
            URLSession(configuration: .default).dataTask(with: self) { (data, response, error) in
                if let error = error {
                    completion?(nil, error)
                } else if let data = data, let image = UIImage(data: data) {
                    ImageDownloader.shared.imageCache.setObject(image, forKey: self.absoluteString as NSString)
                    completion?(image, nil)
                } else {
                    let error = NSError(domain: self.absoluteString, code: 1234, userInfo: nil)
                    completion?(nil, error)
                }
            }.resume()
        }

    }
}
