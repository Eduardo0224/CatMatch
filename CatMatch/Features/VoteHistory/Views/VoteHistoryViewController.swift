//
//  VoteHistoryViewController.swift
//  CatMatch
//
//  Created by Eduardo Andrade on 29/06/26.
//

import UIKit
import CatUI

// MARK: - VoteHistoryViewController

final class VoteHistoryViewController: UIViewController {

    // MARK: - Section

    private enum Section {
        case main
    }

    // MARK: - Private Properties

    private let viewModel: VoteHistoryViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, Vote.ID>?

    // MARK: - Private Views (closure-based init)

    private lazy var filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            L10n.VoteHistory.filterAll,
            L10n.VoteHistory.filterLikes,
            L10n.VoteHistory.filterDislikes
        ])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
        control.setTitleTextAttributes([.foregroundColor: UIColor.catAccent], for: .selected)
        return control
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.VoteHistory.empty
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .catTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.allowsSelection = false
        cv.contentInsetAdjustmentBehavior = .automatic
        return cv
    }()

    // MARK: - Initializers

    init(viewModel: VoteHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupDataSource()
        applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAndApplySnapshot()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = L10n.VoteHistory.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.titleView = filterControl
    }

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.showsSeparators = false
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self,
                  let voteID = self.dataSource?.itemIdentifier(for: indexPath) else {
                return nil
            }

            let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
                self.deleteVote(id: voteID)
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .catDestructive

            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Vote.ID> { [weak self] cell, _, voteID in
            guard let self, let vote = self.viewModel.vote(for: voteID) else { return }

            let catVoteType: CatVoteCellConfiguration.VoteType = vote.voteType == .like ? .like : .dislike

            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
            cell.contentConfiguration = CatVoteCellConfiguration(
                breedName: vote.breedName,
                imageURL: vote.imageUrl,
                voteType: catVoteType,
                date: vote.date
            )
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Vote.ID>(
            collectionView: collectionView
        ) { collectionView, indexPath, voteID in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: voteID
            )
        }
    }

    // MARK: - Snapshot

    func reloadAndApplySnapshot() {
        viewModel.loadVotes()
        applySnapshot()
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Vote.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.filteredVoteIDs)
        snapshot.reconfigureItems(viewModel.filteredVoteIDs)

        dataSource?.apply(snapshot, animatingDifferences: true)
        emptyLabel.isHidden = !viewModel.isEmpty
    }

    // MARK: - Actions

    @objc
    private func filterChanged(_ sender: UISegmentedControl) {
        let filterType: VoteHistoryViewModel.FilterType
        switch sender.selectedSegmentIndex {
        case 0: filterType = .all
        case 1: filterType = .likes
        case 2: filterType = .dislikes
        default: return
        }
        viewModel.setFilter(filterType)
        applySnapshot()
    }

    private func deleteVote(id: Vote.ID) {
        viewModel.deleteVote(id: id)
        applySnapshot()
    }
}
