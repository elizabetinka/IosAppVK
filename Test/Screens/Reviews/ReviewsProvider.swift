import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {

    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsProvider {

    typealias GetReviewsResult = Result<Reviews, GetReviewsError>

    enum GetReviewsError: Error, LocalizedError {

        case badURL
        case badData(Error)
        
        var errorDescription: String? {
            switch self {
            case .badURL:
                return "Неверный url"
            case .badData(let underlying):
                return "Ошибка данных: \(underlying.localizedDescription)"
            }
        }

    }

    func getReviews(offset: Int = 0,limit: Int = 20, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            return completion(.failure(.badURL))
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            // Симулируем сетевой запрос - не менять
            usleep(.random(in: 100_000...1_000_000))

            do {
                // симулирую ошибку
//              throw GetReviewsError.badURL
                let data = try Data(contentsOf: url)
                let reviews = try self.decoder.decode(Reviews.self, from: data)
                let items = reviews.items.prefix(limit)
                completion(.success(Reviews(items: Array(items), count: reviews.count)))
            } catch {
                completion(.failure(.badData(error)))
            }
        }
    }

}
