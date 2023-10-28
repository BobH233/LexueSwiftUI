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

private struct ContactListItemView: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var unreadCnt: Int
    @Binding var time: String
    @Binding var avatar: String
    @Binding var pinned: Bool
    @Binding var silent: Bool
    @Binding var isOpenDatailView: ContactDisplayModel?
    @Binding var currentViewContact: ContactDisplayModel
    @State var isOpenNavigationView: Bool = false
    
    @State private var isPresented = false

    func GetAvatarUIImage(base64String: String) -> UIImage {
        if let data = Data(base64Encoded: base64String), let image = UIImage(data: data) {
            return image
        } else {
            return GlobalVariables.shared.defaultUIImage!
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    UnreadRedPoint(count:$unreadCnt, silent: $silent)
                }
                Image(uiImage: GetAvatarUIImage(base64String: avatar))
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
            if UIDevice.current.userInterfaceIdiom != .phone {
                NavigationLink("", destination: MessageDetailView(contactUid: currentViewContact.contactUid, scrollMsgId: nil), isActive: $isOpenNavigationView)
                    .hidden()
            }
            Button(action: {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    currentViewContact.scrollToMsgId = nil
                    isOpenDatailView = currentViewContact
                } else {
                    isOpenNavigationView = false
                    DispatchQueue.main.async {
                        isOpenNavigationView = true
                    }
                }
            }, label: {
                EmptyView()
            })
        }
    }
}

private struct ContactListView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Binding var contacts: [ContactDisplayModel]
    @Binding var isOpenDatailView: ContactDisplayModel?
    var body: some View {
        VStack {
            List($contacts) { contact in
                ContactListItemView(title: contact.displayName, content: contact.recentMessage, unreadCnt: contact.unreadCount, time: contact.timeString, avatar: contact.avatar_data, pinned: contact.pinned, silent: contact.silent,  isOpenDatailView: $isOpenDatailView, currentViewContact: contact)
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
            .listStyle(.plain)
        }
    }
}

private struct SearchResultListView: View {
    @Binding var searchMessageResult: [ContactMessageSearchResult]
    @Binding var searchContactResult: [ContactStored]
    @Binding var isOpenDatailView: ContactDisplayModel?
    var body: some View {
        List {
            Section("联系人(\(searchContactResult.count))") {
                ForEach(searchContactResult) { contact in
                    SearchResultListItemView(contactUid: contact.contactUid!, msgUUID: nil, title: contact.GetDisplayName(), messageStart: contact.contactUid!, messageSearched: "", messageEnd: "", time: "", isOpenDatailView: $isOpenDatailView)
                }
            }
            Section("消息(\(searchMessageResult.count))") {
                ForEach(searchMessageResult) { message in
                    SearchResultListItemView(contactUid: message.contactUid, msgUUID: message.messageUUID, title: message.contactName, messageStart: message.messageStart, messageSearched: message.messageSearched, messageEnd: message.messageEnd, time: message.sendTimeStr, isOpenDatailView: $isOpenDatailView)
                }
            }
            
        }
    }
}

private struct SearchResultListItemView: View {
    let contactUid: String
    let msgUUID: UUID?
    @State var title: String = "这是联系人"
    @State var messageStart: String = "这是一段话的开始，"
    @State var messageSearched: String = "这一段被搜索了啊啊啊啊,"
    @State var messageEnd: String = "这是那一段话的后面部分"
    @State var time: String = "昨天 12:00"
    @State var avatar: String = "default_avatar"
    @Binding var isOpenDatailView: ContactDisplayModel?
    @State var isOpenNavigationView: Bool = false
    var body: some View {
        ZStack {
            HStack {
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
                    .padding(.bottom, 3)
                    HStack(spacing: 0) {
                        Text("\(messageStart)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.head)
                        Text("\(messageSearched)")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Text("\(messageEnd)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            if UIDevice.current.userInterfaceIdiom != .phone {
                NavigationLink("", destination: MessageDetailView(contactUid: contactUid, scrollMsgId: msgUUID), isActive: $isOpenNavigationView)
                    .hidden()
            }
            Button(action: {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    var tmp = ContactDisplayModel()
                    tmp.contactUid = contactUid
                    tmp.scrollToMsgId = msgUUID
                    isOpenDatailView = tmp
                } else {
                    isOpenNavigationView = false
                    DispatchQueue.main.async {
                        isOpenNavigationView = true
                    }
                }
                
            }, label: {
                EmptyView()
            })
        }
    }
}

private struct ListView: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.isSearching) private var isSearching
    
