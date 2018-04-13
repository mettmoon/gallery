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
class GettyItem:NSObject {
    var title:String
    var imageURL:URL
    var pageURL:URL
    var referText:String?
    var detailText:String?
    var infoText:String?
    var detailImageURL:URL?
    init(title:String, imageURL:URL, pageURL:URL) {
        self.title = title
        self.imageURL = imageURL
        self.pageURL = pageURL
    }
}
//과제 URL
let kTestURL = URL(string:"http://www.gettyimagesgallery.com/collections/archive/slim-aarons.aspx")!

//GettyImageGallery에서 이미지정보를 당겨와 관리하는 클래스
class GettyManager: NSObject {
    //http응답으로 부터 이미지정보들을 반환
    func loadGetty(completion:@escaping (([GettyItem]?) -> ())) {
        DispatchQueue.global().async {
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
extension GettyItem {
    func loadDetailData(completion:@escaping (() -> Void)){
        DispatchQueue.global().async {
            guard let doc = try? HTML(url: self.pageURL, encoding: .utf8) else {
                NSLog("HTML 파싱 실패")
                completion()
                return
            }
            
            //구문 해석 오류 있어서 2줄로 나눔
            let divs = doc.body?.css("div").filter{$0["class"] == "proddetails"}
            guard let div = divs?.first else {
                NSLog("페이지가 잘못 됐나?")
                completion()
                return
            }
            
            let title = div.css("h3").first?.innerHTML
            let pItems = div.css("p").filter{_ in true}
            let referText = pItems[0].innerHTML
            let detailText = pItems[1].innerHTML
            let infoText = pItems[2].innerHTML
            self.referText = referText
            self.detailText = detailText
            self.infoText = infoText
            let images = doc.body?.css("img").filter{$0["id"] == "ctl00_ContentPlaceHolder1_mainImage"}
            if let imageURLString = images?.first?["src"] {
                self.detailImageURL = URL(string: imageURLString, relativeTo: self.pageURL)
            }
            completion()
        }
        
    }
}
