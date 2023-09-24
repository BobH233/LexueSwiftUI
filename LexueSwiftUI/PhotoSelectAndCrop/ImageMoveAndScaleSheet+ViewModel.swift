//
//  ImageMoveAndScaleSheet+ViewModel.swift
//  PhotoSelectAndCrop
//
//  Created by Dave Kondris on 22/11/21.
//

import SwiftUI

extension ImageMoveAndScaleSheet {
    
    class ViewModel: ObservableObject {
        
        @Published var image = Image(systemName: "star.fill")
        @Published var originalImage: UIImage?
        @Published var scale: CGFloat = 1.0
        @Published var xWidth: CGFloat = 0.0
        @Published var yHeight: CGFloat = 0.0
        var position: CGSize {
            get {
                return CGSize(width: xWidth, height: yHeight)
            }
        }
        //Localized strings
        let moveAndScale = "移动和缩放"
        let selectPhoto = "点击相册图标选择图片"
        let cancelSheet = "取消"
        let usePhoto = "使用照片"

        func updateImageAttributes(_ imageAttributes: ImageAttributes) {
            imageAttributes.image = image
            imageAttributes.originalImage = originalImage
            imageAttributes.scale = scale
            imageAttributes.xWidth = position.width
            imageAttributes.yHeight = position.height
        }
        
        func loadImageAttributes(_ imageAttributes: ImageAttributes) {
            self.image = imageAttributes.image
            self.originalImage = imageAttributes.originalImage
            self.scale = imageAttributes.scale
            self.xWidth = imageAttributes.position.width
            self.yHeight = imageAttributes.position.height
        }
    }
}
