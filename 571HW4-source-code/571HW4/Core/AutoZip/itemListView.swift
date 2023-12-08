//
//  itemListView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import SwiftUI

struct ItemListView: View {
    @ObservedObject var itemListViewModel: ItemListViewModel
    @StateObject var itemDetailViewModel = ItemDetailViewModel()
    @StateObject var shippingInfoViewModel = ShippingInfoViewModel()
    @StateObject var photoViewModel = PhotoViewModel()
    @StateObject var similarItemViewModel = SimilarItemViewModel()
    //@ObservedObject var itemDetailViewModel: ItemDetailViewModel
    var body: some View {
        VStack {
            // Results 标题和下划线
            VStack(alignment: .leading) {
                Text("Results")
                    .font(.title)
                    .bold()
                
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.gray)
            }
            
            
            // 根据数据加载状态显示不同内容
            if itemListViewModel.isLoading {
                // 数据正在加载时的视图
                ProgressView("Please wait...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else if !itemListViewModel.itemsFound{
                // 没有结果时的视图
                HStack {
                    Text("No results found.")
                        .foregroundColor(.red) // 文本颜色
                        .font(.system(size: 16)) // 文本字体大小
                        .padding() // 如果需要，添加适当的内边距
                    Spacer() // 将文本推向左边
                }
            }else {
                // 数据加载完成时的视图
                if itemListViewModel.isWishlistLoaded {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(itemListViewModel.jsonDataList, id: \.self) { jsonData in
                            ItemListCellView(
                                viewModel: itemListViewModel,
                                itemDetailViewModel: itemDetailViewModel,
                                shippingInfoViewModel: shippingInfoViewModel,
                                photoViewModel: photoViewModel,
                                similarItemViewModel: similarItemViewModel,// Add this line
                                jsonData: jsonData
                            )
                            .padding(.leading, 0) // 调整单元格样式
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 0)
                            
                        }
                    }
                    .padding(.horizontal, 0)
                }
            }
            }
        }
        .padding(.top, 0 )
        .onAppear {
                    itemListViewModel.fetchWishlist()
        }
    
    }
}


