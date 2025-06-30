import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Максимальное отображаемое фотографий. По умолчанию 5.
    static let maxPhotos = 5
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    /// Имя+Фамилия пользователя
    let username: NSAttributedString
    /// аватар пользователя
    var avatar: UIImage
    /// фотографии отзыва
    var photos: [UIImage?]
    /// фотография рейтинга
    let rating: UIImage

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.username.attributedText = username
        cell.rating.image = rating
        cell.avatar.image = avatar
        
        for (index, photo) in cell.photos.enumerated()  {
            photo.image = nil
            photo.layer.borderWidth = 0
            photo.layer.borderColor = nil
            cell.photoActivityIndicators[index].stopAnimating()
        }
        
        for (index, photo) in photos.enumerated() {
            if (index >= cell.photos.count){
                break
            }
            cell.photos[index].image = photo
            if photo == nil {
                cell.photos[index].layer.borderWidth = 1.0
                cell.photos[index].layer.borderColor = UIColor.lightGray.cgColor
                cell.photoActivityIndicators[index].startAnimating()
            }
        }
        
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let username = UILabel()
    fileprivate let avatar =  UIImageView()
    fileprivate var photos: [UIImageView] = (0..<Config.maxPhotos).map { _ in UIImageView() }
    fileprivate var photoActivityIndicators: [UIActivityIndicatorView] = (0..<Config.maxPhotos).map { _ in UIActivityIndicatorView() }
    fileprivate let rating = UIImageView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        username.frame = layout.usernameLabelFrame
        rating.frame = layout.ratingImageFrame
        avatar.frame = layout.avatarFrame
        
        for (index, frame) in layout.photoFrames.enumerated() {
            photos[index].frame = frame
            photoActivityIndicators[index].center = CGPoint(x: frame.midX, y: frame.midY)
        }
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAvatarImage()
        setupUsernameLabel()
        setupRatingImage()
        setupPhotos()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(username)
    }
    
    func setupRatingImage() {
        contentView.addSubview(rating)
    }
    
    func setupAvatarImage() {
        contentView.addSubview(avatar)
        avatar.layer.cornerRadius = Layout.avatarCornerRadius
        avatar.clipsToBounds = true
    }
    
    func setupPhotos() {
        
        photos.forEach {
            contentView.addSubview($0)
            $0.layer.cornerRadius = Layout.photoCornerRadius
            $0.clipsToBounds = true
        }

        photoActivityIndicators.forEach {
            contentView.addSubview($0)
        }
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
    }
    

    @objc private func didTapShowMore() {
        if let config = config {
            config.onTapShowMore(config.id)
        }
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingImageFrame = CGRect.zero
    private(set) var avatarFrame = CGRect.zero
    private(set) var photoFrames: [CGRect] = (0..<Config.maxPhotos).map { _ in CGRect.zero }
    private(set) var activityCenters: [CGPoint] = (0..<Config.maxPhotos).map { _ in CGPoint.zero }

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        
        var maxY = insets.top
        var maxX = insets.left
        
        avatarFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: Self.avatarSize
        )
        
        maxX = avatarFrame.maxX + avatarToUsernameSpacing
        let width = maxWidth - insets.right - maxX

        var showShowMoreButton = false
        
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.username.boundingRect(width: width).size
        )
        maxY = usernameLabelFrame.maxY + usernameToRatingSpacing
        
        ratingImageFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.rating.size
        )
        maxY = ratingImageFrame.maxY + ratingToPhotosSpacing
        
        if !config.photos.isEmpty {
            let limitedPhotos = Array(config.photos.prefix(Config.maxPhotos))
            photoFrames = []
            
            var photoX = maxX
            
            for _ in limitedPhotos {
                let frame = CGRect(origin: CGPoint(x: photoX, y: maxY), size: Self.photoSize)
                photoFrames.append(frame)
                photoX += Self.photoSize.width + photosSpacing
            }
            maxY += Self.photoSize.height + photosToTextSpacing
        }

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
