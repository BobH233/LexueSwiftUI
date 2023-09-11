//
//  AFRequest.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/11.
//

import Foundation
import Alamofire

func performGetRequest(urlString: String, headers: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
    // 创建请求
    AF.request(urlString, method: .get, headers: HTTPHeaders(headers))
        .validate(statusCode: 200..<300)
        .responseData { response in
            switch response.result {
            case .success(let data):
                if let htmlString = String(data: data, encoding: .utf8) {
                    completion(.success(htmlString))
                } else {
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
}
