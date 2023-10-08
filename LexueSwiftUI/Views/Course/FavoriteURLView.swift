//
//  FavoriteURLView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/8.
//

import SwiftUI

struct EditFavoriteURLView: View {
    @Binding var favoriteURL: FavoriteURLStored?
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var title: String = ""
    @State var url: String = ""
    var body: some View {
        if favoriteURL != nil {
            Form {
                if let favoriteDate = favoriteURL!.favorite_date {
                    HStack {
                        Text("收藏时间")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(GetDateDescriptionText(sendDate: favoriteDate))
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text("收藏标题")
                    Spacer()
                    TextField("输入收藏链接的标题", text: $title)
                }
                HStack {
                    Text("URL")
                    Spacer()
                    TextField("输入收藏的链接", text: $url)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            GlobalVariables.shared.alertTitle = "收藏标题不能为空"
                            GlobalVariables.shared.alertContent = "请至少指定收藏标题"
                            GlobalVariables.shared.showAlert = true
                            return
                        }
                        if let url = URL(string: url) {
                            print(url)
                            favoriteURL!.title = title
                            favoriteURL!.url = url.absoluteString
                            DataController.shared.save(context: managedObjContext)
                            dismiss()
                        } else {
                            GlobalVariables.shared.alertTitle = "URL非法"
                            GlobalVariables.shared.alertContent = "请填写正确格式的URL"
                            GlobalVariables.shared.showAlert = true
                        }
                    }
                }
            }
            .onAppear {
                title = favoriteURL!.title ?? ""
                url = favoriteURL!.url ?? ""
            }
            .navigationTitle("编辑收藏链接")
        }
    }
}

struct FavoriteURLView: View {
    @State var favoriteUrls = [FavoriteURLStored]()
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var editUrlStored: FavoriteURLStored?
    @State var showEditView: Bool = false
    
    var body: some View {
        List {
            if favoriteUrls.count == 0 {
                Text("还没有收藏链接哦~")
            } else {
                ForEach(favoriteUrls) { favoriteUrl in
                    NavigationLink(destination: LexueBroswerView(url: favoriteUrl.url ?? "", customActions: []).navigationTitle(favoriteUrl.title ?? "未命名").navigationBarTitleDisplayMode(.inline), label: {
                        VStack {
                            HStack {
                                Text(favoriteUrl.title ?? "未命名")
                                    .bold()
                                    .lineLimit(1)
                                Spacer()
                            }
                            HStack {
                                Text(favoriteUrl.from_course_name ?? "用户收藏")
                                Spacer()
                            }
                        }
                    })
                    .swipeActions(edge: .trailing) {
                        Button {
                            managedObjContext.delete(favoriteUrl)
                            DataController.shared.save(context: managedObjContext)
                            withAnimation {
                                favoriteUrls = DataController.shared.getFavoriteURLs(context: managedObjContext)
                            }
                        } label: {
                            Label("trash", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            editUrlStored = favoriteUrl
                            showEditView = true
                        } label: {
                            Label("square.and.pencil", systemImage: "square.and.pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .navigationTitle("我的收藏链接")
        .onAppear {
            favoriteUrls = []
            favoriteUrls = DataController.shared.getFavoriteURLs(context: managedObjContext)
        }
        NavigationLink("", isActive: $showEditView, destination: {
            EditFavoriteURLView(favoriteURL: $editUrlStored)
        })
        .hidden()
    }
}

#Preview {
    FavoriteURLView()
}
