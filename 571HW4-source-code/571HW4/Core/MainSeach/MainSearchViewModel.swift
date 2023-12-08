//
//  MainSearchViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/22.
//

import Foundation
import Combine

struct SearchParameters {
        var keywords: String
        var category: String
        var condition: [String]
        var freeShippingOnly: Bool
        var localPickupOnly: Bool
        var distance: String?
        var zipCode: String? // 可选属性，因为可能不是所有搜索都需要邮政编码
}

struct ZipCodeResponse: Codable {
    let zip: String
}
//Search result data 处理
struct EbaySearchResponse: Codable {
    let findItemsAdvancedResponse: [FindItemsAdvancedResponse]
}
struct FindItemsAdvancedResponse: Codable {
    let searchResult: [SearchResultItem]
}

struct SearchResultItem: Codable {
    let imageURL: String?
    let title: String?
    let price: String?
    let postalCode: String?
    let conditionDisplayName: String?
    let shippingCost: String?
    let shippingLocations: String?
    let handlingTime: String?
    let expeditedShipping: String?
    let oneDayShipping: String?
    let returnsAccepted: String?
    let link: String?
    let itemID: String?
    let categoryId: String?
}

class ProductSearchViewModel: ObservableObject {
    // 使用 @Published 包装器来标记需要观察的属性
    @Published var searchParameters: SearchParameters
    
    //
    init() {
        // Here 'distance' should be set to nil or a specific String value, not 'String?'
        searchParameters = SearchParameters(
            keywords: "",
            category: "",
            condition: [],
            freeShippingOnly: false,
            localPickupOnly: false,
            distance: nil,  // This should be nil or a String value like "10",
            zipCode: nil // Correctly set to nil
           
        )
    }
    // 用于构建查询字符串的函数
    func buildQuery() -> String {
           var queryItems = [URLQueryItem]()
           var itemFilterIndex = 0

           // 添加关键词
           queryItems.append(URLQueryItem(name: "keywords", value: searchParameters.keywords))

           // 处理类别
            if searchParameters.category.lowercased() != "all" {
                queryItems.append(URLQueryItem(name: "categoryId", value: searchParameters.category))
            }

           // 处理条件
            if !searchParameters.condition.isEmpty {
               queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).name", value: "Condition"))
               for (index, conditionValue) in searchParameters.condition.enumerated() {
                   queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).value(\(index))", value: conditionValue))
               }
               itemFilterIndex += 1
           }

            // 处理免费配送选项
            if searchParameters.freeShippingOnly {
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).name", value: "FreeShippingOnly"))
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).value", value: "true"))
                itemFilterIndex += 1
            }

            // 处理当地取货选项
            // 假设您有一个相应的布尔值属性来检查用户是否选择了当地取货
            if searchParameters.localPickupOnly {
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).name", value: "LocalPickupOnly"))
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).value", value: "true"))
                itemFilterIndex += 1
            }
        
            // 处理距离
            if let distance = searchParameters.distance, !distance.isEmpty {
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).name", value: "MaxDistance"))
                queryItems.append(URLQueryItem(name: "itemFilter(\(itemFilterIndex)).value", value: distance))
                itemFilterIndex += 1
            }
        
            // 处理邮政编码
            if let zipCode = searchParameters.zipCode, !zipCode.isEmpty {
                queryItems.append(URLQueryItem(name: "buyerPostalCode", value: zipCode))
            }

           // 构建查询字符串
            let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
            print(queryString)
            return queryString
       }
    
    func updateSearchParameters(keyword: String, selectedCategory: String, conditionUsed: Bool, conditionNew: Bool, freeShipping: Bool, localPickup: Bool, distance: String?, zipCode: String?) {
        searchParameters.keywords = keyword
        searchParameters.category = selectedCategory
        searchParameters.freeShippingOnly = freeShipping
        searchParameters.localPickupOnly = localPickup // 新增的处理
        searchParameters.distance = distance
        searchParameters.zipCode = zipCode
        

        searchParameters.condition.removeAll()
        if conditionUsed { searchParameters.condition.append("3000") }
        if conditionNew { searchParameters.condition.append("1000") }

        buildQuery()
    }
    
    
    
    // 示例用的清空所有搜索参数的方法
    func clearSearchParameters() {
        searchParameters = SearchParameters(keywords: "", category: "All", condition: [], freeShippingOnly: false, localPickupOnly: false)
    }
    
 
    // 搜索商品
    func sendSearchRequest(completion: @escaping (String) -> Void) {
        let queryString = buildQuery()
        guard let url = URL(string: "http://localhost:4200/ebay/search?\(queryString)") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // 如果有错误，就在主线程中更新UI
                DispatchQueue.main.async {
                    print("Request error: \(error)")
                }
                return
            }

            guard let data = data else {
                // 如果没有收到数据，也在主线程中更新UI
                DispatchQueue.main.async {
                    print("No data received")
                }
                return
            }

            // 尝试将数据转换为字符串
            if let jsonString = String(data: data, encoding: .utf8) {
                // 在主线程中打印出JSON字符串
                DispatchQueue.main.async {
                    completion(jsonString)  // 使用闭包回传JSON字符串
                    print("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
                    //print(jsonString)
                    print("Received string: \(jsonString)")
                }
            } else {
                // 如果数据不能被解析为字符串，同样在主线程中处理
                DispatchQueue.main.async {
                    print("Received data can't be converted to String")
                }
            }
        }
        
        task.resume()
    }

    func getCurrentLocationZip(completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://localhost:4200/getCurrentLocationZip") else {
            print("Invalid URL for getting current location zip")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    // 更新UI或处理错误
                    print("Error fetching current location zip: \(error)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    // 更新UI或处理错误
                    print("No data received for current location zip")
                }
                return
            }
            
            do {
                // 解析 JSON 数据
                let decodedData = try JSONDecoder().decode(ZipCodeResponse.self, from: data)
                DispatchQueue.main.async {
                    // 提取邮政编码并通过闭包传递
                    let zipCode = decodedData.zip
                    print("Obtained zipcode: \(zipCode)")
                    completion(zipCode)
                }
            } catch {
                DispatchQueue.main.async {
                    // 更新UI或处理错误
                    print("Failed to decode zip code response: \(error)")
                }
            }
        }

        task.resume()
    }

}

