//
//  wishlistView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/6.
//
import SwiftUI

struct WishlistView: View {
    @ObservedObject var wishlistViewModel: WishlistViewModel
    var viewModel: ProductSearchViewModel
    var itemListViewModel: ItemListViewModel
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            // 使用 VStack 和条件判断来确定显示的内容
            VStack {
                if wishlistViewModel.wishlistItems.isEmpty {
                    // 空状态时的文本
                    Text("No items in wishlist")
                        .font(.system(size: 20)) // 字体大小
                        .foregroundColor(.black) // 字体颜色
                } else {
                    List {
                        Section {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Wishlist total(\(wishlistViewModel.wishlistItems.count)) items:")
                                        .padding([.top, .bottom, .leading])
                                    Spacer()
                                    Text("$\(wishlistViewModel.totalCost, specifier: "%.2f")")
                                        .padding([.top, .bottom, .trailing])
                                }
                                
                                Rectangle()
                                    .frame(height: 0.1)
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                            }
                            .listRowInsets(EdgeInsets())
                            
                            ForEach(wishlistViewModel.wishlistItems) { item in
                                WishlistItemView(wishlistViewModel: wishlistViewModel, item: item)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                wishlistViewModel.deleteItem(itemID: item.id){}
                                                print("hello", item.id)
                                                itemListViewModel.fetchWishlist()
                                                viewModel.sendSearchRequest { jsonString in
                                                    print(jsonString)
                                                    itemListViewModel.updateDataList(with: jsonString)
                                                    showResults = true
                                                }
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
           
        }.navigationTitle("Favorites")
    }
}
