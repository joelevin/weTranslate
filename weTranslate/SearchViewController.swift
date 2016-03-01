//
//  SearchViewController.swift
//  weTranslate
//
//  Created by Lionel on 2/14/16.
//  Copyright © 2016 weTranslate. All rights reserved.
//

import UIKit
import TranslateKit

protocol SearchViewControllerDelegate: class {
    func searchViewController(searchViewController: SearchViewController, didSearchWord word: String, fromLanguage: Language, toLanguage: Language)
}

final class SearchViewController: UIViewController {

    // MARK: - Type

    enum State {
        case Default
        case Loading
        case Result(TranslationViewModel)
        case NoResult(NoResultViewModel)
        case Error
    }


    // MARK: - Properties

    var state: State = .Default {
        didSet {
            switch state {
            case .Default:
                noResultView.hidden = true
                tableView.hidden = false
                viewModel = nil
            case .Loading:
                noResultView.hidden = true
                tableView.hidden = false
            case .Result(let translationViewModel):
                noResultView.hidden = true
                tableView.hidden = false
                viewModel = translationViewModel
            case .NoResult(let noResultViewModel):
                noResultView.hidden = false
                tableView.hidden = true
                noResultView.viewModel = noResultViewModel
            case .Error:
                noResultView.hidden = false
                tableView.hidden = true
            }
            tableView.reloadData()
        }
    }

    private var viewModel: TranslationViewModel?

    private weak var delegate: SearchViewControllerDelegate?

    private let searchHeaderViewController: SearchHeaderViewController = {
        let searchHeaderViewController = SearchHeaderViewController()
        return searchHeaderViewController
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        return tableView
    }()

    private let translationView: TranslationView = {
        let translationView = TranslationView(frame: .zero)
        translationView.translatesAutoresizingMaskIntoConstraints = false
        return translationView
    }()

    private let noResultView: NoResultView = {
        let view = NoResultView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidden = true
        return view
    }()

    private let bodyView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.spacing = 5
        stackView.opaque = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        stackView.layoutMarginsRelativeArrangement = true
        return stackView
    }()


    // MARK: - Init

    init(delegate: SearchViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        view.backgroundColor = Color.brand

        addChildViewController(searchHeaderViewController)
        searchHeaderViewController.didMoveToParentViewController(self)
        searchHeaderViewController.delegate = self

        tableView.registerClass(WordTableViewCell.self, forCellReuseIdentifier: WordTableViewCell.cellIdentifier)
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: TableViewCell.cellIdentifier)
        tableView.registerClass(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self

        bodyView.addArrangedSubview(searchHeaderViewController.view)
        bodyView.addArrangedSubview(noResultView)
        bodyView.addArrangedSubview(tableView)
        view.addSubview(bodyView)

        bodyView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        bodyView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        bodyView.topAnchor.constraintEqualToAnchor(topLayoutGuide.topAnchor).active = true
        bodyView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor).active = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
}

extension SearchViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard case .Result(let translationViewModel) = state else { return 1 }

        return translationViewModel.translation.meanings.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .Result(let translationViewModel) = state else { return 1 }

        return translationViewModel.translation.meanings[section].translatedWords.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch state {
        case .Default:
            break
        case .Loading:
            if let cell = tableView.dequeueReusableCellWithIdentifier(LoadingTableViewCell.cellIdentifier, forIndexPath: indexPath) as? LoadingTableViewCell {
                cell.activityIndicator.startAnimating()
                return cell
            }
        case .Result(_):
            break
        case .NoResult:
            break
        case .Error:
            break
        }

        guard case .Result(let translationViewModel) = state else { return UITableViewCell() }


        let wordViewModel = WordViewModel(word: translationViewModel.translation.meanings[indexPath.section].translatedWords[indexPath.row])

        if indexPath.row == 0  && indexPath.section == 0 {
            translationView.viewModel = wordViewModel
            return TableViewCell(reuseIdentifier: "TranslationTableViewCell", view: translationView)

        } else if let cell = tableView.dequeueReusableCellWithIdentifier(WordTableViewCell.cellIdentifier, forIndexPath: indexPath) as? WordTableViewCell {
            cell.viewModel = wordViewModel
            return cell
        }

        return UITableViewCell()
    }
}


extension SearchViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // FIXME: Push to detail
    }
}


extension SearchViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchHeaderViewController.resignFirstResponder()
    }
}


extension SearchViewController: SearchHeaderViewControllerDelegate {
    func searchHeaderViewController(searchHeaderViewController: SearchHeaderViewController, didSearchWord word: String, fromLanguage: Language, toLanguage: Language) {
        state = .Loading
        delegate?.searchViewController(self, didSearchWord: word, fromLanguage: fromLanguage, toLanguage: toLanguage)
    }

    func searchHeaderViewControllerDidResetSearch(searchHeaderViewController: SearchHeaderViewController) {
        state = .Default
    }

}
