/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = 22
    var offset = 0
    var shouldLoad = true
    /// переменная показывает мы уже загрузили какие-то данные, или еще грузим
    var isLoading = true
    var error: Error? = nil
    
    mutating func reset() {
        items.removeAll()
        limit = 22
        offset = 0
        shouldLoad = true
        isLoading = true
        error = nil
    }

}
