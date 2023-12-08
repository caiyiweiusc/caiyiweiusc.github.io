//
//  RootTabView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/5.
//

import SwiftUI

struct RootView: View {
    @StateObject var itemListViewModel = ItemListViewModel()
    @StateObject var itemDetailViewModel = ItemDetailViewModel()
    @StateObject var shippingInfoViewModel = ShippingInfoViewModel()
    @StateObject var photoViewModel = PhotoViewModel()
    @StateObject var similarItemViewModel = SimilarItemViewModel()
    @State private var selectedTab: String = "Info"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Info Tab
            ItemDetailView(itemDetailViewModel: itemDetailViewModel)
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
                .tag("Info")
            
            // 其他标签的占位视图
            ShippingInfoView(viewModel: shippingInfoViewModel) // 假设您已经有了ShippingInfoView
                    .tabItem {
                        Label("Shipping", systemImage: "shippingbox")
                    }
                    .tag("Shipping")
            
            PhotoView(viewModel: photoViewModel)
                .tabItem {
                    Label("Photos", systemImage: "photo.stack.fill")
                }
                .tag("Photos")
            
            SimilarItemsView(viewModel: similarItemViewModel)
                .tabItem {
                    Label("Similar", systemImage: "list.bullet.indent")
                }
                .tag("Similar")
        }
        // 当 ItemDetailViewModel 更新时，切换到 Info 标签
        .onChange(of: itemDetailViewModel.shouldNavigateToDetail) { newValue in
                print("shouldNavigateToDetail changed to \(newValue)")
                if newValue {
                        selectedTab = "Info"
                        itemDetailViewModel.shouldNavigateToDetail = false // 重置标志
            }
        }
    }
    
}
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView()
        }
}
    


