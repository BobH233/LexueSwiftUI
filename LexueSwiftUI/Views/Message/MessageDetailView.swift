//
//  MessageDetailView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/4.
//

import SwiftUI

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


private struct BubbleTextMessageView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let message: String
    var body: some View {
        ChatBubble(direction: .left) {
            Text(message)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(BubbleTextColor)
                .background(BubbleColor)
        }
        .contextMenu(ContextMenu(menuItems: {
            Button {
                UIPasteboard.general.string = message
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
        }))
        .padding(.leading, 10)
    }
}

private struct BubbleImageMessageView: View, BubbleBaseColorConfig {
    
    @Environment(\.colorScheme) var sysColorScheme
    let image: String
    var body: some View {
        ChatBubble(direction: .left) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width - 70)
        }
        .contextMenu(ContextMenu(menuItems: {
            Button {
                Task {
                    UIPasteboard.general.image = UIImage(named: "test_image")
                }
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
        }))
        .padding(.leading, 10)
    }
}

private struct TimeView: View, BubbleBaseColorConfig {
    @Environment(\.colorScheme) var sysColorScheme
    let timeStr: String
    var body: some View {
        Text(timeStr)
            .font(.subheadline)
            .foregroundColor(TimeTextColor)
            .padding(.trailing, 10)
            .padding(.top, 10)
        
    }
}

private struct BubbleLinkMessageView: View, BubbleBaseColorConfig {
    
    @Environment(\.colorScheme) var sysColorScheme
    let linkName: String
    let url: String
    var body: some View {
        if let encodedUrl = URL(string: url) {
            ChatBubble(direction: .left) {
                Link(destination: encodedUrl, label: {
                    Text(linkName)
                        .underline()
                })
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(BubbleColor)
            }
            .contextMenu(ContextMenu(menuItems: {
                Button {
                    UIPasteboard.general.string = url
                } label: {
                    Label("复制链接", systemImage: "link")
                }
                Button {
                    UIPasteboard.general.string = linkName
                } label: {
                    Label("复制标题", systemImage: "doc.on.doc")
                }
            }))
            .padding(.leading, 10)
        } else {
            EmptyView()
        }
    }
}

struct MessageDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjContext
    
    let contactUid: String
    @State var contactName: String = "联系人啊"
    @State private var messages: [ContactMessage] = []
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messages) { message in
                            if message.messageBody.type == .text {
                                BubbleTextMessageView(message: message.messageBody.text_data!)
                            } else if message.messageBody.type == .image {
                                BubbleImageMessageView(image: message.messageBody.image_data!)
                            } else if message.messageBody.type == .link {
                                BubbleLinkMessageView(linkName: message.messageBody.link_title!, url: message.messageBody.link!)
                            } else if message.messageBody.type == .time {
                                TimeView(timeStr: message.messageBody.time_text!)
                            }
                        }
                        Text("")
                            .opacity(0)
                            .id("bottom_text")
                    }
                    // To let it scroll to the bottom
                    Text("")
                        .opacity(0)
                        .onAppear {
                            proxy.scrollTo("bottom_text")
                        }
                }
                .onAppear {
                    let result = DataController.shared.queryMessagesByContactUid(senderUid: "Admin1", context: managedObjContext)
                    messages = result
                }
                .onChange(of: messages.count) { _ in
                    proxy.scrollTo("bottom_text")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationTitle(contactName)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    MessageDetailView(contactUid: "123", contactName: "debug")
}
