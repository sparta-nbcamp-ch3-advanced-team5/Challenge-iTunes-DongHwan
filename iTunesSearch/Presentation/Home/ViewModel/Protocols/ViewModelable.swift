//
//  ViewModelable.swift
//  iTunesSearch
//
//  Created by 서동환 on 5/13/25.
//

import Foundation

import RxSwift

/// Action (ViewController ➡️ ViewModel)
enum Action {
    case viewDidLoad
}

/// State (ViewModel ➡️ ViewController)
struct State {
    let actionSubject = PublishSubject<Action>()
}

/// ViewController에서 ViewModel 구현체에 의존하지 않도록 하는 역할
protocol ViewModelable {
    /// Action (ViewController ➡️ ViewModel)
    var action: AnyObserver<Action> { get }
    /// State (ViewModel ➡️ ViewController)
    var state: State { get }
    var dataSource: DataSource! { get set }
}
