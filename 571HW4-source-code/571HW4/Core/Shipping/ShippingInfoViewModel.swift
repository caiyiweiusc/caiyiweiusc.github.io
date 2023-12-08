//
//  ShippingInfoViewModel.swift
//  571HW4
//
//  Created by sk_sunflower@163.com on 2023/12/5.
//
import Foundation

class ShippingInfoViewModel: ObservableObject {
    // Published properties
    @Published var storeName: String = "Unknown"
    @Published var feedbackScore: Int = 0
    @Published var positiveFeedbackPercent: Double = 0.0
    @Published var storeURL: String = "Unknown"
    @Published var shippingCost: String = "Unknown"
    @Published var globalShipping: Bool = false
    @Published var handlingTime: Int = 0
    @Published var ReturnsAccepted: Bool = false
    @Published var Refund: String = "Unknown"
    @Published var ReturnsWithin: String = "Unknown"
    @Published var ShippingCostPaidBy: String = "Unknown"
    @Published var productLink: String? {
        didSet {
            print("Product Link Updated: \(productLink ?? "nil")")
        }
    }

    func processSellerData(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let details = jsonObject as? [String: Any] else {
            print("Error parsing seller info data")
            return
        }
        
        DispatchQueue.main.async {
            // Parse and assign the data to the published properties
            self.storeName = details["storeName"] as? String ?? "Unknown"
            self.feedbackScore = details["feedbackScore"] as? Int ?? 0
            self.positiveFeedbackPercent = details["positiveFeedbackPercent"] as? Double ?? 0.0
            self.storeURL = details["storeURL"] as? String ?? "Unknown"
            self.globalShipping = details["globalShipping"] as? Bool ?? false
            self.handlingTime = details["handlingTime"] as? Int ?? 0
            self.ReturnsAccepted = details["ReturnsAccepted"] as? Bool ?? false
            self.Refund = details["Refund"] as? String ?? "Unknown"
            self.ReturnsWithin = details["ReturnsWithin"] as? String ?? "Unknown"
            self.ShippingCostPaidBy = details["ShippingCostPaidBy"] as? String ?? "Unknown"
            
            print("Processed Seller Info Data:")
            print(self)
        }
    }

    func processShippingCost(_ shippingCostValue: String) {
        DispatchQueue.main.async {
            self.shippingCost = shippingCostValue
            print("Processed Shipping Cost: \(self.shippingCost)")
        }
    }
}

// Extend the view model to make it easier to print all properties
extension ShippingInfoViewModel: CustomStringConvertible {
    var description: String {
        return """
        Store Name: \(storeName)
        Feedback Score: \(feedbackScore)
        Popularity: \(positiveFeedbackPercent)
        Store URL: \(storeURL)
        Shipping Cost: \(shippingCost)
        Global Shipping: \(globalShipping)
        Handling Time: \(handlingTime)
        Returns Accepted: \(ReturnsAccepted)
        Refund Mode: \(Refund)
        Return Within: \(ReturnsWithin)
        Shipping Cost Paid By: \(ShippingCostPaidBy)
        """
    }
}




