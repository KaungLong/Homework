//
//  GitHubAPI.swift
//  GithubSearch
//
//  Created by 10322 on 2024/6/18.
//

import Foundation
import RxSwift
import RxCocoa

class GitHubAPI {
    static func searchRepositories(query: String) -> Observable<[Repository]> {
        let urlString = "https://api.github.com/search/repositories?q=\(query)"
        guard let url = URL(string: urlString) else {
            return Observable.just([])
        }
        
        let request = URLRequest(url: url)
        
        return URLSession.shared.rx.data(request: request)
            .map { data in
                let response = try JSONDecoder().decode(SearchResponse.self, from: data)
                return response.items
            }
            .catchAndReturn([])
    }
}
    
struct SearchResponse: Decodable {
    let items: [Repository]
}

