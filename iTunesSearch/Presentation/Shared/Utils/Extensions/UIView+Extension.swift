//
//  UIView+Extension.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

extension UIView {
    /// UIStackView에서 Spacer 역할을 하는 Extension
    static func spacer(axis: NSLayoutConstraint.Axis) -> UIView {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: axis)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: axis)
        
        return spacer
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
