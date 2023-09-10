//
//  ContactDetaiView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/8.
//

import SwiftUI

struct EditTextView: View {
    @Binding var textContent: String
    let title: String
    var body: some View {
        Form {
            TextField(title, text: $textContent)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var contactAlias: String = "联系人备注"
    @State var contactUid: String = "test"
    @State var originName: String = "originName"
    @State var contactTypeStr: String = ""
    @State var pinned: Bool = false
    @State var silent: Bool = false
    @State var contactType: Int = 0
    var body: some View {
        Form {
            HStack {
                Text("联系人ID")
                    .foregroundColor(.primary)
                Spacer()
                Text(contactUid)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("名称")
                    .foregroundColor(.primary)
                Spacer()
                Text(originName)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("类型")
                    .foregroundColor(.primary)
                Spacer()
                Text(contactTypeStr)
                    .foregroundColor(.secondary)
            }
            NavigationLink {
                EditTextView(textContent: $contactAlias, title: "联系人备注")
                    .onDisappear {
                        print("update contact alias")
                        ContactsManager.shared.SetAlias(contactUid: contactUid, alias: contactAlias, context: managedObjContext)
                    }
            } label: {
                HStack {
                    Text("备注")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(contactAlias)
                        .foregroundColor(.secondary)
                }
            }
            Toggle("置顶", isOn: $pinned)
            Toggle("消息免打扰", isOn: $silent)
        }
        .onFirstAppear {
            let contact = DataController.shared.findContactStored(contactUid: contactUid, context: managedObjContext)
            if contact != nil {
                contactAlias = contact!.alias ?? ""
                originName = contact!.originName!
                pinned = contact!.pinned
                silent = contact!.silent
                contactType = Int(contact!.type)
                contactTypeStr = ContactTypeString[Int(contact!.type)]
            }
        }
        .onChange(of: pinned) { newVal in
            print("update pinned")
            ContactsManager.shared.PinContact(contactUid: contactUid, isPin: newVal, context: managedObjContext)
        }
        .onChange(of: silent) { newVal in
            print("update silent")
            ContactsManager.shared.SilentContact(contactUid: contactUid, isSilent: newVal, context: managedObjContext)
        }
        .navigationTitle("编辑联系人")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContactDetailView()
}
