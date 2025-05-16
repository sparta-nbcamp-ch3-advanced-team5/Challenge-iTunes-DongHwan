//
//  SearchResultViewControllerDelegate.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/16/25.
//

import Foundation

protocol SearchResultViewControllerDelegate: AnyObject {
    /// 드래그 시작할 때 호출
    func willBeginDragging()
    /// SearchTextCell이 탭 됐을 때 호출
    func searchTextCellTapped()
}
