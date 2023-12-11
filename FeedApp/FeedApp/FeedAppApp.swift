//
//  FeedAppApp.swift
//  FeedApp
//
//  Created by Max Gribov on 25.05.2023.
//

import SwiftUI
import CoreData
import Combine
import Feed
import FeedIOS

@main
struct FeedAppApp: App {
    
    let model = FeedAppModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedView(url: model.feedURL, client: model.client, store: model.store, imageStore: model.imageStore)
                    .navigationTitle("Feed")
            }
        }
    }
}

final class FeedAppModel {
    
    var feedURL: URL {
        
        URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
    }
    
    var client: HTTPClient {
        
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
    
    let store: FeedStore
    let imageStore: FeedImageDataStore
    
    init() {
        
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
        
        let coreDataStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        
        self.store = coreDataStore
        self.imageStore = coreDataStore
    }
}

struct FeedView: UIViewControllerRepresentable {
    
    let url: URL
    let client: HTTPClient
    let store: FeedStore
    let imageStore: FeedImageDataStore
    
    func makeUIViewController(
        context: Context
    ) -> FeedViewController {
          
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let localImageLoader = LocalFeedImageDataLoader(store: imageStore)
        
        return FeedUIComposer.feedComposedWith(
            feedLoader: makeFeedLoader,
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    loader: remoteImageLoader,
                    cache: localImageLoader
                )
            )
        )
    }
    
    func updateUIViewController(_ uiViewController: FeedViewController, context: Context) {}
    
    func makeFeedLoader() -> AnyPublisher<[FeedImage], Error> {
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: { Date() })
        
        return RemoteFeedLoader(url: url, client: client)
            .loadPublisher()
            .cache(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
}

extension FeedLoader {
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        
        Deferred { Future { promise in
            
            load { completion in
                
                promise(completion)
            }
            
        }}.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    
    func cache(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        
        handleEvents(receiveOutput: cache.saveIgnoringCompletion).eraseToAnyPublisher()
    }
}

extension Publisher {
    
    func fallback(to fallback: @escaping () -> AnyPublisher<Output, Error>) -> AnyPublisher<Output, Error> {
        
        self.catch { _ in fallback() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    
    func mainQueueDispatch() -> AnyPublisher<Output, Failure> {
        
        receive(on: DispatchQueue.runOnMainOrDispatchOnMainScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var runOnMainOrDispatchOnMainScheduler: RunOnMainOrDispatchOnMainScheduler {
        RunOnMainOrDispatchOnMainScheduler()
    }
    
    final class RunOnMainOrDispatchOnMainScheduler: Scheduler {
        
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: DispatchQueue.SchedulerTimeType { DispatchQueue.main.now }
        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride { DispatchQueue.main.minimumTolerance }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
