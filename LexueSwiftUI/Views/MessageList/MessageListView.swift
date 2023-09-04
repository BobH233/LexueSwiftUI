//
//  MessageListView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/3.
//

import SwiftUI
import SearchBarView

struct MessagesStructure: Identifiable {
    var id = UUID()
    var unreadIndicator: String
    var avatar: String
    var name: String
    var messageSummary: String
    var timestamp: String
}

struct ListItemView: View {
    @State var title: String
    @State var content: String
    @State var unreadCnt: Int
    @State var time: String
    @State var avatar: String
    let readIndicator = Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 0))
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    readIndicator
                        .frame(width: 10, height: 10)
                    if unreadCnt > 0 {
                        Image("unreadIndicator")
                    }
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
            .swipeActions(edge: .leading) {
                Button {
                    print("Hi")
                } label: {
                    Label("Read", systemImage: "checkmark.circle.fill")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing) {
                Button {
                    print("Hi")
                } label: {
                    Label("Pin", systemImage: "pin")
                }
                .tint(.orange)
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

struct MessageListView: View {
    var messages: [MessagesStructure] = [MessagesStructure(unreadIndicator: "unreadIndicator", avatar: "default_avatar", name: "Jared", messageSummary: "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊", timestamp: "2023年9月23日 23:48"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Martin Steed", messageSummary: "I don't know why people are so anti pineapple pizza. I kind of like it.", timestamp: "12:40 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Zach Friedman", messageSummary: "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)", timestamp: "11:00 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Kyle & Aaron", messageSummary: "There's no way you'll be able to jump your motorcycle over that bus.", timestamp: "10:36 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Dee McRobie", messageSummary: "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.", timestamp: "9:59 AM"),
                                         MessagesStructure(unreadIndicator: "unreadIndicator", avatar: "default_avatar", name: "Gary Butcher", messageSummary: "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)", timestamp: "9:26 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Francesco", messageSummary: "I don't know why people are so anti pineapple pizza. I kind of like it.", timestamp: "9:20 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Luke", messageSummary: "There's no way you'll be able to jump your motorcycle over that bus.", timestamp: "9:16 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Ama Aboakye", messageSummary: "Tabs make way more sense than spaces. Convince me I'm wrong. LOL.", timestamp: "9:00 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Adwoa Forson", messageSummary: "That's what I'm talking about!", timestamp: "8:59 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Kofi Mensah", messageSummary: "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)", timestamp: "8:51 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Amos G.", messageSummary: "Maybe email isn't the best form of communication.", timestamp: "9:36 AM"),
                                         MessagesStructure(unreadIndicator: "unreadIndicator", avatar: "default_avatar", name: "Maren Yustiono", messageSummary: "There's no way you'll be able to jump your motorcycle over that bus.", timestamp: "8:50 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Martin Yustiono", messageSummary: "That's what I'm talking about!", timestamp: "8:45 AM"),
                                         MessagesStructure(unreadIndicator: "", avatar: "default_avatar", name: "Zain Snowman", messageSummary: "(Sad fact: you cannot search for a gif of the word “gif”, just gives you gifs.)", timestamp: "8:40 AM"),
                                         MessagesStructure(unreadIndicator: "unreadIndicator", avatar: "default_avatar", name: "Kipling West King", messageSummary: "Maybe email isn't the best form of communication.", timestamp: "8:36 AM")]
    let readIndicator = Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 0))
    @State var text1: String = ""
    
    var body: some View {
        NavigationView{
            VStack {
                VStack {
                    List(messages) { item in
                        ListItemView(title: item.name, content: item.messageSummary, unreadCnt: 10, time: item.timestamp, avatar: item.avatar)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    print("refresh")
                }
            }
            .navigationTitle("消息")
            .searchable(text: $text1, prompt: "搜索消息")
            .navigationBarTitleDisplayMode(.large)
        }
        
    }
}

struct MessageListView_Previews: PreviewProvider {
    static var previews: some View {
        MessageListView()
    }
}
