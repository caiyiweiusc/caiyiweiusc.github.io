//
//  itemDetailView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import SwiftUI

struct ItemDetailView: View {
    @ObservedObject var itemDetailViewModel: ItemDetailViewModel
    @Environment(\.openURL) var openURL

    
    
    var body: some View {
        if itemDetailViewModel.isLoading {
            // 当ViewModel表明正在加载数据时，显示进度指示器
            ProgressView("Please wait...")
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                HStack {
                    Button(action: {
                        if let productURL = itemDetailViewModel.productLink {
                            shareToFacebook(productURL: productURL)
                        }
                    }) {
                        Image("fb")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .padding(.leading, 350)
                }
                
                VStack(alignment: .leading) {
                    
                    // 商品图片滑动查看
                    TabView {
                        ForEach(itemDetailViewModel.images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray.frame(width: 200, height: 200)
                            }
                            .scaledToFit()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 300)
                    .padding(.horizontal, 10) // 添加水平边界
                    .padding(.bottom, 10) // 给指示器预留空间
                    .tabViewStyle(PageTabViewStyle())
                    .onAppear {
                        setupAppearance()
                    }
                    
                    
                    // 产品标题
                    if let title = itemDetailViewModel.itemDetails["title"] as? String {
                        Text(title)
                            .font(.system(size: 20))
                            .padding(.top, 10)
                            .padding(.horizontal, 10)
                        
                    }
                    // Product Price
                    if let price = itemDetailViewModel.itemDetails["price"] as? String {
                        let formattedPrice = "$ " + price.replacingOccurrences(of: "USD", with: "")
                        Text(formattedPrice)
                            .foregroundColor(.blue) // Make the price text blue
                            .font(.system(size:16))
                            .fontWeight(.bold)
                            .padding(.top, 10) // 增加与上方元素的间距
                            .padding(.bottom, 10) // 增加与下方元素的间距
                            .padding(.horizontal, 10) // 添加水平边界
                    }
                    
                    // 插入描述标题和图标
                    HStack(spacing: 5) {
                        Image(systemName: "magnifyingglass") // 使用系统图标或者您的自定义图标
                            .foregroundColor(.black)
                        Text("Description")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5) // 根据您的设计需求调整垂直间距
                    .padding(.bottom, 10)
                    
                    // Item Specifications
                    if let itemSpecifics = itemDetailViewModel.itemDetails["itemSpecifics"] as? [String: [String]] {
                        ForEach(itemSpecifics.keys.sorted(), id: \.self) { key in
                            if let values = itemSpecifics[key], let value = values.first {
                                VStack {
                                    HStack {
                                        Text(key + ":")
                                            .bold()
                                        Spacer()
                                        Text(value)
                                            .frame(maxWidth: .infinity, alignment: .trailing) // Right align the value
                                    }
                                    .font(.system(size:16))
                                    .padding(.horizontal, 10)
                                    Divider() // Add a divider after each specification
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .onAppear {
                    print("Debugging data: \(itemDetailViewModel.itemDetails)")
                }
            }
        }
        
    }
    // 在ItemDetailView中
    func shareToFacebook(productURL: String) {
        let urlString = "http://www.facebook.com/sharer.php?u=\(productURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("尝试打开的 URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("无效的 URL")
            return
        }
        openURL(url)
    }

}



func setupAppearance() {
    UIPageControl.appearance().currentPageIndicatorTintColor = .black
    UIPageControl.appearance().pageIndicatorTintColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
}


struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(itemDetailViewModel: ItemDetailViewModel())
    }
}
