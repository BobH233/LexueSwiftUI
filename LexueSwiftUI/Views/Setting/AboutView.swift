//
//  AboutView.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/4.
//

import SwiftUI
import MarkdownUI

let markdownAboutApp = """
# 关于乐学助手

北理工校友你好，我是“[乐学助手](https://github.com/BobH233/LexueSwiftUI)”的主要开发者BobH，一名北理工2021级徐特立自动化的普通学生。首先感谢你使用“乐学助手”，“乐学助手”也在不断的迭代更新，加入更多更符合大家需求的功能。

下面是关于“乐学助手”的一些故事。

## 开发初衷

[乐学平台](https://lexue.bit.edu.cn/)是我们学校维护的一个很棒的在线学习平台，早在大一的时候我就体会过它的便利之处，更多的时候，它是作为一个老师发送课件，收取作业的平台。

但是有的时候，基于[Moodle](https://moodle.org/)开源项目定制的乐学平台又不那么方便。比如打开后时不时会弹出的重新登录页面，比如想查看最近要提交的作业时的反直觉操作，比如在手机上想要查看课程内容时打开浏览器的繁琐操作。这些是我遇到的问题，也是我希望解决的问题，于是萌生了为乐学开发一款app的想法，以我作为用户的角度来设计这款app，试图通过一些开发手段来解决或者掩盖乐学的使用不便处。

最初的我也对能否独立完成这样一个app感到担忧，抱着“做出来就给大家分享，做不出来就当自己练手”的心态，我决定开启这个app项目。

我想让这个app在传统的信息展示/工具类app之上，又要有些不同，一些更适合年轻人的改变，我的最终决定是将主要的乐学消息推送、事件提醒等都抽象成一个给你发送消息的联系人，就像我们使用QQ、微信一样，这种接收消息的方式更符合直觉，同时也有别于传统的信息展示/工具类app，让“乐学助手”不仅仅是“乐学”套壳换了个皮肤，而更有它自己的设计风格。

这样的设计让我脑海里一下子有了更多的想法，既然是以联系人的方式来推送消息，那“乐学助手”也可以不再仅局限于拉取“乐学平台”的相关消息，它还可以做到消息聚合，从不同的渠道拉取不同的消息，最后通过联系人的方式，将所有消息统一起来。所以我为app设计了“**消息源(DataProvider)**”这样一个角色，乐学上的消息可以作为一个**消息源**为“乐学助手”推送消息，同样的也可以有其他的消息源，比如我之前关注的一个很棒的北理工消息聚合项目叫[HaoBIT](https://haobit.top/dev/site/)，我也将它抽象成了一个消息源，这样就能为乐学助手提供整个学校各个类别消息的聚合能力。之后我也会加入更多的消息源，丰富消息种类。

未来我也在设想为“乐学助手”提供js脚本执行能力，允许第三方为“乐学助手”编写消息源，允许用户自行订阅第三方的消息源，做到真正的“集万象消息汇于乐学助手一体”。

至于为什么只开发ios平台，我有自己的考量。首先我自己是mac和ios用户，有言道：“要想别人用你的app，首先你自己必须是这个app的忠实用户”。自私地讲，我做这个app的首要目的是方便自己，其次是方便他人（有点言之过重了，但是事实确实是这样），我想要时刻为我app的质量把关，就放弃了适配安卓的想法。

还有一个原因便是ios平台开发对开发者是真的非常友好，我刚接触ios开发大概是大半年以前，但入门真的非常简单，我目前使用的技术栈就SwiftUI，Swift的入门在我看来相比Go、Rust是相当容易的了，Apple甚至为你Swift入门专门构建了一款软件“Swift Playground”，让你在游戏过程中便学会了Swift。借助SwiftUI，我可以非常方便的在苹果全平台（iphone, ipad, iwatch）构建我的app布局，同时享受苹果内置的丝滑动画效果，这给我更多的精力关注app的逻辑本身。

总而言之，“乐学助手”始于我对“及时获取消息”的需求，希望我的这些想法也能与你产生共鸣，让你使用这款app产生便利。当然目前这个app仍处于开发的初期，我也没有太多维护app的经验，如果你有更好的功能提议，或者遇到了使用上的问题，也欢迎随时与我联系，我很乐于听取大家的意见。

邮箱：[admin@bit-helper.cn](mailto:admin@bit-helper.cn)

## 特别感谢

以下的一些个人或组织在开发期间为我提供了很大的帮助，在此特别感谢：

* 开一：提供Logo上的建议
* F_picacho：提供Logo上的建议
* [HaoBIT](https://haobit.top/dev/site/)：授权使用其数据作为消息聚合的消息源
* [BIT101](https://bit101.cn/#/)：授权使用其成绩查询接口

## 合作事宜

如果你也愿意为“乐学助手”增砖加瓦，我将非常感谢，请联系我：[admin@bit-helper.cn](mailto:admin@bit-helper.cn)

"""

struct AboutView: View {
    var body: some View {
        Form {
            Section() {
                Markdown(markdownAboutApp)
            }
            NavigationLink("开源包引用声明", destination: {
                PackageDeclarationView()
            })
        }
        .navigationTitle("关于")
    }
}

#Preview {
    AboutView()
}