    @Binding var contacts: [ContactDisplayModel]
    @Binding var isRefreshing: Bool
    @Binding var isOpenDatailView: ContactDisplayModel?
    
    @Binding var submittedSearch: Bool
    @Binding var searchMessageResult: [ContactMessageSearchResult]
    @Binding var searchContactResult: [ContactStored]
    
    
    let refreshAction: (()async -> Void)?

    
    var body: some View {
        Group {
            if isSearching {
                if !submittedSearch {
                    // 还没开始搜索的时候显示的提示视图
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 30)
                        Text("搜索联系人名、文字消息或链接标题关键词")
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // 搜索后的展示视图
                    SearchResultListView(searchMessageResult: $searchMessageResult, searchContactResult: $searchContactResult, isOpenDatailView: $isOpenDatailView)
                }
            } else {
                ContactListView(contacts: $contacts, isOpenDatailView: $isOpenDatailView)
                    .refreshable {
                        if let refresh = refreshAction {
                            await refresh()
                        }
                    }
                    .toolbar {
                        if isRefreshing {
                            ProgressView()
                        } else {
                            Button(action: {
                                if let refresh = refreshAction {
                                    isRefreshing = true
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
        }
        .onChange(of: isSearching) {newVal in
            print("start seaching: \(newVal)")
            if newVal {
                submittedSearch = false
            }
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
    
    @State var submittedSearch = false
    @State var searchMessageResult: [ContactMessageSearchResult] = []
    @State var searchContactResult: [ContactStored] = []
    
    @State var isOpenDatailView: ContactDisplayModel? = nil
    
    func RecalcUnread() {
        DispatchQueue.main.async {
            var tmpTotal = 0
            ContactsManager.shared.GenerateContactDisplayLists(context: managedObjContext)
            for contact in ContactsManager.shared.ContactDisplayLists {
                if contact.silent {
                    continue
                }
                tmpTotal = tmpTotal + contact.unreadCount
            }
            totalUnread = tmpTotal
        }
    }
    
    func DoRefresh() async {
        isRefreshing = true
        Task {
            await DataProviderManager.shared.DoRefreshAll(manually: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    ContactsManager.shared.GenerateContactDisplayLists(context: managedObjContext)
                }
            }
            isRefreshing = false
        }
    }
    
    func DoSearchMessage() {
        print("do search")
        let trimmedKeyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword == "" {
            return
        }
        
        var result = DataController.shared.blurSearchMessage(keyword: trimmedKeyword, context: managedObjContext)
        result.sort { (msg1: ContactMessage, msg2: ContactMessage) in
            if msg1.senderUid != msg2.senderUid {
                return msg1.senderUid! < msg2.senderUid!
            }
            return msg1.sendDate > msg2.sendDate
        }
        searchMessageResult.removeAll()
        var tmpSearchMessageResult: [ContactMessageSearchResult] = []
        var tmpSearchContactResult: [ContactStored] = []
        var uniqueContactUids = Set<String>()
        let result2 = DataController.shared.blurSearchContact(keyword: trimmedKeyword, context: managedObjContext)
        for contact in result2 {
            if uniqueContactUids.contains(contact.contactUid!) {
                continue
            }
            tmpSearchContactResult.append(contact)
            uniqueContactUids.insert(contact.contactUid!)
        }
        for (_, message) in result.enumerated() {
            var cur: ContactMessageSearchResult = ContactMessageSearchResult()
            let contact = DataController.shared.findContactStored(contactUid: message.senderUid!, context: managedObjContext)
            if contact == nil {
                continue
            }
            cur.contactUid = message.senderUid!
            cur.contactName = contact!.GetDisplayName()
            cur.sendTimeStr = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
            cur.messageUUID = message.id
            var searched = false
            if message.messageBody.type == .text || message.messageBody.type == .new_event_notification || message.messageBody.type == .due_event_notification {
                if let range = message.messageBody.text_data!.lowercased().range(of: trimmedKeyword.lowercased()) {
                    let lowerBoundIndex = range.lowerBound
                    let upperBoundIndex = range.upperBound
                    if let lowerBound = message.messageBody.text_data!.index(lowerBoundIndex, offsetBy: 0, limitedBy: lowerBoundIndex), let upperBound = message.messageBody.text_data!.index(upperBoundIndex, offsetBy: 0, limitedBy: upperBoundIndex) {
                        cur.messageStart = String(message.messageBody.text_data![..<lowerBound])
                        cur.messageSearched = String(message.messageBody.text_data![lowerBound..<upperBound])
                        cur.messageEnd = String(message.messageBody.text_data![upperBound...])
                        searched = true
                    }
                }
            } else if message.messageBody.type == .link {
                if let range = message.messageBody.link_title!.lowercased().range(of: trimmedKeyword.lowercased()) {
                    let lowerBoundIndex = range.lowerBound
                    let upperBoundIndex = range.upperBound
                    if let lowerBound = message.messageBody.link_title!.index(lowerBoundIndex, offsetBy: 0, limitedBy: lowerBoundIndex), let upperBound = message.messageBody.link_title!.index(upperBoundIndex, offsetBy: 0, limitedBy: upperBoundIndex) {
                        cur.messageStart = "[链接] " + String(message.messageBody.link_title![..<lowerBound])
                        cur.messageSearched = String(message.messageBody.link_title![lowerBound..<upperBound])
                        cur.messageEnd = String(message.messageBody.link_title![upperBound...])
                        searched = true
                    }
                    searched = true
                }
            }
            if searched {
                tmpSearchMessageResult.append(cur)
            }
        }
        withAnimation {
            searchContactResult = tmpSearchContactResult
            searchMessageResult = tmpSearchMessageResult
            submittedSearch = true
        }
    }
    
    var body: some View {
        NavigationView{
            if globalVar.isLogin {
                VStack {
                    ListView(contacts: $contactsManager.ContactDisplayLists, isRefreshing: $isRefreshing, isOpenDatailView: $isOpenDatailView, submittedSearch: $submittedSearch, searchMessageResult: $searchMessageResult, searchContactResult: $searchContactResult, refreshAction: DoRefresh)
                        .searchable(text: $searchText, prompt: "搜索消息")
                        .onSubmit(of: .search, DoSearchMessage)
                }
                .navigationTitle("消息")
                .navigationBarTitleDisplayMode(.large)
            } else {
                UnloginView(tabSelection: $tabSelection)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onDatabaseUpdate)) { _ in
            print("数据库更新，重新刷新消息!")
            withAnimation {
                RecalcUnread()
            }
        }
        .badge(globalVar.isLogin ? unreadBadge : nil)
        .onAppear {
            GlobalVariables.shared.refreshUnreadMsgCallback = RecalcUnread
            GlobalVariables.shared.handleNotificationMsg = { param in
                if let contactUid = param["contactUid"] as? String, let msgId = param["msgId"] as? String {
                    tabSelection = 1
                    var tmp = ContactDisplayModel()
                    tmp.contactUid = contactUid
                    tmp.scrollToMsgId = UUID(uuidString: msgId)
                    isOpenDatailView = tmp
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    ContactsManager.shared.GenerateContactDisplayLists(context: managedObjContext)
                }
            }
        }
        .sheet(item: $isOpenDatailView) { contact in
            MessageDetailView(contactUid: contact.contactUid, scrollMsgId: contact.scrollToMsgId)
        }
        .onChange(of: contactsManager.ContactDisplayLists) { _ in
            // print("recalc totalUnread")
            RecalcUnread()
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



struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        Text("123")
        // SearchResultListItemView()
    }
}
