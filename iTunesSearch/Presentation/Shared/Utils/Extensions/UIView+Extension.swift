//
//  UIView+Extension.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func setViewCornerRadAndShadow(baseView: UIView, cornerRad: CGFloat, shadowOffset: CGSize, shadowRad: CGFloat, shadowOpacity: Float) {
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius = cornerRad
        
        layer.masksToBounds = false
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRad
        layer.shadowOpacity = shadowOpacity
    }
}
