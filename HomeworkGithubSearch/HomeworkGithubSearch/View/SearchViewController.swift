//
//  SearchViewController.swift
//  GithubSearch
//
//  Created by 10322 on 2024/6/18.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: UIViewController, UITableViewDelegate {
    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        self.title = "Repository Search"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSearchBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "請輸入關鍵字搜尋"
        searchBar.showsCancelButton = false
        
        let headerView = UIView()
        headerView.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        bindSearchBar()
        bindTableView()
        bindRefreshControl()
        bindViewModelOutputs()
    }
    
    private func bindSearchBar() {
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                if query.isEmpty {
                    self?.showAlert(title: "警告", message: "請輸入搜尋關鍵字")
                } else {
                    self?.viewModel.search(query: query)
                }
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.clearResults()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        viewModel.repositories
            .drive(tableView.rx.items(cellIdentifier: "Cell", cellType: RepositoryTableViewCell.self)) { (index, repository, cell) in
                cell.configure(with: repository)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Repository.self)
            .subscribe(onNext: { [weak self] repository in
                self?.navigateToDetail(with: repository)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] query in
                if query.isEmpty {
                    self?.showAlert(title: "警告", message: "請輸入搜尋關鍵字")
                } else {
                    self?.viewModel.search(query: query)
                }
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.isLoading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        viewModel.error
            .drive(onNext: { [weak self] error in
                guard !error.isEmpty else { return }
                self?.showAlert(title: "Error", message: error)
            })
            .disposed(by: disposeBag)
    }

    private func navigateToDetail(with repository: Repository) {
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
        let detailVC = DetailViewController(repository: repository)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            updateSearchBarConstraints(hidden: true)
            searchBar.resignFirstResponder()
        } else {
            updateSearchBarConstraints(hidden: false)
        }
    }
    
    private func updateSearchBarConstraints(hidden: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.snp.updateConstraints { make in
                make.height.equalTo(hidden ? 0 : 50)
            }
            self.searchBar.alpha = hidden ? 0 : 1
            self.view.layoutIfNeeded()
        }) { _ in
            self.updateNavigationBarStyle(hidden: hidden)
        }
    }
    
    private func updateNavigationBarStyle(hidden: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = !hidden
        navigationController?.navigationBar.barStyle = hidden ? .black : .default
        let textColor = hidden ? UIColor.white : UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        UIView.performWithoutAnimation {
            navigationController?.navigationBar.setNeedsLayout()
            navigationController?.navigationBar.layoutIfNeeded()
        }
    }
}
