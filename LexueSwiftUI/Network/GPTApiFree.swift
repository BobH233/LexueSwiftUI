//
//  GPTApiFree.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/10/7.
//

import Foundation
import Alamofire


class GPTApiFree {
    static let shared = GPTApiFree()
    
    let API_URL = "https://api.chatanywhere.com.cn/v1/chat/completions"
    
    struct GPTMessage: Codable {
        var role: String
        var content: String
        init() {
            role = ""
            content = ""
        }
        init(fromDic: [String: String]) {
            if let role1 = fromDic["role"] {
                role = role1
            } else {
                role = ""
            }
            if let content1 = fromDic["content"] {
                content = content1
            } else {
                content = ""
            }
        }
        init(role role1: String, content content1: String) {
            role = role1
            content = content1
        }
    }
    
    struct GPTRequestParam: Codable {
        var modle: String = "gpt-3.5-turbo"
        var messages: [GPTMessage] = []
        var temperature: Float = 0.7
        func GetMessagesDic() -> [[String: String]] {
            var ret = [[String: String]]()
            for message in messages {
                ret.append([
                    "role": message.role,
                    "content": message.content
                ])
            }
            return ret
        }
    }
    
    struct GPTChoice {
        var index: Int = 0
        var message: GPTMessage = GPTMessage()
        var finishReason = ""
    }
    
    struct GPTResponse {
        var model: String = ""
        var choices: [GPTChoice] = []
    }
    
    enum GPTRequestError: Error {
        case stringfyJsonError
        case parseJsonError
        case networkError
    }
    
    func GetApiToken() -> String {
        guard let path = Bundle.main.path(forResource: "KeyInfo", ofType: "plist") else { return "" }
        let keys = NSDictionary(contentsOfFile: path)
        var keyName = "APIKey"
        if let OpenAI = keys?.value(forKey: "OpenAI") as? [String: Any], let ret = OpenAI[keyName] as? String {
            return ret
        } else {
            fatalError("无法载入gpt apikey")
        }
    }
    
    func GetHeader() -> HTTPHeaders {
        return HTTPHeaders([
            "Content-Type": "application/json",
            "Authorization": "Bearer \(GetApiToken())"
        ])
    }
    
    func RequestGPT(param: GPTRequestParam) async -> Result<GPTResponse, GPTRequestError> {
        var param_dic: [String: Any] = [
            "model": param.modle,
            "temperature": param.temperature,
            "messages": param.GetMessagesDic()
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param_dic, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                var request = URLRequest(url: URL(string: API_URL)!)
                request.cachePolicy = .reloadIgnoringCacheData
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = GetHeader()
                request.httpBody = jsonData
                let ret = await withCheckedContinuation { continuation in
                    AF.request(request).response { res in
                        switch res.result {
                        case .success(let data):
                            continuation.resume(returning: data)
                        case .failure(_):
                            print("请求 gpt 失败")
                            continuation.resume(returning: nil)
                        }
                    }
                }
                if ret == nil {
                    return .failure(.parseJsonError)
                }
                if let json = try? JSONSerialization.jsonObject(with: ret!, options: []) as? [String: Any] {
                    var parsedResponse = GPTResponse()
                    if let model = json["model"] as? String {
                        parsedResponse.model = model
                    }
                    if let choices = json["choices"] as? [[String: Any]] {
                        for choice in choices {
                            var currentChoice = GPTChoice()
                            if let index = choice["index"] as? Int {
                                currentChoice.index = index
                            }
                            if let finishReason = choice["finish_reason"] as? String {
                                currentChoice.finishReason = finishReason
                            }
                            if let message = choice["message"] as? [String: String] {
                                currentChoice.message = .init(fromDic: message)
                            }
                            parsedResponse.choices.append(currentChoice)
                        }
                    }
                    return .success(parsedResponse)
                } else {
                    return .failure(.parseJsonError)
                }
            } else {
                return .failure(.stringfyJsonError)
            }
        } catch {
            return .failure(.stringfyJsonError)
        }
    }
}
