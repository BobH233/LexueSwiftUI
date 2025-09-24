import SwiftUI

struct CourseExportSelection: Identifiable {
    let id: String
    var courseName: String
    var events: [ScheduleManager.CalendarEvent]
    var isSelected: Bool
}

struct CourseSelectionView: View {
    @Binding var courses: [CourseExportSelection]
    @State private var allSelected: Bool = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach($courses) { $course in
                    Button(action: {
                        course.isSelected.toggle()
                        updateSelectAllState()
                    }) {
                        HStack {
                            Text(course.courseName)
                                .foregroundColor(.primary)
                            Spacer()
                            if course.isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择课程")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(allSelected ? "取消全选" : "全选") {
                allSelected.toggle()
                for i in courses.indices {
                    courses[i].isSelected = allSelected
                }
            }, trailing: Button("完成") {
                dismiss()
            })
            .onAppear(perform: updateSelectAllState)
        }
    }
    
    private func updateSelectAllState() {
        allSelected = courses.allSatisfy { $0.isSelected }
    }
}
