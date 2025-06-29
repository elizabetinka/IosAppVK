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

    enum GetReviewsError: Error {

        case badURL
        case badData(Error)

    }

    func getReviews(offset: Int = 0,limit: Int = 20, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            return completion(.failure(.badURL))
        }

        // Симулируем сетевой запрос - не менять
        usleep(.random(in: 100_000...1_000_000))

        do {
            let data = try Data(contentsOf: url)
            var reviews = try decoder.decode(Reviews.self, from: data)
            var items = reviews.items.prefix(limit)
            completion(.success(Reviews(items: Array(items), count: reviews.count)))
        } catch {
            completion(.failure(.badData(error)))
        }
    }

}
