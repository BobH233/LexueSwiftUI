//
//  DebugDataView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import SwiftUI

struct DebugDataView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var senderUid: String = ""
    var msgtype = [MessageBodyType.text, MessageBodyType.link, MessageBodyType.image]
    var msgtypeStr = ["text", "image", "link"]
    @State var setMsgType: Int = 0
    @State var text_data: String = ""
    @State var image_data: String = ""
    @State var link_data: String = ""
    @State var link_title: String = ""
    @State var date: Date = Date()
    var body: some View {
        Form {
            Section("message data") {
                TextField("senderUid", text: $senderUid)
                Picker("MsgType", selection: $setMsgType) {
                    ForEach(msgtype, id: \.rawValue) {
                        Text(msgtypeStr[$0.rawValue])
                    }
                }
                TextField("text_data", text: $text_data)
                TextField("image_data", text: $image_data)
                TextField("link_data", text: $link_data)
                TextField("link_title", text: $link_title)
                DatePicker("date", selection: $date)
                HStack {
                    Spacer()
                    Button("Submit") {
                        DataController.shared.addMessageStored(senderUid: senderUid, type: MessageBodyType(rawValue: setMsgType)!, text_data: text_data, image_data: image_data, link_data: link_data, link_title: link_title, date: date, context: managedObjContext)
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    DebugDataView()
}
