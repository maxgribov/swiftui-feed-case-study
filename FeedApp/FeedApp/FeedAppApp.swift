//
//  FeedAppApp.swift
//  FeedApp
//
//  Created by Max Gribov on 25.05.2023.
//

import SwiftUI
import Feed
import FeedIOS
import CoreData

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
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: { Date() })
        
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        let localImageLoader = LocalFeedImageDataLoader(store: imageStore)
        
        return FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    loader: remoteFeedLoader,
                    cache: localFeedLoader
                ),
                fallback: localFeedLoader
            ),
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
}

