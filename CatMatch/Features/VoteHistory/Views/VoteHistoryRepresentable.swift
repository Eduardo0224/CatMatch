//
//  VoteHistoryRepresentable.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import SwiftUI

// MARK: - VoteHistoryRepresentable

struct VoteHistoryRepresentable: UIViewControllerRepresentable {

    // MARK: - Properties

    let viewModel: VoteHistoryViewModel

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = VoteHistoryViewController(viewModel: viewModel)
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        guard let vc = uiViewController.viewControllers.first as? VoteHistoryViewController else { return }
        vc.reloadAndApplySnapshot()
    }
}
