//
//  MainSearchView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/22.
//arfff
//
//  SwiftUIView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/22.
//

import SwiftUI

struct ProductSearchView: View {
@State private var keyword: String = ""
@State private var distance: String = ""
@State private var selectedCategory: String = "All"
@State private var conditionUsed: Bool = false
@State private var conditionNew: Bool = false
@State private var conditionUnspecified: Bool = false
@State private var localPickup: Bool = false
@State private var shippingFree: Bool = false
@State private var customLocation: Bool = false
@State private var zipCode: String = ""
@State private var showAutoZip = false
@State private var showKeywordError = false
@State private var showResults = false  // 新增状态控制结果显示
@State private var showWishlistView = false
@StateObject var wishlistViewModel = WishlistViewModel() // 创建 WishlistViewModel 实例
@ObservedObject var autoZipViewModel = AutoZipViewModel()
@ObservedObject var viewModel = ProductSearchViewModel()
@ObservedObject var itemListViewModel = ItemListViewModel()
@StateObject var itemDetailViewModel = ItemDetailViewModel() // 创建 ItemDetailViewModel 实例
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    Section{
                        HStack{
                            Text("Keyword: ")
                            Spacer()
                            TextField("Required", text: $keyword)
                        }
                        
                        Divider()
                        
                        HStack{
                            Picker("Category", selection: $selectedCategory) {
                                Text("All").tag("all")
                                Text("Art").tag("550")
                                Text("Baby").tag("2984")
                                Text("Books").tag("267")
                                Text("Clothing, Shoes & Accessories").tag("11450")
                                Text("Computers/Tablets & Networking").tag("58058")
                                Text("Health & Beauty").tag("26395")
                                Text("Music").tag("11233")
                                Text("Video Games & Consoles").tag("1249")
                                // Add other categories as needed
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        Divider()
                        
                        HStack {
                            Text("Condition")
                            Spacer()
                            CheckboxField(checked: $conditionUsed, label: "Used")
                            CheckboxField(checked: $conditionNew, label: "New")
                            CheckboxField(checked: $conditionUnspecified, label: "Unspecified")
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        
                        Divider()
                        
                        HStack {
                            Text("Shipping")
                            Spacer()
                            CheckboxField(checked: $localPickup, label: "Pickup")
                            CheckboxField(checked: $shippingFree, label: "Free Shipping")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Distance: ")
                            Spacer()
                            TextField("10", text: $distance)
                        }
                        
                        
                        Divider()
                        
                        Toggle(isOn: $customLocation) {
                            Text("Custom location")
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .onAppear {
                            // 在视图出现时检查toggle状态并相应地获取当前位置的邮政编码
                            if !self.customLocation {
                                viewModel.getCurrentLocationZip() { zip in
                                    self.zipCode = zip
                                }
                            }
                        }
                        .onChange(of: customLocation) { newValue in
                            if newValue {
                                // 当 toggle 打开时，清空 zipCode
                                self.zipCode = ""
                            } else {
                                // 当 toggle 关闭时，获取当前位置的邮政编码并赋值给 zipCode
                                viewModel.getCurrentLocationZip() { zip in
                                    self.zipCode = zip
                                }
                            }
                        }
                        Divider()
                        // 根据 customLocation 的状态显示或隐藏 Zipcode 输入框
                        if customLocation {
                            HStack {
                                Text("ZipCode: ")
                                Spacer()
                                TextField("Required", text: $zipCode)
                                    .keyboardType(.numberPad)
                                    .onChange(of: zipCode) { newValue in
                                        if newValue.count >= 3 && newValue.count < 5{
                                            autoZipViewModel.fetchSuggestions(for: newValue)
                                            // 显示自动补全视图
                                            showAutoZip = true
                                        } else {
                                            // 不满足条件时隐藏自动补全视图
                                            showAutoZip = false
                                        }
                                    }
                            }
                            Divider()
                        }
                        
                        Section {
                            HStack {
                                Spacer()
                                Button("Submit") {
                                    if keyword.trimmingCharacters(in: .whitespaces).isEmpty {
                                        showKeywordError = true
                                        
                                    } else {
                                        // 如果关键词不为空，则进行搜索
                                        viewModel.updateSearchParameters(keyword: keyword,
                                                                         selectedCategory: selectedCategory,
                                                                         conditionUsed: conditionUsed,
                                                                         conditionNew: conditionNew,
                                                                         freeShipping: shippingFree,
                                                                         localPickup: localPickup,
                                                                         distance: distance,
                                                                         zipCode: zipCode
                                        )
                                        viewModel.sendSearchRequest { jsonString in
                                            itemListViewModel.updateDataList(with: jsonString)
                                            showResults = true  // 提交后设置为 true
                                        }
                                        itemListViewModel.fetchWishlist()
                                        showKeywordError = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Spacer()
                                Button("Clear") {
                                    clearForm()
                                }
                                .buttonStyle(.bordered)
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.bottom, 20)
                    .navigationBarItems(trailing: Button(action: {
                        wishlistViewModel.fetchWishlist() // 调用获取愿望清单数据的方法
                        showWishlistView = true // 设置状态以显示 WishlistView
                    }) {
                        Image(systemName: "heart.circle")
                    })
                    .navigationTitle("Product Search")
                    // 使用 NavigationLink 来响应状态变化并导航
                    .background(NavigationLink(destination: WishlistView(
                        wishlistViewModel: wishlistViewModel,
                        viewModel: viewModel,   // 确保传递正确的 ViewModel
                        itemListViewModel: itemListViewModel
                    ), isActive: $showWishlistView) { EmptyView() })
                    if showResults {  // 根据状态决定是否显示结果
                        Section{
                            ItemListView(itemListViewModel: itemListViewModel, itemDetailViewModel: itemDetailViewModel)
                        }
                    }
                    
                    
                }.onAppear {
                    itemListViewModel.fetchWishlist() // 刷新愿望清单
                }
                .sheet(isPresented: $showAutoZip) {
                    if autoZipViewModel.isLoading {
                        ProgressView("Please wait...")
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        AutoZipView(suggestions: $autoZipViewModel.suggestions,
                                    zipCodeInput: $zipCode)
                    }
                }
                if showKeywordError {
                    Text("Keyword is mandatory")
                            .foregroundColor(.white)
                            .padding(.vertical, 8) // 垂直内边距
                            .padding(.horizontal, 16) // 水平内边距
                            .background(Color.black)
                            .cornerRadius(4) // 根据您上传的图片，半径可以调整以匹配您想要的曲率
                            .frame(maxWidth: .infinity)
                        //.zIndex(1) // 确保消息在列表之上

                }
            }
        }
    }

    private func clearForm() {
        keyword = ""
        selectedCategory = "All"
        conditionUsed = false
        conditionNew = false
        shippingFree = false
        localPickup = false
        conditionUnspecified = false
        distance = ""
        customLocation = false
        zipCode = ""
        viewModel.clearSearchParameters()
        showResults = false // 不显示搜索结果
        showKeywordError = false
    }
}

struct CheckboxField: View {
    @Binding var checked: Bool
    var label: String
    
    var body: some View {
        Button(action: {
            self.checked.toggle()
        }) {
            HStack {
                Image(systemName: checked ? "checkmark.square" : "square")
                Text(label)
            }
        }
        .buttonStyle(.plain)
    }
}

    

struct ProductSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSearchView()
    }
}
