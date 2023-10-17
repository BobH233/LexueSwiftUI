//
//  PrivacyStatement.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/28.
//

import SwiftUI

struct PrivacyStatement: View {
    var body: some View {
        Form {
            if GlobalVariables.shared.isLogin {
                Section("您的以下信息被收集") {
                    HStack {
                        Text("设备标识(umid)")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(UMCommonSwift.umidString() ?? "暂时无法获取")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("用户名")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(SettingStorage.shared.cacheUserInfo.stuId)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    HStack {
                        Text("消息推送标识")
                            .foregroundColor(.primary)
                        Spacer()
                        Text(GlobalVariables.shared.deviceToken ?? "无法获取")
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    if !GlobalVariables.shared.enableTracking {
                        Text("因为你要求app不进行跟踪，因此上述的设备标识和用户名将不用作跟踪目的，也不会与你个人信息绑定。")
                    }
                }
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
            Section("用户协议") {
                UserAgreement()
            }
        }
        .navigationTitle("隐私声明")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    PrivacyStatement()
}
