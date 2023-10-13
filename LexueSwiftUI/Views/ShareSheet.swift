//
//  ShareSheet.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/13.
//

import SwiftUI
import LinkPresentation

struct ShareSheet: UIViewControllerRepresentable {
    let photo: UIImage?
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = self.text
        let itemSource = ShareActivityItemSource(shareText: text, shareImage: photo)
        
        let activityItems: [Any] = [photo, text, itemSource]
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)
        
        return controller
    }
      
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {
    }
}

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    
    var shareText: String
    var shareImage: UIImage?
    var linkMetaData = LPLinkMetadata()
    
    init(shareText: String, shareImage: UIImage?) {
        self.shareText = shareText
        self.shareImage = shareImage
        linkMetaData.title = shareText
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "AppIcon ") as Any
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetaData
    }
}
