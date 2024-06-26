//
//  MessageDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import SwiftUI
import ImageViewer
import MarkdownUI

protocol BubbleBaseColorConfig: View {
    var sysColorScheme: ColorScheme { get }
    var BubbleColor: Color { get }
    var BubbleTextColor: Color { get }
    var TimeTextColor: Color { get }
}

extension BubbleBaseColorConfig {
    var BubbleColor: Color {
        if sysColorScheme == .dark {
            return Color(#colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1607843137, alpha: 1))
        } else {
            return Color(#colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9215686275, alpha: 1))
        }
    }
    
    var BubbleTextColor: Color {
        if sysColorScheme == .dark {
            return .white
        } else {
            return .black
        }
    }
    
    var TimeTextColor: Color {
        if sysColorScheme == .dark {
            return .white.opacity(0.5)
        } else {
            return .black.opacity(0.5)
        }
    }
}


// reference: https://prafullkumar77.medium.com/swiftui-creating-a-chat-bubble-like-imessage-using-path-and-shape-67cf23ccbf62
struct ChatBubble<Content>: View where Content: View {
    let direction: ChatBubbleShape.Direction
    let content: () -> Content
    init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
            self.content = content
            self.direction = direction
    }
    
    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            content().clipShape(ChatBubbleShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }.padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 5)
        .padding((direction == .right) ? .leading : .trailing, 50)
    }
}

struct ChatBubbleShape: Shape {
    enum Direction {
        case left
        case right
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        return (direction == .left) ? getLeftBubblePath(in: rect) : getRightBubblePath(in: rect)
    }
    
    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20),
                       control1: CGPoint(x: width - 8, y: height),
                       control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0),
                       control1: CGPoint(x: width, y: 8),
                       control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20),
                       control1: CGPoint(x: 12, y: 0),
                       control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addCurve(to: CGPoint(x: 0, y: height),
                       control1: CGPoint(x: 4, y: height - 1),
                       control2: CGPoint(x: 0, y: height))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0),
                       control1: CGPoint(x: 4.0, y: height + 0.5),
                       control2: CGPoint(x: 8, y: height - 1))
            p.addCurve(to: CGPoint(x: 25, y: height),
                       control1: CGPoint(x: 16, y: height),
                       control2: CGPoint(x: 20, y: height))
            
        }
        return path
    }
    
    private func getRightBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x:  20, y: height))
            p.addCurve(to: CGPoint(x: 0, y: height - 20),
                       control1: CGPoint(x: 8, y: height),
                       control2: CGPoint(x: 0, y: height - 8))
            p.addLine(to: CGPoint(x: 0, y: 20))
            p.addCurve(to: CGPoint(x: 20, y: 0),
                       control1: CGPoint(x: 0, y: 8),
                       control2: CGPoint(x: 8, y: 0))
            p.addLine(to: CGPoint(x: width - 21, y: 0))
            p.addCurve(to: CGPoint(x: width - 4, y: 20),
                       control1: CGPoint(x: width - 12, y: 0),
                       control2: CGPoint(x: width - 4, y: 8))
            p.addLine(to: CGPoint(x: width - 4, y: height - 11))
            p.addCurve(to: CGPoint(x: width, y: height),
                       control1: CGPoint(x: width - 4, y: height - 1),
                       control2: CGPoint(x: width, y: height))
            p.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: width - 11, y: height - 4),
                       control1: CGPoint(x: width - 4, y: height + 0.5),
                       control2: CGPoint(x: width - 8, y: height - 1))
            p.addCurve(to: CGPoint(x: width - 25, y: height),
                       control1: CGPoint(x: width - 16, y: height),
                       control2: CGPoint(x: width - 20, y: height))
            
        }
        return path
    }
}

private struct BubbleUnkowTypeMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let type: Int
    var body: some View {
        ChatBubble(direction: .left) {
            Text("[不受支持的消息类型] type = \(type)")
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(.red)
                .background(BubbleColor)
        }
        .padding(.leading, 10)
    }
}

private struct BubbleTextMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: ContactMessage
    @State var sendDate: String = ""
    var body: some View {
        ChatBubble(direction: .left) {
            Text(message.messageBody.text_data!)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(BubbleTextColor)
                .background(BubbleColor)
        }
        .onAppear {
            sendDate = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
        }
        .contextMenu(ContextMenu(menuItems: {
            Label("发送日期: \(sendDate)", systemImage: "clock.arrow.circlepath")
            Button {
                UIPasteboard.general.string = message.messageBody.text_data!
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
        }))
        .padding(.leading, 10)
    }
}

