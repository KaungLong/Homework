//
//  SearchViewModel.swift
//  GithubSearch
//
//  Created by 10322 on 2024/6/18.
//

import RxSwift
import RxCocoa

class SearchViewModel {
    private let disposeBag = DisposeBag()
    let searchText = PublishSubject<String>()

    let repositories: Driver<[Repository]>
    let isLoading: Driver<Bool>
    let error: Driver<String>
    
    private let repositoriesSubject = BehaviorSubject<[Repository]>(value: [])
    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let errorSubject = BehaviorSubject<String>(value: "")
    
    init() {
        repositories = repositoriesSubject.asDriver(onErrorJustReturn: [])
        isLoading = isLoadingSubject.asDriver(onErrorJustReturn: false)
        error = errorSubject.asDriver(onErrorJustReturn: "")
        
        searchText
            .flatMapLatest { [weak self] query -> Observable<[Repository]> in
                self?.isLoadingSubject.onNext(true)
                return GitHubAPI.searchRepositories(query: query)
                    .do(onNext: { _ in
                        self?.isLoadingSubject.onNext(false)
                    }, onError: { error in
                        self?.isLoadingSubject.onNext(false)
                        self?.errorSubject.onNext("An error occurred")
                    })
                    .catchAndReturn([])
            }
            .bind(to: repositoriesSubject)
            .disposed(by: disposeBag)
    }
    
    func search(query: String) {
        searchText.onNext(query)
    }
    
    func clearResults() {
        searchText.onNext("")
    }
}
