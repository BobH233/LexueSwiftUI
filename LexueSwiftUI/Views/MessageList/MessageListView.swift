//
//  MessageListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import SearchBarView

struct MessagesStructure: Identifiable, Equatable {
    var id = UUID()
    var unreadIndicator: String
    var unreadCnt: Int
    var avatar: String
    var name: String
    var messageSummary: String
    var timestamp: String
    var pinned: Bool
}

struct UnreadRedPoint: View {
    @Binding var count: Int
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
            } else if count < 100 {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text("\(count)")
                    .bold()
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color.red)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            } else {
                readIndicator
                    .frame(width: transparentWidth, height: transparentWidth)
                Text("99+")
                    .bold()
                    .foregroundColor(.white)
                    .padding(3)
                    .background(Color.red)
                    .cornerRadius(10)
                    .font(.system(size: 12))
            }
        }
    }
}

struct ListItemView: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var unreadCnt: Int
    @Binding var time: String
    @Binding var avatar: String
    @Binding var pinned: Bool
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    UnreadRedPoint(count:$unreadCnt)
                }
                Image(avatar)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)
                
                VStack(alignment: .leading, spacing: 3){
                    HStack{
                        Text("\(title)")
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
                }
            }
            NavigationLink(destination: {
                Text(title)
            }, label: {
                EmptyView()
            })
            .opacity(0)
        }
    }
}

struct ListView: View {
    @Binding var messages: [MessagesStructure]
    @Binding var isRefreshing: Bool
    
    @Environment(\.refresh) private var refreshAction
    @ViewBuilder
    var refreshToolbar: some View {
        if let doRefresh = refreshAction {
            if isRefreshing {
                ProgressView()
            } else {
                Button(action: {
                    Task{
                        await doRefresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    var body: some View {
        VStack {
            List($messages) { item in
                ListItemView(title: item.name, content: item.messageSummary, unreadCnt: item.unreadCnt, time: item.timestamp, avatar: item.avatar, pinned: item.pinned)
                    .swipeActions(edge: .leading) {
                        Button {
                            print("Hi read")
                            withAnimation {
                                item.unreadCnt.wrappedValue = 0
                            }
                        } label: {
                            Label("Read", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            print("Hi pin")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                withAnimation {
                                    item.pinned.wrappedValue = !item.pinned.wrappedValue
                                    if(item.pinned.wrappedValue) {
                                        if let currentIndex = messages.firstIndex(of: item.wrappedValue) {
                                            messages.move(fromOffsets: IndexSet([currentIndex]), toOffset: 0)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Pin", systemImage: "pin")
                        }
                        .tint(.orange)
                    }
                    .listRowBackground(Color(item.pinned.wrappedValue ? UIColor.systemFill : UIColor.systemBackground).animation(.easeInOut))
            }
            .listStyle(.plain)
            .toolbar {
                refreshToolbar
            }
        }
    }
}

struct MessageListView: View {
    @State var messages: [MessagesStructure] = [
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: true),
        MessagesStructure(unreadIndicator: "", unreadCnt: 2, avatar: "default_avatar", name: "Martin Steed", messageSummary: "I don't know why people are so anti pineapple pizza. I kind of like it.", timestamp: "12:40 AM", pinned: true),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 123, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: true),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 666, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 0, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 0, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false),
        MessagesStructure(unreadIndicator: "unreadIndicator", unreadCnt: 12, avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48", pinned: false)
    ]
    @State var searchText: String = ""
    @State var isRefreshing: Bool = false
    
    func testRefresh() async {
        Task {
            isRefreshing = true
            Thread.sleep(forTimeInterval: 1.5)
            withAnimation {
                isRefreshing = false
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                ListView(messages: $messages, isRefreshing: $isRefreshing)
                .refreshable {
                    print("refresh")
                    await testRefresh()
                }
            }
            .navigationTitle("消息")
            .searchable(text: $searchText, prompt: "搜索消息")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: searchText, perform: { newValue in
            print("search \(newValue)")
            print("\(messages.count)")
            for index in 0..<messages.count {
                messages[index].name = newValue
            }
        })
        
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView()
    }
}
