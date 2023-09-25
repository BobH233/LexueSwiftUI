//
//  AvatarSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/24.
//

import SwiftUI

let placeholderImage = ImageAttributes(withSFSymbol: "person.crop.circle.fill")

struct AvatarSettingView: View {
    
    @State private var image: ImageAttributes = placeholderImage
    @State private var allow_upload = false
    @State private var renderingMode: SymbolRenderingMode = .hierarchical
    @State private var renderingModeInt: Int = 1
    @State private var colors: [Color] = [.accentColor, Color(.systemTeal), Color.init(red: 248.0 / 255.0, green: 218.0 / 255.0, blue: 174.0 / 255.0)]
    @State private var themeColor: Color = Color.accentColor
    @State private var isEditMode: Bool = true
    @State var showSelectionPanel: Bool = false
    
    func DoUploadAvatar() {
        Task {
            DispatchQueue.main.async {
                GlobalVariables.shared.LoadingText = "上传中"
                GlobalVariables.shared.isLoading = true
            }
            if let imageData = image.croppedImage!.jpegData(compressionQuality: 1.0) {
                let base64String = imageData.base64EncodedString(options: [])
                var toUpdate = LexueProfile.getNilObject()
                toUpdate.avatarBase64 = base64String
                await CoreLogicManager.shared.UpdateSelfProfile(toUpdate)
                DispatchQueue.main.async {
                    GlobalVariables.shared.userAvatarUIImage = image.croppedImage!
                }
            }
            DispatchQueue.main.async {
                GlobalVariables.shared.isLoading = false
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
        .navigationTitle("设置头像")
    }
}

#Preview {
    AvatarSettingView()
}
