//
//  DeletedEventView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/3.
//

import SwiftUI

struct DeletedEventView: View {
    @ObservedObject var globalVar = GlobalVariables.shared
    @ObservedObject var eventManager = EventManager.shared
    @Environment(\.managedObjectContext) var managedObjContext
    
    @State var curSelectEventUUID: UUID = UUID()
    @State var showViewEventView: Bool = false
    var body: some View {
        ScrollView {
            LazyVStack{
                ForEach($eventManager.DeletedEventDisplayList, id: \.id) { event in
                    EventListItemView(title: event.name, description: event.event_description, isPeriodEvent: event.is_period_event, starttime: event.timestart,endtime: event.timeend, courseName: event.course_name, backgroundCol: event.color)
                        .onTapGesture {
                            curSelectEventUUID = event.id!
                            showViewEventView = true
                        }
                        .frame(maxWidth: 800)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 15)
        }
        .onAppear {
            eventManager.LoadDeletedEventList(context: managedObjContext)
        }
        .navigationTitle("已删除过期事件")
        .navigationBarTitleDisplayMode(.inline)
        
        NavigationLink("", isActive: $showViewEventView, destination: {
            ViewEventView(event_uuid: curSelectEventUUID, editable: false)
        })
        .hidden()
    }
}

#Preview {
    DeletedEventView()
}
