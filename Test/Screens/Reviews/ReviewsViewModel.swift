import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let photoProvider: PhotoProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        photoProvider: PhotoProvider = PhotoProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.photoProvider = photoProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset,limit: state.limit, completion: gotReviews)
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        switch result {
        case .failure:
            state.shouldLoad = true
        case .success(let reviews):
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            
            if (!state.shouldLoad){
                state.items.append(makeReviewCountItem(reviews.count))
            }
        }
        
        onStateChange?(state)
    }
    
    /// Метод обработки получения фотографии
    func gotAvatarPhoto(_ result: PhotoProvider.GetPhotoResult, with id : UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        
        switch result {
            case .success(let image):
            item.avatar = image
            state.items[index]=item
            onStateChange?(state)
        case .failure:
            break
        }
    }
    
    /// Метод обработки получения фотографии
    func gotReviewPhoto(_ result: PhotoProvider.GetPhotoResult, with id : UUID, at idx: Int) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        
        switch result {
            case .success(let image):
            item.photos[idx]=image
            state.items[index]=item
            onStateChange?(state)
        case .failure:
            break
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig
    typealias ReviewCountItem = ReviewCountCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let username = (review.firstName+" "+review.lastName).attributed(font: .username)
        let avatar = UIImage.defaultAvatar
        let photos: [UIImage?] = (0..<review.photoURLs.count).map { _ in nil }
        let rating = ratingRenderer.ratingImage(review.rating)

        let item = ReviewItem(
            reviewText: reviewText,
            created: created,
            onTapShowMore: showMoreReview,
            username: username,
            avatar: avatar,
            photos: photos,
            rating: rating
        )
        
        if let avatarURL = review.avatarURL {
            photoProvider.getPhoto(url: avatarURL) { result in
                self.gotAvatarPhoto(result, with: item.id)
            }
        }
        
        for (index, photoURL) in review.photoURLs.enumerated() {
            photoProvider.getPhoto(url: photoURL) { result in
                self.gotReviewPhoto(result, with: item.id, at: index)
            }
        }
        return item
    }
    
    func makeReviewCountItem(_ count: Int) -> ReviewCountItem {
        let reviewCountString=String(count)+" " + reviewWord(for: count)
        let reviewCount = reviewCountString.attributed(font: .reviewCount, color: .reviewCount)
        return ReviewCountItem(reviewCount: reviewCount)
    }
    
    
    func reviewWord(for count: Int) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10

        if remainder100 >= 11 && remainder100 <= 14 {
            return "отзывов"
        }

        switch remainder10 {
        case 1:
            return "отзыв"
        case 2...4:
            return "отзыва"
        default:
            return "отзывов"
        }
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
