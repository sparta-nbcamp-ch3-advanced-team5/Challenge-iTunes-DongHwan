//
//  LoadingCell.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/19/25.
//

import UIKit

import SnapKit
import Then

final class LoadingCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "LoadingCell"
    
    // MARK: - UI Components
    
    private lazy var activityIndicator = UIActivityIndicatorView().then {
        $0.center = self.center
        $0.style = .medium
        $0.hidesWhenStopped = true
    }
    
    // MARK: - Getter
    
    var getActivityIndicator: UIActivityIndicatorView {
        return activityIndicator
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Methods

private extension LoadingCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(activityIndicator)
    }
    
    func setConstraints() {
        activityIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
