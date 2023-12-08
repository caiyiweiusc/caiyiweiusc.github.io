//
//  itemListCellView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import SwiftUI
import Foundation

struct ItemListCellView: View {
    @ObservedObject var viewModel: ItemListViewModel
    @ObservedObject var itemDetailViewModel: ItemDetailViewModel // 新的 ViewModel
    @ObservedObject var shippingInfoViewModel: ShippingInfoViewModel
    @ObservedObject var photoViewModel: PhotoViewModel
    @ObservedObject var similarItemViewModel: SimilarItemViewModel
    @State private var isLinkActive = false
    @State private var isFavorite = false

    let jsonData: String
    
    init(viewModel: ItemListViewModel, itemDetailViewModel: ItemDetailViewModel, shippingInfoViewModel: ShippingInfoViewModel, photoViewModel: PhotoViewModel, similarItemViewModel: SimilarItemViewModel, jsonData: String) {
            self._viewModel = ObservedObject(wrappedValue: viewModel)
            self._itemDetailViewModel = ObservedObject(wrappedValue: itemDetailViewModel)
            self._shippingInfoViewModel = ObservedObject(wrappedValue: shippingInfoViewModel)
            self._photoViewModel = ObservedObject(wrappedValue: photoViewModel)
            self._similarItemViewModel = ObservedObject(wrappedValue: similarItemViewModel)
            self.jsonData = jsonData

            let itemID = extractData(key: "itemID")
            let isInWishlist = viewModel.wishlistItemIDs.contains(itemID)
            _isFavorite = State(initialValue: isInWishlist)
            print("Item ID: \(itemID), Is in Wishlist: \(isInWishlist)")
        }
    
    // 假设这个方法用来提取JSON中的数据
    func extractData(key: String) -> String {
        guard let data = jsonData.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = json as? [String: Any],
              let value = dictionary[key] as? String else { return "N/A" }
        
        return value
    }
    func mapConditionIdToCondition(_ conditionId: String) -> String {
        switch conditionId {
        case "1000": return "NEW"
        case "2000", "2500": return "REFURBISHED"
        case "3000", "4000", "5000", "6000": return "USED"
        default: return "NA"
        }
    }
    
    var body: some View {
        // Your current view's body
            NavigationLink(destination: RootView(itemDetailViewModel: itemDetailViewModel, shippingInfoViewModel: shippingInfoViewModel, photoViewModel: photoViewModel, similarItemViewModel: similarItemViewModel), isActive: $isLinkActive) {
                EmptyView()
            }
            .hidden() // 隐藏 NavigationLink，因为我们不需要显示它
        
        HStack {
            // 使用 AsyncImage 加载图片
            AsyncImage(url: URL(string: extractData(key: "imageURL"))) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 70, height: 70)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                // 显示标题
                Text(extractData(key: "title"))
                    .font(.system(size: 16))
                    .lineLimit(1) // 限制单行显示
                    .truncationMode(.tail) // 尾部省略
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                // 显示价格
                Text("$\(extractData(key: "price"))")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                // 显示运费
                let shippingCost = extractData(key: "shippingCost")
                Text(shippingCost == "0" ? "FREE SHIPPING" : shippingCost)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                HStack{
                    // 显示邮政编码
                    Text(extractData(key: "postalCode"))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    // 显示商品状况
                    Text(mapConditionIdToCondition(extractData(key: "conditionId")))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            
            // Wishlist button (WishList功能未实现)
            Button(action: {
                self.isFavorite.toggle()
                let itemID = extractData(key: "itemID")
                if self.isFavorite {
                    // 添加产品到愿望清单
                    viewModel.addProductToWishlist(jsonData: jsonData)
                } else {
                    // 从愿望清单删除产品
                    viewModel.removeProductFromWishlist(itemID: itemID)
                }
            }) {
                Image(systemName: self.isFavorite ? "heart.fill" : "heart")
                    .imageScale(.large)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())


            
            Image(systemName: "chevron.right") // 添加苹果提供的箭头图标
                .imageScale(.medium) // 你可以调整这个大小
                .foregroundColor(.gray) // 设置箭头图标为灰色
        }
        .frame(width: 300, height: 100) // 这里设置您希望的宽度和高度
        .background(Color.white) // 可以设置背景色
        .cornerRadius(10) // 圆角
        .onTapGesture {
            let itemID = extractData(key: "itemID")
            let link = extractData(key: "link") // 提取产品链接
            itemDetailViewModel.isLoading = true // Start loading
            self.isLinkActive = true
            viewModel.fetchItemDetails(itemID: itemID) { data in
                itemDetailViewModel.shouldNavigateToDetail = true // 设置标志以触发导航
                itemDetailViewModel.updateItemDetails(from: data)
                itemDetailViewModel.productLink = link

                
            // Fetch seller data and shipping cost
            viewModel.fetchSellerData(itemID: itemID) { sellerData, shippingCost in
                shippingInfoViewModel.processSellerData(sellerData)
                    if let shippingCost = shippingCost {
                        shippingInfoViewModel.processShippingCost(shippingCost)
                        shippingInfoViewModel.productLink = link
                    } else {
                            print("Shipping cost not found for itemID: \(itemID)")
                    }
                }
            
            //Fetch Google Photos
            viewModel.fetchRelatedPhotos(itemID: itemID) { photoUrls in
                if let photoUrls = photoUrls {
                    photoViewModel.updatePhotos(with: photoUrls)
                    photoViewModel.productLink = link
                } else {
                        print("Could not fetch related photos for itemID: \(itemID)")
                    }
                }
                
                // Fetch similar item by itemID
            viewModel.fetchSimilarItems(itemID: itemID) { similarItemsData in
                    similarItemViewModel.updateSimilarItemsData(similarItemsData)
                    similarItemViewModel.productLink = link
                }

            }
        }

            Rectangle()
                .foregroundColor(.gray) // 线的颜色
                .frame(height: 0.5) // 将 Rectangle 的高度设置为 1，使其看起来像一条线
        }
        
    }


