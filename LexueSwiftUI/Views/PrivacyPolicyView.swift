//
//  PrivacyPolicyView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Group {
            HStack{
                Spacer()
                Text("应用隐私许可")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                Spacer()
            }
            Form {
                Section {
                    Text("下面将列举应用会收集的您的信息，以及应用使用的相关服务，征得您的同意之前，应用不会上传任何信息，请仔细阅读并选择同意后，方可开始使用app。")
                        .multilineTextAlignment(.center)
                }
                Section("友盟+SDK服务的相关声明") {
                    HStack {
                        Text("SDK名称")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("友盟统计分析SDK")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("SDK服务商")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("友盟同欣（北京）科技有限公司")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("收集个人信息")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("设备信息（IMEI/MAC/Android ID/IDFA/OAID/OpenUDID/GUID/SIM卡IMSI/ICCID）、位置信息、网络信息")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("隐私政策链接")
                            .foregroundColor(.primary)
                        Spacer()
                        Link("点击访问", destination: URL(string: "https://www.umeng.com/page/policy")!)
                    }
                    Text("友盟SDK用于我们收集、分析app用量信息，以便更好为您提供app服务，上传的内容不涉及敏感信息")
                        .multilineTextAlignment(.center)
                }
                
                Section {
                    Button(action: {
                        SettingStorage.shared.agreePrivacyPolicy = true
                        AppStatusManager.shared.OnAppStart()
                        dismiss()
                    }, label: {
                        Text("同意并进入")
                            .foregroundColor(.accentColor)
                    })
                    Button(action: {
                        exit(0)
                    }, label: {
                        Text("不同意并退出")
                            .foregroundColor(.red)
                    })
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    PrivacyPolicyView()
}