private struct MarkdownMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: ContactMessage
    @State var sendDate: String = ""
    var body: some View {
        ChatBubble(direction: .left) {
            Markdown(message.messageBody.text_data!)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(BubbleTextColor)
                .background(BubbleColor)
        }
        .onAppear {
            sendDate = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
        }
        .contextMenu(ContextMenu(menuItems: {
            Label("发送日期: \(sendDate)", systemImage: "clock.arrow.circlepath")
            Button {
                UIPasteboard.general.string = message.messageBody.text_data!
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
        }))
        .padding(.leading, 10)
    }
}

private struct BubbleImageMessageView: View, BubbleBaseColorConfig {
    
    @Environment(\.colorScheme) var sysColorScheme
    @Binding var showImage: Bool
    @Binding var imageData: Image
    
    let message: ContactMessage
    @State var sendDate: String = ""
    @State var uiImage: UIImage? = nil
    var body: some View {
        ChatBubble(direction: .left) {
            if let uiImage = uiImage  {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width - 70)
                    .background(BubbleColor)
            } else {
                ZStack {
                    Color.clear
                        .frame(width: UIScreen.main.bounds.width - 70)
                        .frame(height: 100)
                        .background(BubbleColor)
                    Image(systemName: "photo")
                }
            }
            
        }
        .onTapGesture {
            if uiImage == nil {
                return
            }
            imageData = Image(message.messageBody.image_data!)
            showImage = true
        }
        .onAppear {
            sendDate = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
            uiImage = UIImage(named: message.messageBody.image_data!)
        }
        .contextMenu(ContextMenu(menuItems: {
            Label("发送日期: \(sendDate)", systemImage: "clock.arrow.circlepath")
            if let uiImage = uiImage {
                Button {
                    Task {
                        UIPasteboard.general.image = uiImage
                    }
                } label: {
                    Label("复制", systemImage: "doc.on.doc")
                }
                Button {
                    Task {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    }
                } label: {
                    Label("保存到相册", systemImage: "rectangle.stack.badge.plus")
                }
            } else {
                Label("图像已损坏", systemImage: "square.and.arrow.up.trianglebadge.exclamationmark")
            }
            
        }))
        .padding(.leading, 10)
    }
}

private struct TimeView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: ContactMessage
    var body: some View {
        Text(message.messageBody.time_text!)
            .font(.subheadline)
            .foregroundColor(TimeTextColor)
            .padding(.trailing, 10)
            .padding(.top, 10)
        
    }
}

private struct BubbleEventNotificationMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: ContactMessage
    @State var sendDate: String = ""
    @State var showEventDetail: Bool = false
    var body: some View {
        ChatBubble(direction: .left) {
            NavigationLink("", isActive: $showEventDetail, destination: {
                ViewEventView(event_uuid: message.messageBody.event_uuid ?? UUID())
            })
            VStack(alignment: .leading) {
                HStack {
                    Text(message.messageBody.type == .new_event_notification ? "事件提醒" : "事件到期提醒")
                        .foregroundColor(message.messageBody.type == .new_event_notification ? BubbleTextColor : .red)
                        .font(.title)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text(message.messageBody.type == .new_event_notification ? "检测到新增乐学事件，请注意时间" : "这个事件马上要到期了，请注意及时完成!")
                        .font(.system(size: 24))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                HStack(alignment: .top) {
                    Text("事件名称:")
                        .bold()
                        .font(.system(size: 20))
                    Text(message.messageBody.event_name ?? "无名称")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    Spacer()
                }
                HStack(alignment: .top) {
                    Text("截止时间:")
                        .bold()
                        .font(.system(size: 20))
                    Text(message.messageBody.event_starttime ?? "[错误]")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    Spacer()
                }
                Button {
                    showEventDetail.toggle()
                } label: {
                    Text("查看事件")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                }
                .tint(.blue)
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(BubbleColor)
        }
        .onAppear {
            sendDate = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
        }
        .contextMenu(ContextMenu(menuItems: {
            Label("发送日期: \(sendDate)", systemImage: "clock.arrow.circlepath")
        }))
        .padding(.leading, 10)
    }
}

private struct BubbleLinkMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: ContactMessage
    @State var sendDate: String = ""
    @State var url: URL? = nil
    var body: some View {            
        ChatBubble(direction: .left) {
            if let encodedUrl = url {
                if encodedUrl.host == "lexue.bit.edu.cn" {
                    NavigationLink(destination: LexueBroswerView(url: encodedUrl.absoluteString, customActions: []), label: {
                        Text(message.messageBody.link_title ?? "")
                            .foregroundColor(.blue)
                            .underline()
                            .multilineTextAlignment(.leading)
                    })
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(BubbleColor)
                } else {
                    Link(destination: encodedUrl, label: {
                        Text(message.messageBody.link_title!)
                            .underline()
                            .multilineTextAlignment(.leading)
                    })
                    
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(BubbleColor)
                }
            } else {
                Text("错误的链接")
                    .underline()
                    .foregroundStyle(.red)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(BubbleColor)
            }
        }
        .onAppear {
            sendDate = MessageManager.shared.GetSendDateDescriptionText(sendDate: message.sendDate)
            url = URL(string: message.messageBody.link ?? "")
        }
        .contextMenu(ContextMenu(menuItems: {
            Label("发送日期: \(sendDate)", systemImage: "clock.arrow.circlepath")
            Button {
                UIPasteboard.general.string = message.messageBody.link ?? ""
            } label: {
                Label("复制链接", systemImage: "link")
            }
            Button {
                UIPasteboard.general.string = message.messageBody.link_title ?? ""
            } label: {
                Label("复制标题", systemImage: "doc.on.doc")
            }
        }))
        .padding(.leading, 10)

    }
}

