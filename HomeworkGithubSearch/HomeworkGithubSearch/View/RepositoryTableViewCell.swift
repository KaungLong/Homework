//
//  RepositoryTableViewCell.swift
//  HomeworkGithubSearch
//
//  Created by 10322 on 2024/6/19.
//

import UIKit
import SnapKit

class RepositoryTableViewCell: UITableViewCell {
    private let repositoryImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let textStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(repositoryImageView)
        contentView.addSubview(textStackView)
        
        repositoryImageView.contentMode = .scaleAspectFill
        repositoryImageView.clipsToBounds = true
        
        repositoryImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80) 
        }
        
        repositoryImageView.layer.cornerRadius = 40
        repositoryImageView.layer.masksToBounds = true
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        textStackView.axis = .vertical
        textStackView.spacing = 5
        textStackView.addArrangedSubview(nameLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        
        textStackView.snp.makeConstraints { make in
            make.left.equalTo(repositoryImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }

    func configure(with repository: Repository) {
        if let url = URL(string: repository.owner.avatarUrl) {
            repositoryImageView.sd_setImage(with: url, completed: nil)
        }
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
    }
}
