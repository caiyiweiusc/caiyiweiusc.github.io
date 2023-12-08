//
//  itemListViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import Foundation

class ItemListViewModel: ObservableObject {
    @Published var jsonDataList: [String] = []
    @Published var isLoading = false  // 添加加载状态
    @Published var itemsFound = true // 新的状态，表示是否找到了项目
    @Published var itemDetailData: String? // 存储详细信息的属性
    @Published var sellerData: String?
    @Published var wishlistItemIDs: Set<String> = []
    @Published var isWishlistLoaded = false
    @Published var productLink: String? // 存储产品链接的属性
    

    func updateDataList(with jsonString: String) {
            isLoading = true
            DispatchQueue.main.async {
                if jsonString == "{\"itemsFound\":false}" {
                    self.itemsFound = false
                    self.jsonDataList = []
                } else {
                    self.jsonDataList = self.parseJson(jsonString: jsonString)
                    self.itemsFound = !self.jsonDataList.isEmpty
                }
                self.isLoading = false
            }
    }

    private func parseJson(jsonString: String) -> [String] {
        guard let data = jsonString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            print("Failed to parse JSON string")
            return []
        }

        return jsonArray.compactMap { dictionary in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
            isLoading = false
            //print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            //print(jsonString)
            return jsonString
        }
    }
    
    func fetchItemDetails(itemID: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://localhost:4200/getSingleItem?item_id=\(itemID)") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching item details: \(error)")
                }
                return
            }

            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                            self?.itemDetailData = jsonString
                            //print(jsonString)
                            completion(jsonString)
                }
            
            }
        }

        task.resume()
    }
    
    func fetchSellerData(itemID: String, completion: @escaping (String, String?) -> Void) {
        guard let url = URL(string: "http://localhost:4200/ebay/getSellerData") else {
            print("Invalid URL for fetching seller data")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching seller data: \(error)")
                    completion("", nil)
                }
                return
            }

            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self?.sellerData = jsonString
                    print("Fetched Seller Data: \(jsonString)")

                    // Fetch the stored data
                    self?.fetchStoredData(itemID: itemID) { [weak self] shippingCost, storedTitle in
                        completion(jsonString, shippingCost)
                    }
                }
            }
        }

        task.resume()
    }

    private func fetchStoredData(itemID: String, completion: @escaping (String?, String?) -> Void) {
        guard let url = URL(string: "http://localhost:4200/ebay/getStoredData") else {
                print("Invalid URL for fetching stored data")
                completion(nil, nil)
                return
            }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching stored data: \(error)")
                    completion(nil, nil)
                }
                return
            }
            
            if let data = data, let storedData = try? JSONDecoder().decode([StoredItem].self, from: data) {
                let storedItem = storedData.first { $0.itemID == itemID }
                DispatchQueue.main.async {
                    completion(storedItem?.shippingCost, storedItem?.title)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
        }
        
        task.resume()
    }

    struct StoredItem: Decodable {
        let title: String
        let itemID: String
        let shippingCost: String
    }
    
    // Google Photo
    func fetchRelatedPhotos(itemID: String, completion: @escaping ([String]?) -> Void) {
        // First, fetch the stored data to get the title
        fetchStoredData(itemID: itemID) { [weak self] shippingCost, storedTitle in
            guard let title = storedTitle else {
                print("No title found for itemID: \(itemID)")
                completion(nil)
                return
            }
            
            // Construct the URL for the photos API
            guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "http://localhost:4200/photos?q=\(encodedTitle)") else {
                print("Invalid URL for fetching photos")
                completion(nil)
                return
            }
            
            // Perform the network request to fetch the photos
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print("Error fetching photos: \(error)")
                        completion(nil)
                    }
                    return
                }
                
                if let data = data, let photoUrls = try? JSONDecoder().decode([String].self, from: data) {
                    DispatchQueue.main.async {
                        print("PPPPPPPPPPPPPPPPPPP")
                        print(photoUrls)
                        completion(photoUrls)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        }
    }
    // Fetch similar item:
    func fetchSimilarItems(itemID: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://localhost:4200/ebay/findSimilarItems?itemId=\(itemID)") else {
            print("Invalid URL for fetching similar items")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching similar items: \(error.localizedDescription)")
                    completion("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received for similar items")
                    completion("Error: No data received")
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                DispatchQueue.main.async {
                    print("Error fetching similar items: \(response.statusCode)")
                    completion("Error: HTTP \(response.statusCode)")
                }
                return
            }
            
            // Attempt to parse the JSON data
            if let jsonString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(jsonString)
                }
            } else {
                DispatchQueue.main.async {
                    print("Failed to decode JSON for similar items")
                    completion("Error: Failed to decode JSON")
                }
            }
        }
        
        task.resume()
    }
    
    //add to MongoDB
    func addProductToWishlist(jsonData: String) {
        // 这里假设jsonData是包含产品信息的JSON字符串
        // 创建请求
        guard let url = URL(string: "http://localhost:4200/saveItem") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // jsonData已经是一个JSON字符串，所以可以直接作为HTTP体使用
        request.httpBody = jsonData.data(using: .utf8)

        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding product to wishlist: \(error)")
                return
            }
            // 可以添加额外的响应处理逻辑
        }
        task.resume()
    }
    //Remove from mongoDB
    func removeProductFromWishlist(itemID: String) {
        guard let url = URL(string: "http://localhost:4200/deleteItem") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ["itemID": itemID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error removing product from wishlist: \(error)")
                return
            }
            // 可以添加额外的响应处理逻辑
        }
        task.resume()
    }
    
    //Fetch wishlist:
    func fetchWishlist() {
           guard let url = URL(string: "http://localhost:4200/getWishList") else {
               print("Invalid URL")
               return
           }

           let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               if let error = error {
                   print("Error fetching wishlist: \(error)")
                   return
               }

               if let data = data,
                  let itemList = try? JSONDecoder().decode([WishlistItem].self, from: data) {
                   DispatchQueue.main.async {
                       self?.wishlistItemIDs = Set(itemList.map { $0.itemID })
                       self?.isWishlistLoaded = true
                       //print("Wishlist Item IDs: \(self?.wishlistItemIDs ?? [])")
                   }
               }
           }
           task.resume()
       }

       struct WishlistItem: Decodable {
           let itemID: String
           // 添加其他需要的属性
       }
}



