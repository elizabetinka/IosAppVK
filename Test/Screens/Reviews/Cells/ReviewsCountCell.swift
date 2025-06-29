import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCountCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCountCellConfig.self)
    /// количество отзывов
    let reviewCount: NSAttributedString

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCountCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCountCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.reviewCountLabel.attributedText = reviewCount
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Cell

final class ReviewCountCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewCountLabel = UILabel()

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
        reviewCountLabel.frame = layout.reviewCountLabelFrame
    }

}

// MARK: - Private

private extension ReviewCountCell {

    func setupCell() {
        setupReviewCountLabel()
    }

    func setupReviewCountLabel() {
        contentView.addSubview(reviewCountLabel)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCountCellLayout {
    
    // MARK: - Фреймы

    private(set) var reviewCountLabelFrame = CGRect.zero

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        
        let labelSize = config.reviewCount.boundingRect(width: maxWidth).size

        let centerX = (maxWidth - labelSize.width) / 2
        let centerY = labelSize.height / 2

        reviewCountLabelFrame = CGRect(
            origin: CGPoint(x: centerX, y: centerY),
            size: labelSize
        )
        
        return reviewCountLabelFrame.maxY
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCountCellConfig
fileprivate typealias Layout = ReviewCountCellLayout
