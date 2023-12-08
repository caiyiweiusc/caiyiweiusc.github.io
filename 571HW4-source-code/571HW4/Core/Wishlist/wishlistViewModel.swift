//
//  wishlistViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/6.
//

import Foundation
import Combine

class WishlistViewModel: ObservableObject {
    @Published var wishlistItems: [WishlistItem] = []
    @Published var isLoading = false
    @Published var errorOccurred = false
    @Published var totalCost: Double = 0.0 // 新增总价格计算

    // 结构体用于解码 JSON 数据
    struct WishlistItem: Codable, Identifiable {
        let itemID: String
        let title: String
        let price: String
        let imageURL: String
        let shippingCost: String
        let postalCode: String
        let conditionId: String

        var id: String { itemID } // 使用 itemID 作为唯一标识符
    }

    // 从服务器获取愿望清单数据
    func fetchWishlist() {
        guard let url = URL(string: "http://localhost:4200/getWishList") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        errorOccurred = false

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Error fetching wishlist: \(error)")
                    self?.errorOccurred = true
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self?.errorOccurred = true
                    return
                }

                do {
                    let items = try JSONDecoder().decode([WishlistItem].self, from: data)
                    self?.wishlistItems = items
                    self?.calculateTotal()
                    
                } catch {
                    print("Error decoding wishlist data: \(error)")
                    self?.errorOccurred = true
                }
            }
        }
        task.resume()
    }

    func deleteItem(itemID: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "http://localhost:4200/deleteItem") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["itemID": itemID]
        request.httpBody = try? JSONEncoder().encode(body)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting item: \(error)")
                    self?.errorOccurred = true
                    return
                }
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error deleting item: Invalid response or data")
                    self?.errorOccurred = true
                    return
                }

                do {
                    // 这里可以根据后端的响应格式解码响应，如果有必要
                    let responseString = String(data: data, encoding: .utf8)
                    print("Delete successful: \(responseString ?? "")")
                    
                    // 从本地列表中移除已删除的项
                    self?.wishlistItems.removeAll(where: { $0.id == itemID })
                    
                    self?.calculateTotal()
                    if let index = self?.wishlistItems.firstIndex(where: { $0.id == itemID }) {
                                self?.wishlistItems.remove(at: index)
                                self?.calculateTotal() // 重新计算总价格
                                completion() // 调用回调
                        }
                } catch {
                    print("Error processing delete response: \(error)")
                    self?.errorOccurred = true
                }
            }
        }
        task.resume()
    }
    

    func calculateTotal() {
        totalCost = wishlistItems.reduce(0.0) { sum, item in
            // Ensure the price string is in a correct format, e.g., "199.99"
            let formattedPrice = item.price.filter("0123456789.".contains)
            if let priceValue = Double(formattedPrice) {
                return sum + priceValue
            } else {
                print("Failed to convert price to Double: \(item.price)")
                return sum
            }
        }
        print("Total Cost updated: \(totalCost)")
    }

}
