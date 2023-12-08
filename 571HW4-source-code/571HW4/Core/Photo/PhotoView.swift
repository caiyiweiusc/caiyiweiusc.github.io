//
//  PhotoView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/5.
//

import SwiftUI

struct PhotoView: View {
    @ObservedObject var viewModel: PhotoViewModel
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 10) {
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
                    .padding(.leading, 350)
                    ForEach(viewModel.photos) { photo in
                        ZStack {
                            Rectangle() // 这个矩形用于确保ScrollView的每个子视图大小一致
                                .foregroundColor(.clear) // 使矩形透明，不影响视图
                                .frame(width: 400, height: 200) // 你希望的ScrollView子视图大小

                            AsyncImage(url: URL(string: photo.url)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit() // 保持图片的原始长宽比
                                case .failure:
                                    Image(systemName: "photo")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 200, height: 200) // 设置图片的大小为200x200
                            .clipped() // 确保图片不会超出框架
                        }
                    }
                }
                .padding() // 添加内边距
            }.padding(.top, 40)
            
            // 在顶部添加一个固定位置的视图，显示"Powered by Google"的文字
            VStack {
                HStack {
                    Spacer()
                    Text("Powered by")
                        .foregroundColor(.black) // 设置文字颜色
                    Image("google") // 假设您已经将Google的Logo以"logo.google"的名字添加到了您的Assets.xcassets
                        .resizable() // 使图片可以调整大小
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 40) // 根据您的需要调整Google logo的大小
                    Spacer()
                    

                }
                .background(Color.white) // 设置背景色为白色并稍微透明，这样可以看到下面的内容
                Spacer() // 这将推动上面的视图保持在顶部
            }
            .frame(height: 30) // 根据您的需要调整这个视图的高度
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

// 这里是您的PhotoViewModel的预览提供者，您可以根据实际情况进行调整
struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(viewModel: PhotoViewModel())
    }
}



