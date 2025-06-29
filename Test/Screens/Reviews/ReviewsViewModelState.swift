/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = 22
    var offset = 0
    var shouldLoad = true

}
