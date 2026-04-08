//
//  InfoProtocols.swift
//  PWRS_test
//
//  VIPER contracts for the Info module.
//

import UIKit

// MARK: - View ← Presenter

@MainActor
protocol InfoViewProtocol: AnyObject {
    func display(title: String, description: String)
}

// MARK: - Presenter ← View

protocol InfoPresenterProtocol: AnyObject {
    func viewDidLoad()
    func closeTapped()
}

// MARK: - Router

protocol InfoRouterProtocol: AnyObject {
    static func buildModule() -> UIViewController
    func dismiss()
}
