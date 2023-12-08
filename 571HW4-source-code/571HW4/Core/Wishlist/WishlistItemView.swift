//
//  WishlistItemView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/6.
//

import SwiftUI

struct WishlistItemView: View {
    @ObservedObject var wishlistViewModel: WishlistViewModel // 作为 observed object 传入
    var item: WishlistViewModel.WishlistItem

    var body: some View {
        HStack {
            // 使用 AsyncImage 加载图片
            AsyncImage(url: URL(string: item.imageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 70, height: 70)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                // 显示标题
                Text(item.title)
                    .font(.system(size: 16))
                    .lineLimit(1) // 限制单行显示
                    .truncationMode(.tail) // 尾部省略
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                // 显示价格
                Text("$\(item.price)")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                // 显示运费
                let shippingCost = item.shippingCost // 确保您的数据模型中有此字段
                Text(shippingCost == "0" ? "FREE SHIPPING" : "\(shippingCost)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 4) // 在价格和运费之间增加间距
                
                HStack {
                    // 显示邮政编码
                    Text(item.postalCode) // 确保您的数据模型中有此字段
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                    // 显示商品状况
                    Text(mapConditionIdToCondition(item.conditionId)) // 确保您有一个函数将 conditionId 转换为对应的状况
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .frame(width: 300, height: 100) // 设置视图的宽度和高度
        .background(Color.white) // 设置背景色
        .cornerRadius(10) // 设置圆角
    }
    
    func mapConditionIdToCondition(_ conditionId: String) -> String {
        switch conditionId {
        case "1000": return "NEW"
        case "2000", "2500": return "REFURBISHED"
        case "3000", "4000", "5000", "6000": return "USED"
        default: return "NA"
        }
    }
}

