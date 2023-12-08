//
//  AutoZipView.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/11/24.
//

import SwiftUI

struct AutoZipView: View {
    @Binding var suggestions: [String]
    @Binding var zipCodeInput: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(suggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .onTapGesture {
                        print("Zip code \(suggestion) was tapped, attempting to dismiss.")
                        self.zipCodeInput = suggestion
                        self.presentationMode.wrappedValue.dismiss() // 直接关闭视图
                    }
            }
            .navigationBarTitle("Zip Code Suggestions", displayMode: .inline)
        }
    }
}


