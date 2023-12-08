//
//  SimilarItemView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/6.
//
import SwiftUI

struct SimilarItem: Identifiable, Decodable {
    let id: UUID
    let imageUrl: String
    let productName: String
    let price: String
    let shippingCost: String
    let daysLeft: String
    
    // 数值类型的属性，用于排序
    var priceValue: Double { Double(price) ?? 0.0 }
    var shippingCostValue: Double { Double(shippingCost) ?? 0.0 }
    var daysLeftValue: Int { Int(daysLeft) ?? 0 }
    
    // 由于我们使用了自定义的计算属性，我们需要定义自己的CodingKeys
    // Identifiable 需要一个明确的 id
    enum CodingKeys: String, CodingKey {
        case imageUrl, productName, price, shippingCost, daysLeft
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        productName = try container.decode(String.self, forKey: .productName)
        price = try container.decode(String.self, forKey: .price)
        shippingCost = try container.decode(String.self, forKey: .shippingCost)
        daysLeft = try container.decode(String.self, forKey: .daysLeft)
        id = UUID() // 或者从解码器解码，如果 id 也是从 JSON 中获取的
    }
}

struct SimilarItemsView: View {
    @ObservedObject var viewModel: SimilarItemViewModel
    @State private var selectedSort = "Default"
    @State private var selectedOrder = "Ascending"
    @Environment(\.openURL) var openURL

    let layout = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack { // 包裹在一个垂直堆栈中
            // 标题
            HStack {
                Text("Sort By")
                    .font(.system(size: 20))
                    .bold() // 加粗
                    .padding(.leading)

                Spacer() // 这将推动文本和按钮到两边

                Button(action: {
                    if let productURL = viewModel.productLink {
                        shareToFacebook(productURL: productURL)
                    }
                }) {
                    Image("fb")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .padding(.trailing)
            }
            .padding(.top, -20)
            .padding(.bottom, 5) // 减小与上面元素的垂直距离
            
            Picker("Sort By", selection: $selectedSort) {
                Text("Default").tag("Default")
                Text("Name").tag("Name")
                Text("Price").tag("Price")
                Text("Days Left").tag("Days Left")
                Text("Shipping").tag("Shipping")
            }
            .pickerStyle(SegmentedPickerStyle()) // 设置为分段样式
            .padding([.leading, .trailing], 10) // 减小与周围元素的垂直和水平距离
            .padding(.bottom, 5)
            
            // 根据选择显示或隐藏排序顺序
            if selectedSort != "Default" {
                HStack {
                    Text("Order")
                        .font(.system(size: 20))
                        .bold()
                        .padding(.leading)
                        Spacer()
                    }
                        .padding(.bottom, 5)
                            
                Picker("Order", selection: $selectedOrder) {
                    Text("Ascending").tag("Ascending")
                    Text("Descending").tag("Descending")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing], 10)
                    .padding(.bottom, 5)
                    .onChange(of: selectedSort) { newValue in
                        viewModel.sortItems(by: newValue, order: selectedOrder)
                    }
                    .onChange(of: selectedOrder) { newOrder in
                        viewModel.sortItems(by: selectedSort, order: newOrder)
                    }

                }


            ScrollView {
                LazyVGrid(columns: layout, spacing: 20) {
                    ForEach(viewModel.similarItems) { item in
                        VStack {
                            AsyncImage(url: URL(string: item.imageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                            .padding(.top, 10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.productName)
                                    .font(.system(size:16))
                                    .lineLimit(2)
                                
                                HStack {
                                    Text("$\(item.shippingCost)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(item.daysLeft) days left")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .trailing) // 右对齐文本
                                }
                                
                                HStack {
                                    Spacer()
                                    Text("$\(item.price)")
                                        .font(.system(size:20))
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .trailing) // 右对齐文本
                                }
                            }
                            .padding([.leading, .bottom, .trailing])
                        }
                        .background(Color(red:0.96, green:0.96, blue:0.96))
                        .cornerRadius(10)
                        .shadow(radius: 1)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("SimilarItemsView appeared with items: \(viewModel.similarItems)")
        }
    }
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





