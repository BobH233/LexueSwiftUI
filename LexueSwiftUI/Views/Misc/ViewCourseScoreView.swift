//
//  ViewCourseScoreView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/11.
//

import SwiftUI
import LightChart

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

private struct ColoredProgressView: View {
    @State var progress: Double = 0.3
    @State var height: CGFloat = 50
    @State var indicatorColor: Color = .blue
    @State var indicatorSize: CGFloat = 15
    @State var beforeText: String = "10人"
    @State var afterText: String = "20人"
    @State var textVerticalOffset: CGFloat = 25
    @State var textColor: Color = .black
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(gradient: Gradient(stops: [
                        .init(color: Color.green, location: 0),
                        .init(color: Color.yellow, location: 0.6),
                        .init(color: Color.red, location: 0.8)
                    ]), startPoint: .leading, endPoint: .trailing))
                    .frame(height: height)
                Rectangle()
                    .fill(indicatorColor)
                    .frame(width: 3, height: height)
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress, height: 0))
                Triangle()
                    .fill(indicatorColor)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .rotationEffect(.degrees(0))
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress, height: (indicatorSize * 0.5 + height * 0.5)))
                Text(beforeText)
                    .foregroundColor(textColor)
                    .shadow(radius: 4)
                    .offset(CGSize(width:  -geometry.size.width * 0.5 + geometry.size.width * progress * 0.5, height: height * 0.5 + textVerticalOffset))
                Text(afterText)
                    .foregroundColor(textColor)
                    .shadow(radius: 4)
                    .offset(CGSize(width:  geometry.size.width * 0.5 - geometry.size.width * (1 - progress) * 0.5, height: height * 0.5 + textVerticalOffset))
            }
            .padding(.bottom, 25)
        }
    }
}

struct ViewCourseScoreView: View {
    var body: some View {
        ColoredProgressView()
            .padding(.horizontal, 20)
        LightChartView(data: [2, 17, 9, 23, 10],
                       type: .curved,
                       visualType: .customFilled(color: .red,
                                                 lineWidth: 3,
                                                 fillGradient: LinearGradient(gradient: Gradient(stops: [
                                                    .init(color: Color.green, location: 0),
                                                    .init(color: Color.yellow, location: 0.4),
                                                    .init(color: Color.clear, location: 0.4)
                                                ]), startPoint: .leading, endPoint: .trailing)))
    }
}

#Preview {
    ViewCourseScoreView()
}
