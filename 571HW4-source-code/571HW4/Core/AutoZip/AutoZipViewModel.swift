//
//  AutoZipViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import Foundation

class AutoZipViewModel: ObservableObject {
    @Published var suggestions: [String] = []
    @Published var isLoading = false

    func fetchSuggestions(for input: String) {
        isLoading = true
        // 检查输入是否至少有3个字符
        guard input.count >= 3 else {
            self.suggestions = []
            return
        }

        // 拼接URL并包含查询参数
        let urlString = "http://localhost:4200/searchZipCodes?postalcode_startsWith=\(input)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // 发送网络请求
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 检查是否有错误
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            // 检查是否收到数据
            guard let data = data else {
                print("No data received")
                return
            }
            // 解析JSON数据
            do {
                // 解析JSON数据到一个字典
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let postalCodes = json["postalCodes"] as? [[String: Any]] {
                    // 提取所有邮政编码并更新建议列表
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.suggestions = postalCodes.compactMap { $0["postalCode"] as? String }
                        
                    }
                }
            } catch {
                print("JSON decoding failed: \(error)")
            }
        }.resume()
    }
}
