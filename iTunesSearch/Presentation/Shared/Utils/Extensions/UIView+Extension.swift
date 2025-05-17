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
}
