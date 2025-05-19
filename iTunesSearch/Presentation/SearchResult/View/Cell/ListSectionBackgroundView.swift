//
//  ListSectionBackgroundView.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/19/25.
//

import UIKit

import SnapKit
import Then

final class ListSectionBackgroundView: UICollectionReusableView {
    
    // MARK: - Properties
    
    static let identifier = "ListSectionBackgroundView"
    
    // MARK: - UI Components
    
    private let cornerRadiusView = UIView().then {
        $0.backgroundColor = .secondarySystemGroupedBackground
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewCornerRadAndShadow(baseView: cornerRadiusView,
                                  cornerRad: 15,
                                  shadowOffset: CGSize(width: 0, height: 2),
                                  shadowRad: 15,
                                  shadowOpacity: 0.2)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
}

// MARK: - Setting Methods

private extension ListSectionBackgroundView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(cornerRadiusView)
    }
    
    func setConstraints() {
        cornerRadiusView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
