//
//  AvatarSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/24.
//

import SwiftUI

private let placeholderImage = ImageAttributes(withSFSymbol: "person.crop.circle.fill")

struct AvatarSettingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var allow_swipeclose = true
    @State private var image: ImageAttributes = placeholderImage
    @State private var allow_upload = false
    @State private var renderingMode: SymbolRenderingMode = .hierarchical
    @State private var renderingModeInt: Int = 1
    @State private var colors: [Color] = [.accentColor, Color(.systemTeal), Color.init(red: 248.0 / 255.0, green: 218.0 / 255.0, blue: 174.0 / 255.0)]
    @State private var themeColor: Color = Color.accentColor
    @State private var isEditMode: Bool = true
    @State var showSelectionPanel: Bool = false
    
    @State var isUploading = false
    
    func DoUploadAvatar() {
        Task {
            DispatchQueue.main.async {
                isUploading = true
                allow_upload = false
                allow_swipeclose = false
            }
            if let imageData = image.croppedImage!.jpegData(compressionQuality: 0.5) {
                let base64String = imageData.base64EncodedString(options: [])
                var toUpdate = LexueProfile.getNilObject()
                toUpdate.avatarBase64 = base64String
                await CoreLogicManager.shared.UpdateSelfProfile(toUpdate)
                DispatchQueue.main.async {
                    GlobalVariables.shared.userAvatarUIImage = image.croppedImage!
                }
            }
            DispatchQueue.main.async {
                allow_swipeclose = true
                allow_upload = true
                isUploading = false
                dismiss()
            }
        }
    }
    
    var body: some View {
        VStack {
            ImagePane(image: image,
                      isEditMode: $isEditMode,
                      renderingMode: renderingMode,
                      colors: colors,
                      showSelectionPanel: $showSelectionPanel)
            .frame(maxWidth: 300)
            .padding(.horizontal, 50)
            .foregroundColor(themeColor)
            Button {
                showSelectionPanel.toggle()
            } label: {
                Text("选择图片")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .padding(.top, 50)
            Button {
                DoUploadAvatar()
            } label: {
                Text("上传")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .disabled(!allow_upload)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
        .frame(maxWidth: 500)
        .interactiveDismissDisabled(!allow_swipeclose)
        .overlay {
            if isUploading {
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .background(.ultraThickMaterial)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10.0)
                                .shadow(radius: 20)
                                .overlay {
                                    VStack {
                                        ProgressView()
                                            .padding(.bottom, 10)
                                            .tint(.black)
                                        Text("上传中...")
                                            .foregroundColor(.black)
                                            .font(.system(size: 15))
                                    }
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: showSelectionPanel) { newVal in
            if newVal == false && image.croppedImage != nil {
                allow_upload = true
            }
        }
        .onAppear {
            if image.croppedImage != nil {
                allow_upload = true
            }
        }
//        .navigationTitle("设置头像")
    }
}

#Preview {
    AvatarSettingView()
}
