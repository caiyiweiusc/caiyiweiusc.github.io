//
//  itemDetailViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import Foundation
class ItemDetailViewModel: ObservableObject {
    @Published var itemDetails: [String: Any] = [:]
    @Published var images: [String] = [] // This should be an array of strings
    @Published var shouldNavigateToDetail = false // 新增属性
    @Published var isLoading: Bool = false
    @Published var productLink: String? {
            didSet {
                print("Product Link Updated: \(productLink ?? "nil")")
            }
        }

    
    
    func updateItemDetails(from jsonString: String) {
        self.isLoading = true
        // 将 JSON 字符串解析为字典
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let details = jsonObject as? [String: Any] else {
            print("Error parsing item details")
            return
        }
        DispatchQueue.main.async {
            self.itemDetails = details
            // Attempt to extract the image URL from the __NSSingleObjectArrayI
            if let imagesContainer = details["images"] as? NSArray {
                            self.images = imagesContainer.compactMap { $0 as? String }
                    } else if let singleImageUrl = details["images"] as? String {
                            self.images = [singleImageUrl]
                    }
                //print(self.images)
                print(self.itemDetails)
                self.isLoading = false
            }
        }

}

