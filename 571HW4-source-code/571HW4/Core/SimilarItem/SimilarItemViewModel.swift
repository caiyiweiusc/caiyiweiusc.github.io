//
//  SimilarItemViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/6.
//

import Foundation

class SimilarItemViewModel: ObservableObject {
    @Published var similarItems: [SimilarItem] = []
    @Published var productLink: String? {
            didSet {
                print("Product Link Updated: \(productLink ?? "nil")")
            }
        }
    
    func updateSimilarItemsData(_ data: String) {
        guard let jsonData = data.data(using: .utf8),
              let items = try? JSONDecoder().decode([SimilarItem].self, from: jsonData) else {
            print("Failed to decode JSON")
            return
        }
        
        DispatchQueue.main.async {
            self.similarItems = items
        }
        print("Similar Items Data Received: \(items)")
    }
    
    // 排序方法
    func sortItems(by category: String, order: String) {
        DispatchQueue.main.async {
            switch category {
            case "Name":
                self.similarItems.sort {
                    order == "Ascending" ? $0.productName < $1.productName : $0.productName > $1.productName
                }
            case "Price":
                self.similarItems.sort {
                    order == "Ascending" ? $0.priceValue < $1.priceValue : $0.priceValue > $1.priceValue
                }
            case "Days Left":
                self.similarItems.sort {
                    order == "Ascending" ? $0.daysLeftValue < $1.daysLeftValue : $0.daysLeftValue > $1.daysLeftValue
                }
            case "Shipping":
                self.similarItems.sort {
                    order == "Ascending" ? $0.shippingCostValue < $1.shippingCostValue : $0.shippingCostValue > $1.shippingCostValue
                }
            default: // Default or any other category
                break
            }
        }
    }
}
