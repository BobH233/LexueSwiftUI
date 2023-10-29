//
//  iCloudActions.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/27.
//

import SwiftUI
import CoreData

struct iCloudActions: View {
    @Environment(\.managedObjectContext) var managedObjContext
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    @State private var showAlert3 = false
    @State private var showAlert4 = false
    @State private var showAlert5 = false
    @State private var alertMessage = ""
    var body: some View {
        Form {
            Section {
                Button(role: .none, action: {
                    alertMessage = "确认要重置整个app数据库吗？这将会删除你本地以及云端app存储的全部信息，并且不可恢复，请确认"
                    VibrateOnce()
                    showAlert4 = true
                }, label: {
                    HStack {
                        Image(systemName: "app.badge")
                        Text("重置整个app数据库")
                    }
                })
                .alert(isPresented: $showAlert4) {
                    Alert(title: Text("确认操作"), message: Text(alertMessage), primaryButton: .destructive(Text("确认"), action: {
                        DataController.shared.deleteEntityAllData(entityName: ContactStored.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: MessageStored.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordEvent.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordNotification.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordNotifiedEvent.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: EventStored.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: CourseCacheStored.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: FavoriteURLStored.entity().name ?? "", context: managedObjContext)
                        iCloudUserDefaults.shared.clearAllCloudStorage()
                        VibrateTwice()
                    }), secondaryButton: .cancel(Text("取消")))
                }
                
                
                Button(role: .none, action: {
                    alertMessage = "确认要重置消息数据库吗？这将会删除你本地以及云端的全部联系人以及消息数据，且不可恢复，请确认"
                    VibrateOnce()
                    showAlert1 = true
                }, label: {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("仅重置消息数据库")
                    }
                })
                .alert(isPresented: $showAlert1) {
                    Alert(title: Text("确认操作"), message: Text(alertMessage), primaryButton: .destructive(Text("确认"), action: {
                        DataController.shared.deleteEntityAllData(entityName: ContactStored.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: MessageStored.entity().name ?? "", context: managedObjContext)
                        VibrateTwice()
                    }), secondaryButton: .cancel(Text("取消")))
                }
                
                
                
                Button(role: .none, action: {
                    alertMessage = "确认要重置消息源数据库吗？这将会删除你本地以及云端的消息源缓存，且不可恢复，请确认"
                    VibrateOnce()
                    showAlert2 = true
                }, label: {
                    HStack {
                        Image(systemName: "externaldrive.fill.badge.icloud")
                        Text("仅重置消息源数据库")
                    }
                })
                .alert(isPresented: $showAlert2) {
                    Alert(title: Text("确认操作"), message: Text(alertMessage), primaryButton: .destructive(Text("确认"), action: {
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordEvent.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordNotification.entity().name ?? "", context: managedObjContext)
                        DataController.shared.deleteEntityAllData(entityName: LexueDP_RecordNotifiedEvent.entity().name ?? "", context: managedObjContext)
                        VibrateTwice()
                    }), secondaryButton: .cancel(Text("取消")))
                }
                
                Button(role: .none, action: {
                    alertMessage = "确认要重置事件数据库吗？这将会删除你本地以及云端的最近事件数据，且不可恢复，请确认"
                    VibrateOnce()
                    showAlert3 = true
                }, label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("仅重置事件数据库")
                    }
                })
                .alert(isPresented: $showAlert3) {
                    Alert(title: Text("确认操作"), message: Text(alertMessage), primaryButton: .destructive(Text("确认"), action: {
                        DataController.shared.deleteEntityAllData(entityName: EventStored.entity().name ?? "", context: managedObjContext)
                        VibrateTwice()
                    }), secondaryButton: .cancel(Text("取消")))
                }
                Button(role: .none, action: {
                    alertMessage = "确认要重置存储的设置吗？这将会删除你云端存储的全部设置，且不可恢复，请确认"
                    VibrateOnce()
                    showAlert4 = true
                }, label: {
                    HStack {
                        Image(systemName: "tablecells")
                        Text("仅重置存储的设置")
                    }
                })
                .alert(isPresented: $showAlert4) {
                    Alert(title: Text("确认操作"), message: Text(alertMessage), primaryButton: .destructive(Text("确认"), action: {
                        iCloudUserDefaults.shared.clearAllCloudStorage()
                        VibrateTwice()
                    }), secondaryButton: .cancel(Text("取消")))
                }
            } header: {
                Text("重置操作")
            } footer: {
                Text("如果你发现同步的内容出现错误，或者出现奇怪的BUG，可以尝试重置iCloud数据库。请注意，这将删除乐学助手app本地和云端数据库中对应的内容，所以在重置之前，确保你已经将重要的事件做好了自行备份。")
            }
        }
        .navigationTitle("iCloud数据库操作")
    }
}

#Preview {
    iCloudActions()
}
