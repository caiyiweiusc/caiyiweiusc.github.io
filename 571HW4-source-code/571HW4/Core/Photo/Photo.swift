//
//  Photo.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/5.
//

import Foundation

struct Photo: Identifiable {
    let id = UUID()
    let url: String
}

class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var productLink: String? {
            didSet {
                print("Product Link Updated: \(productLink ?? "nil")")
            }
        }

    func updatePhotos(with photoUrls: [String]) {
        self.photos = photoUrls.map { Photo(url: $0) }
        print(self.photos)
    }
    
}

