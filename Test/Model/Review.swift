/// Модель отзыва.

import Foundation
struct Review: Decodable {

    /// Имя автора.
    let firstName: String
    /// Фамилия автора.
    let lastName: String
    /// Рейтинг отзыва.
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Ссылка на фотографию автора
    let avatarURL: URL?
    /// Коллекция фотографий для отзыва
    let photoURLs: [URL]

    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case text
        case created
        case avatarURL = "avatar_url"
        case photoURLs = "photo_urls"
    }
}
