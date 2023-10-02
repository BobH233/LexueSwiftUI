//
//  EditEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/2.
//

import SwiftUI
import CoreData


struct EditEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.dismiss) var dismiss
    @State var event_uuid: UUID
    @State var event_obj: EventStored? = nil
    
    // 是否已经是到期事件了
    func IsExpired(event: EventStored) -> Bool {
        return event.timestart! < Date.now
    }
    var body: some View {
        Form {
            if event_obj != nil {
                Section() {
                    if IsExpired(event: event_obj!) {
                        Text("事件已到期")
                    } else {
                        if event_obj!.finish {
                            Button(action: {
                                withAnimation {
                                    EventManager.shared.FinishEvent(id: event_uuid, isFinish: false, context: managedObjContext)
                                }
                                dismiss()
                            }) {
                                Text("设置为未完成")
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: {
                                withAnimation {
                                    EventManager.shared.FinishEvent(id: event_uuid, isFinish: true, context: managedObjContext)
                                }
                                dismiss()
                            }) {
                                Text("设置为已完成")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if let event = DataController.shared.findEventById(id: event_uuid, context: managedObjContext) {
                event_obj = event
            } else {
                dismiss()
                globalVar.alertTitle = "无法找到这个事件\(event_uuid.uuidString)"
                globalVar.alertContent = "按理来说这不应该发生...请反馈bug"
                globalVar.showAlert = true
            }
        }
    }
}

