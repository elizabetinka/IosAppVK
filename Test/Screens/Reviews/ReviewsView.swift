import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    var refreshDelegate: RefreshDelegate?
    let activityIndicator = UIActivityIndicatorView(style: .large)

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
    }
    
    func reloadData(state: ReviewsViewModelState) {
        if state.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
        tableView.reloadData()
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicator()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewCountCell.self, forCellReuseIdentifier: ReviewCountCellConfig.reuseId)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func startLoading() {
        if !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            tableView.isUserInteractionEnabled = false
        }
    }

   func stopLoading() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        if activityIndicator.isAnimating {
            refreshControl.endRefreshing()
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            tableView.isUserInteractionEnabled = true
        }
    }
    
    
    @objc private func refresh() {
        refreshDelegate?.refresh()
    }

}
