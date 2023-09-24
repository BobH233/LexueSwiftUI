//
//  ImagePane.swift
//  PhotoSelectAndCrop
//
//  Created by Dave Kondris on 18/11/21.
//

import SwiftUI

public struct ImagePane: View {
    
    
    @Binding var isShowingPhotoSelectionSheet: Bool
    // @State private var isShowingPhotoSelectionSheet = false
    
    @ObservedObject public var imageAttributes: ImageAttributes
    
    @Binding var isEditMode: Bool
    
    @State private var addPhotoButtonLabel = "添加照片"
    @State private var changePhotoButtonLabel = "修改照片"
    
    var renderingMode: SymbolRenderingMode = .monochrome
    var colors: [Color] = []
    var linearGradient: LinearGradient = LinearGradient(colors: [], startPoint: .topLeading, endPoint: .bottomTrailing)
    var isGradient: Bool = false
    ///A UIImage that is retrieved to be sent to the finalImage and displayed.
    ///It may be retrieved from the originalImage if one has been
    ///saved previously. Or it may be retrieved
    ///from the ImageMoveAndScaleSheet.
    @State private var inputImage: UIImage?
    
    public init(image: ImageAttributes, isEditMode: Binding<Bool>, showSelectionPanel: Binding<Bool>) {
        self._imageAttributes = ObservedObject(initialValue: image)
        self._isEditMode = isEditMode
        self._isShowingPhotoSelectionSheet = showSelectionPanel
    }
    
    public init(image: ImageAttributes, isEditMode: Binding<Bool>, renderingMode: SymbolRenderingMode,  showSelectionPanel: Binding<Bool>) {
        self._imageAttributes = ObservedObject(initialValue: image)
        self._isEditMode = isEditMode
        self.renderingMode = renderingMode
        self._isShowingPhotoSelectionSheet = showSelectionPanel
    }
    
    public init(image: ImageAttributes, isEditMode: Binding<Bool>, renderingMode: SymbolRenderingMode, colors: [Color], showSelectionPanel: Binding<Bool>) {
        self._imageAttributes = ObservedObject(initialValue: image)
        self._isEditMode = isEditMode
        self.renderingMode = renderingMode
        self.colors = []
        self._isShowingPhotoSelectionSheet = showSelectionPanel
        for color in colors {
            self.colors.append(color)
        }
    }
    
    public init(image: ImageAttributes, isEditMode: Binding<Bool>, renderingMode: SymbolRenderingMode, linearGradient: LinearGradient, showSelectionPanel: Binding<Bool>) {
        self._imageAttributes = ObservedObject(initialValue: image)
        self._isEditMode = isEditMode
        self.renderingMode = renderingMode
        self.linearGradient = linearGradient
        self.isGradient = true
        self._isShowingPhotoSelectionSheet = showSelectionPanel
    }
    
    private init(addPhotoText: String, changePhotoText: String, image: ImageAttributes, defaultImage: UIImage, isEditMode: Binding<Bool>, showSelectionPanel: Binding<Bool>) {
        self._imageAttributes = ObservedObject(initialValue: image)
        self._isEditMode = isEditMode
        self._isShowingPhotoSelectionSheet = showSelectionPanel
        self.addPhotoButtonLabel = addPhotoText
        self.changePhotoButtonLabel = changePhotoText
    }
    
    public var body: some View {
        
        VStack {
            displayImage
//            Button (action: {
//                self.isShowingPhotoSelectionSheet = true
//            }, label: {
//                if imageAttributes.originalImage != nil {
//                    Text(changePhotoButtonLabel)
//                        .font(.footnote)
//                        .foregroundColor(Color.accentColor)
//                } else {
//                    Text(addPhotoButtonLabel)
//                        .font(.footnote)
//                        .foregroundColor(Color.accentColor)
//                }
//            })
//            .opacity(isEditMode ? 1.0 : 0.0)
        }
        .fullScreenCover(isPresented: $isShowingPhotoSelectionSheet) {
            ImageMoveAndScaleSheet(imageAttributes: imageAttributes)
        }
    }
    
    ///A View that "displays" the image.
    ///
    /// - Note: This requires the `inputImage` be viable.
    private var displayImage: some View {
        
        imageAttributes.image
            .resizable()
            .symbolRenderingMode(renderingMode)
            .modifier(RenderingForegroundStyle(colors: colors, isGradient: isGradient, linearGradient: linearGradient))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .scaledToFill()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
            .shadow(radius: (imageAttributes.originalImage == nil) ? 0 : 4)
    }
}

