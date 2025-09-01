import SwiftUI
import Storage
import Combine

struct FavoritesView: View {
    
    @StateObject
    private var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {

        NavigationView {

            VStack {

                if viewModel.savedArticles.isEmpty {
                    EmptyFavoritesView()

                } else {
                    List {
                        ForEach(viewModel.savedArticles, id: \.id) { article in
                            FavoriteRowView(article: article, onTapFavorite: viewModel.onTapFavorite)
                        }
                        .onDelete(perform: viewModel.deleteArticles)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    
    @Published var savedArticles: [Article] = []
    
    private let articlesStorage: ArticlesStorage
    private var cancellables = Set<AnyCancellable>()
    let onTapFavorite: (Article) -> Void
    
    init(articlesStorage: ArticlesStorage, onTapFavorite: @escaping (Article) -> Void) {

        self.articlesStorage = articlesStorage
        self.onTapFavorite = onTapFavorite
        
        articlesStorage.articlesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                self?.savedArticles = articles
            }
            .store(in: &cancellables)
    }
    
    func loadFavorites() {
        savedArticles = articlesStorage.articles
    }
        
    func deleteArticles(at offsets: IndexSet) {
        for index in offsets {
            let article = savedArticles[index]
            articlesStorage.removeArticle(article.url)
        }
    }
}
