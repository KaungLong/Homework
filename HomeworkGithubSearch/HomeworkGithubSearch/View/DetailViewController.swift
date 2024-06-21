//
//  DetailViewController.swift
//  GithubSearch
//
//  Created by 10322 on 2024/6/18.
//

import UIKit
import SDWebImage
import SnapKit

class DetailViewController: UIViewController {
    
    var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        navigationItem.backBarButtonItem = backButton
    }
    
    private func setupUI() {
        let nameLabel = UILabel()
        nameLabel.text = repository.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        
        let ownerImageView = UIImageView()
        if let url = URL(string: repository.owner.avatarUrl) {
            ownerImageView.sd_setImage(with: url, completed: nil)
        }
        ownerImageView.contentMode = .scaleAspectFit
        
        let fullNameLabel = UILabel()
        fullNameLabel.text = repository.fullName
        fullNameLabel.textAlignment = .center
        
        let languageLabel = UILabel()
        languageLabel.text = "Written in \(repository.language ?? "N/A")"
        
        let starsLabel = UILabel()
        starsLabel.text = "\(repository.stargazersCount) stars"
        
        let watchersLabel = UILabel()
        watchersLabel.text = "\(repository.watchersCount) watchers"
        
        let forksLabel = UILabel()
        forksLabel.text = "\(repository.forksCount) forks"
        
        let issuesLabel = UILabel()
        issuesLabel.text = "\(repository.openIssuesCount) open issues"
        
        let statsStackView = UIStackView(arrangedSubviews: [languageLabel, starsLabel, watchersLabel, forksLabel, issuesLabel])
        statsStackView.axis = .vertical
        statsStackView.spacing = 5
        
        let mainStackView = UIStackView(arrangedSubviews: [nameLabel, ownerImageView, fullNameLabel, statsStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .center
        
        view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        ownerImageView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
    }
}
