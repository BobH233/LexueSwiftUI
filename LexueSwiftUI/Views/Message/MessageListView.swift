//
//  MessageListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI


private struct UnreadRedPoint: View {
    @Binding var count: Int
    @Binding var silent: Bool
    let readIndicator = Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 0))
    let transparentWidth: CGFloat = 30
    var body: some View {
        ZStack {
            if count == 0 {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text("\(count)")
                    .bold()
                    .foregroundColor(.clear)
                    .padding(3)
                    .background(Color.clear)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            } else if count < 10 {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text(" \(count) ")
                    .bold()
                    .foregroundColor(.white)
                    .padding(3)
                    .background(silent ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            } else if count < 100 {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text("\(count)")
                    .bold()
                    .foregroundColor(.white)
                    .padding(3)
                    .background(silent ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            } else {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text("99+")
                    .bold()
                    .foregroundColor(.white)
                    .padding(3)
                    .background(silent ? Color.gray : Color.red)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            }
        }
    }
}

private struct ListItemView: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var unreadCnt: Int
    @Binding var time: String
    @Binding var avatar: String
    @Binding var pinned: Bool
    @Binding var silent: Bool
    @Binding var isOpenDatailView: ContactDisplayModel?
    @Binding var currentViewContact: ContactDisplayModel
    
    @State private var isPresented = false

    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    UnreadRedPoint(count:$unreadCnt, silent: $silent)
                }
                Image(avatar)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                VStack(alignment: .leading, spacing: 3){
                    HStack{
                        Text("\(title)")
                            .lineLimit(1)
                        Spacer()
                        HStack {
                            Text("\(time)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    Text("\(content)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(minHeight: 30)
                }
            }
            Button(action: {
                isOpenDatailView = currentViewContact
            }, label: {
                EmptyView()
            })
        }
    }
}

private struct ListView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Binding var contacts: [ContactDisplayModel]
    @Binding var isRefreshing: Bool
    @Binding var isOpenDatailView: ContactDisplayModel?
    
    
    
    let refreshAction: (()async -> Void)?
    @ViewBuilder
    var refreshToolbar: some View {
        if let doRefresh = refreshAction {
            if isRefreshing {
                ProgressView()
            } else {
                Button(action: {
                    if let refresh = refreshAction {
                        Task {
                            await refresh()
                        }
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            List($contacts) { contact in
                ListItemView(title: contact.displayName, content: contact.recentMessage, unreadCnt: contact.unreadCount, time: contact.timeString, avatar: contact.avatar_data, pinned: contact.pinned, silent: contact.silent,  isOpenDatailView: $isOpenDatailView, currentViewContact: contact)
                    .swipeActions(edge: .leading) {
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    ContactsManager.shared.ReadallContact(contactUid: contact.contactUid.wrappedValue, context: managedObjContext)
                                }
                            }
                        } label: {
                            Label("Read", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeIn) {
                                    if contact.pinned.wrappedValue {
                                        ContactsManager.shared.PinContact(contactUid: contact.contactUid.wrappedValue, isPin: false, context: managedObjContext)
                                    } else {
                                        ContactsManager.shared.PinContact(contactUid: contact.contactUid.wrappedValue, isPin: true, context: managedObjContext)
                                    }
                                }
                            }
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                        .tint(.orange)
                    }
                    .listRowBackground(Color(contact.pinned.wrappedValue ? UIColor.systemFill : UIColor.systemBackground).animation(.easeInOut))
                    .contextMenu(ContextMenu(menuItems: {
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeIn) {
                                    if contact.pinned.wrappedValue {
                                        ContactsManager.shared.PinContact(contactUid: contact.contactUid.wrappedValue, isPin: false, context: managedObjContext)
                                    } else {
                                        ContactsManager.shared.PinContact(contactUid: contact.contactUid.wrappedValue, isPin: true, context: managedObjContext)
                                    }
                                }
                            }
                        } label: {
                            if !contact.pinned.wrappedValue {
                                Label("置顶", systemImage: "pin")
                            } else {
                                Label("取消置顶", systemImage: "pin")
                            }
                        }
                        
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    ContactsManager.shared.ReadallContact(contactUid: contact.contactUid.wrappedValue, context: managedObjContext)
                                }
                            }
                        } label: {
                            Label("已读", systemImage: "checkmark.circle.fill")
                        }
                    }))
            }
            .toolbar {
                refreshToolbar
            }
            .listStyle(.plain)
        }
    }
}

struct MessageListView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    
    @ObservedObject var contactsManager = ContactsManager.shared
    @ObservedObject var globalVar = GlobalVariables.shared
    @Binding var tabSelection: Int
    @State private var isLogin = GlobalVariables.shared.isLogin
    @State var searchText: String = ""
    @State var isRefreshing: Bool = false
    @State var totalUnread = 0
    @State var unreadBadge: Text? = nil
    
    @State var isOpenDatailView: ContactDisplayModel? = nil
    
    func testRefresh() async {
        isRefreshing = true
        Task {
            Thread.sleep(forTimeInterval: 1.5)
            isRefreshing = false
        }
    }
    
    var body: some View {
        NavigationView{
            if globalVar.isLogin {
                VStack {
                    ListView(contacts: $contactsManager.ContactDisplayLists, isRefreshing: $isRefreshing, isOpenDatailView: $isOpenDatailView, refreshAction: testRefresh)
                }
                .refreshable {
                    print("refresh")
                    await testRefresh()
                }
                .navigationTitle("消息")
                .searchable(text: $searchText, prompt: "搜索消息")
                .navigationBarTitleDisplayMode(.large)
            } else {
                UnloginView(tabSelection: $tabSelection)
            }
        }
        .badge(unreadBadge)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    ContactsManager.shared.GenerateContactDisplayLists(context: managedObjContext)
                }
            }
        }
        .sheet(item: $isOpenDatailView) { contact in
            MessageDetailView(contactUid: contact.contactUid)
        }
        .onChange(of: contactsManager.ContactDisplayLists) { _ in
            // print("recalc totalUnread")
            var tmpTotal = 0
            for contact in ContactsManager.shared.ContactDisplayLists {
                if contact.silent {
                    continue
                }
                tmpTotal = tmpTotal + contact.unreadCount
            }
            totalUnread = tmpTotal
        }
        .onChange(of: totalUnread) { newVal in
            if newVal == 0 {
                unreadBadge = nil
            } else if newVal < 99 {
                unreadBadge = Text("\(totalUnread)")
            } else {
                unreadBadge = Text("99+")
            }
        }
        
    }
}

struct UnloginView: View {
    @Binding var tabSelection: Int
    var body: some View {
        VStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            Text("请登录使用乐学助手")
                .font(.title)
                .foregroundColor(.gray)
            Button("前往登录") {
                tabSelection = 4
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        UnloginView(tabSelection: .constant(1))
    }
}