struct MessageDetailView: View {
    let contactUid: String
    let scrollMsgId: UUID?
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            NavigationView {
                MessageDetailViewInternal(contactUid: contactUid, scrollMsgId: scrollMsgId)
            }
        } else {
            MessageDetailViewInternal(contactUid: contactUid, scrollMsgId: scrollMsgId)
        }
    }
}

struct MessageDetailViewInternal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjContext
    @State var showImageViewer: Bool = false
    @State var image = Image("default_avatar")
    
    let contactUid: String
    let scrollMsgId: UUID?
    @State var contactName: String = ""
    @State private var messages: [ContactMessage] = []
    @State var loading: Bool = true
    var body: some View {
//        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        if loading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                        ForEach(messages) { message in
                            if message.messageBody.type == .text {
                                BubbleTextMessageView(message: message)
                                    .id(message.id)
                            } else if message.messageBody.type == .image {
                                BubbleImageMessageView(showImage: $showImageViewer, imageData: $image, message: message)
                                    .id(message.id)
                            } else if message.messageBody.type == .link {
                                BubbleLinkMessageView(message: message)
                                    .id(message.id)
                            } else if message.messageBody.type == .time {
                                TimeView(message: message)
                                    .id(message.id)
                            } else if message.messageBody.type == .new_event_notification || message.messageBody.type == .due_event_notification {
                                BubbleEventNotificationMessageView(message: message)
                                    .id(message.id)
                            } else if message.messageBody.type == .markdown {
                                MarkdownMessageView(message: message)
                                    .id(message.id)
                            }
                            else {
                                BubbleUnkowTypeMessageView(type: message.messageBody.type.rawValue)
                                    .id(message.id)
                            }
                        }
                    }
                    .onFirstAppear {
                        loading = true
                        print("scroll to \(scrollMsgId?.uuidString ?? "nil")")
                        Task {
                            ContactsManager.shared.ReadallContact(contactUid: contactUid, context: managedObjContext)
                            let result = DataController.shared.queryMessagesByContactUid(senderUid: contactUid, context: managedObjContext)
                            let contact = DataController.shared.findContactStored(contactUid: contactUid, context: managedObjContext)
                            contactName = contact!.GetDisplayName()
                            withAnimation(.linear(duration: 0.5)) {
                                messages = MessageManager.shared.InjectTimetagForMessages(messages: result)
                                loading = false
                            }
                            // 哪种方法好？
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    for _ in 0..<3 {
                                        if scrollMsgId == nil {
                                            proxy.scrollTo(messages.last?.id)
                                        } else {
                                            proxy.scrollTo(scrollMsgId!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .overlay(ImageViewer(image: self.$image, viewerShown: self.$showImageViewer))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ContactDetailView(contactUid: contactUid).onDisappear {
                        let contact = DataController.shared.findContactStored(contactUid: contactUid, context: managedObjContext)
                        contactName = contact?.GetDisplayName() ?? "出错"
                    }) {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .navigationTitle(contactName)
            .navigationBarTitleDisplayMode(.inline)
//        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        HStack {
            Text("事件提醒")
                .font(.title)
                .bold()
            Spacer()
        }
        .background(.red)
        
        HStack {
            Text("检测到新增乐学事件，请注意时间")
                .font(.system(size: 24))
                .padding(0)
                .background(.green)
                .lineLimit(nil)
            Spacer()
        }
        
        HStack(alignment: .top) {
            Text("事件名称:")
                .bold()
                .font(.system(size: 20))
            Text("挨饿挂翁哦爱你改翁a额哇哦噶额噶额尕娃恶搞哇哦额")
                .font(.title3)
            Spacer()
        }
        HStack {
            Text("截止时间:")
                .bold()
                .font(.system(size: 20))
            Text("aegaweawegaweaegaegaegawgwaegawegawegawegawegawegawegg")
                .font(.title3)
            Spacer()
        }
        Button {
            
        } label: {
            Text("查看事件")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity)
                .frame(height: 30)
        }
        .tint(.blue)
        .buttonStyle(.borderedProminent)
        
    }
    .frame(width: 300)
    .background(Color.red)
}
