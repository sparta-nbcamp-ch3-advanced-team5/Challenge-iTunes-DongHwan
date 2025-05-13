//
//  UIStackView+Extension.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/12/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
