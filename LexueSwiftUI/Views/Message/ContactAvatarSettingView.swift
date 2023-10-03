//
//  ContactAvatarSettingView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/3.
//

import SwiftUI


struct ContactAvatarSettingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var targetContactUid = ""
    @State var allow_swipeclose = true
    @State private var image: ImageAttributes = ImageAttributes(withSFSymbol: "person.crop.circle.fill")
    @State private var allow_upload = false
    @State private var renderingMode: SymbolRenderingMode = .hierarchical
    @State private var renderingModeInt: Int = 1
    @State private var colors: [Color] = [.accentColor, Color(.systemTeal), Color.init(red: 248.0 / 255.0, green: 218.0 / 255.0, blue: 174.0 / 255.0)]
    @State private var themeColor: Color = Color.accentColor
    @State private var isEditMode: Bool = true
    @State var showSelectionPanel: Bool = false
    
    
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
                if let imageData = image.croppedImage!.jpegData(compressionQuality: 0.5) {
                    let base64String = imageData.base64EncodedString(options: [])
                    if let contact = DataController.shared.findContactStored(contactUid: targetContactUid, context: managedObjContext) {
                        contact.avatar_data = base64String
                    }
                    DataController.shared.save(context: managedObjContext)
                    ContactsManager.shared.GenerateContactDisplayLists(context: managedObjContext)
                }
                dismiss()
            } label: {
                Text("确定设置")
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .disabled(!allow_upload)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
        .interactiveDismissDisabled(!allow_swipeclose)
        .onDisappear {
//            print("clear avatar selector")
//            image = ImageAttributes(withSFSymbol: "person.crop.circle.fill")
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
    }
}
