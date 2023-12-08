//
//  ShippingInfoView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/5.
//

import SwiftUI

struct ShippingInfoView: View {
    @ObservedObject var viewModel: ShippingInfoViewModel
    @Environment(\.openURL) var openURL
    var body: some View {
        ScrollView {
            HStack {
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
            }
            VStack(alignment: .center, spacing: 10) {
                // Seller Section
                VStack(alignment: .leading, spacing: 5) {
                    Divider().padding(.top, 25)
                    HStack{
                        Image(systemName: "house")
                        Text("Seller").font(.headline)
                    }
                    
                    Divider()
                    HStack {
                        Text("Store Name").font(.subheadline)
                        Spacer()
                        Link(viewModel.storeName, destination: URL(string: viewModel.storeURL)!)
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Feedback Score").font(.subheadline)
                        Spacer()
                        Text("\(viewModel.feedbackScore)")
                    }
                    HStack {
                        Text("Popularity").font(.subheadline)
                        Spacer()
                        Text("\(viewModel.positiveFeedbackPercent)")
                    }
                }
                .padding(.vertical)

                // Shipping Info Section
                VStack(alignment: .leading, spacing: 5) {
                    Divider()
                    HStack{
                        Image(systemName: "sailboat")
                        Text("Shipping Info").font(.headline)
                    }
                    
                    Divider()
                    HStack {
                        Text("Shipping Cost").font(.subheadline)
                        Spacer()
                        Text(viewModel.shippingCost)
                    }
                    HStack {
                        Text("Global Shipping").font(.subheadline)
                        Spacer()
                        Text(viewModel.globalShipping ? "Yes" : "No")
                    }
                    HStack {
                        Text("Handling Time").font(.subheadline)
                        Spacer()
                        Text("\(viewModel.handlingTime) day(s)")
                    }
                }
                .padding(.vertical)

                // Return Policy Section
                VStack(alignment: .leading, spacing: 5) {
                    Divider()
                    HStack{
                        Image(systemName: "return.left")
                        Text("Return Policy").font(.headline)
                    }
                    
                    Divider()
                    HStack {
                        Text("Policy").font(.subheadline)
                        Spacer()
                        Text(viewModel.ReturnsAccepted ? "Returns Accepted" : "No Returns")
                    }
                    HStack {
                        Text("Refund Mode").font(.subheadline)
                        Spacer()
                        Text(viewModel.Refund)
                    }
                    HStack {
                        Text("Refund Within").font(.subheadline)
                        Spacer()
                        Text(viewModel.ReturnsWithin)
                    }
                    HStack {
                        Text("Shipping Cost Paid By").font(.subheadline)
                        Spacer()
                        Text(viewModel.ShippingCostPaidBy)
                    }
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            .navigationTitle("Shipping Details")
            .navigationBarTitleDisplayMode(.inline)
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




