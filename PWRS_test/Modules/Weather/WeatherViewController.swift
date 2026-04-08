//
//  WeatherViewController.swift
//  PWRS_test
//
//  UI layer (VIPER View) — passive. Renders what Presenter sends.
//  Contains no business logic.
//

import UIKit

// MARK: - WeatherViewController

final class WeatherViewController: UIViewController {

    // MARK: - VIPER

    var presenter: WeatherPresenterProtocol?

    // MARK: - UI

    private let gradientLayer = CAGradientLayer()

    // Loading
    private let loadingView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()

    // Error
    private let errorView = UIView()
    private let errorIconLabel = UILabel()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    // Content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let feelsLikeLabel = UILabel()

    // Hourly
    private let hourlyCard = UIView()
    private let hourlyTitleLabel = UILabel()
    private let hourlyDivider = UIView()
    private let hourlyCollectionView: UICollectionView

    // Daily
    private let dailyCard = UIView()
    private let dailyTitleLabel = UILabel()
    private let dailyStackView = UIStackView()

    // Details
    private let detailsCard = UIView()
    private let detailsGridView = UIView()

    // Data
    private var currentDisplayModel: WeatherDisplayModel?

    // MARK: - Init

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 90)
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        hourlyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupLoadingView()
        setupErrorView()
        setupScrollContent()
        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Gradient

    private func setupGradient() {
        gradientLayer.colors = [UIColor(hex: "#2196F3").cgColor, UIColor(hex: "#64B5F6").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func applyGradient(top: String, bottom: String) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.6)
        gradientLayer.colors = [UIColor(hex: top).cgColor, UIColor(hex: bottom).cgColor]
        CATransaction.commit()
    }

    // MARK: - Loading View

    private func setupLoadingView() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activityIndicator)

        loadingLabel.text = "Загрузка погоды..."
        loadingLabel.textColor = .white
        loadingLabel.font = .systemFont(ofSize: 17, weight: .medium)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 12),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor)
        ])
    }

    // MARK: - Error View

    private func setupErrorView() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        view.addSubview(errorView)

        errorIconLabel.text = "⛅"
        errorIconLabel.font = .systemFont(ofSize: 60)
        errorIconLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(errorIconLabel)

        errorLabel.textColor = .white
        errorLabel.font = .systemFont(ofSize: 16)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(errorLabel)

        retryButton.setTitle("Повторить", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        retryButton.layer.cornerRadius = 22
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        errorView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            errorIconLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorIconLabel.topAnchor.constraint(equalTo: errorView.topAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorIconLabel.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor)
        ])
    }

    @objc private func retryTapped() {
        presenter?.retryTapped()
    }

    // MARK: - Scroll Content

    private func setupScrollContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isHidden = true
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        setupHeader()
        setupHourlyCard()
        setupDailyCard()
        setupDetailsCard()
    }

    // MARK: - Header

    private func setupHeader() {
        cityLabel.font = .systemFont(ofSize: 32, weight: .medium)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cityLabel)

        temperatureLabel.font = .systemFont(ofSize: 96, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(temperatureLabel)

        conditionLabel.font = .systemFont(ofSize: 22, weight: .regular)
        conditionLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        conditionLabel.textAlignment = .center
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(conditionLabel)

        feelsLikeLabel.font = .systemFont(ofSize: 17)
        feelsLikeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        feelsLikeLabel.textAlignment = .center
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(feelsLikeLabel)

        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 4),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            conditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 4),
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            conditionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            feelsLikeLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 6),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Hourly Card

    private func setupHourlyCard() {
        styleCard(hourlyCard)
        contentView.addSubview(hourlyCard)

        hourlyTitleLabel.text = "ПОЧАСОВОЙ ПРОГНОЗ"
        styleCardTitle(hourlyTitleLabel)
        hourlyCard.addSubview(hourlyTitleLabel)

        hourlyDivider.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        hourlyDivider.translatesAutoresizingMaskIntoConstraints = false
        hourlyCard.addSubview(hourlyDivider)

        hourlyCollectionView.backgroundColor = .clear
        hourlyCollectionView.showsHorizontalScrollIndicator = false
        hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.reuseID)
        hourlyCard.addSubview(hourlyCollectionView)

        NSLayoutConstraint.activate([
            hourlyCard.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 28),
            hourlyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hourlyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hourlyTitleLabel.topAnchor.constraint(equalTo: hourlyCard.topAnchor, constant: 12),
            hourlyTitleLabel.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 16),
            hourlyTitleLabel.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor, constant: -16),
            hourlyDivider.topAnchor.constraint(equalTo: hourlyTitleLabel.bottomAnchor, constant: 10),
            hourlyDivider.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor, constant: 16),
            hourlyDivider.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor, constant: -16),
            hourlyDivider.heightAnchor.constraint(equalToConstant: 0.5),
            hourlyCollectionView.topAnchor.constraint(equalTo: hourlyDivider.bottomAnchor, constant: 8),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: hourlyCard.leadingAnchor),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: hourlyCard.trailingAnchor),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 100),
            hourlyCollectionView.bottomAnchor.constraint(equalTo: hourlyCard.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Daily Card

    private func setupDailyCard() {
        styleCard(dailyCard)
        contentView.addSubview(dailyCard)

        dailyTitleLabel.text = "ПРОГНОЗ НА 3 ДНЯ"
        styleCardTitle(dailyTitleLabel)
        dailyCard.addSubview(dailyTitleLabel)

        dailyStackView.axis = .vertical
        dailyStackView.spacing = 0
        dailyStackView.translatesAutoresizingMaskIntoConstraints = false
        dailyCard.addSubview(dailyStackView)

        NSLayoutConstraint.activate([
            dailyCard.topAnchor.constraint(equalTo: hourlyCard.bottomAnchor, constant: 16),
            dailyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dailyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dailyTitleLabel.topAnchor.constraint(equalTo: dailyCard.topAnchor, constant: 12),
            dailyTitleLabel.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor, constant: 16),
            dailyTitleLabel.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor, constant: -16),
            dailyStackView.topAnchor.constraint(equalTo: dailyTitleLabel.bottomAnchor, constant: 8),
            dailyStackView.leadingAnchor.constraint(equalTo: dailyCard.leadingAnchor),
            dailyStackView.trailingAnchor.constraint(equalTo: dailyCard.trailingAnchor),
            dailyStackView.bottomAnchor.constraint(equalTo: dailyCard.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Details Card

    private func setupDetailsCard() {
        styleCard(detailsCard)
        contentView.addSubview(detailsCard)

        detailsGridView.translatesAutoresizingMaskIntoConstraints = false
        detailsCard.addSubview(detailsGridView)

        NSLayoutConstraint.activate([
            detailsCard.topAnchor.constraint(equalTo: dailyCard.bottomAnchor, constant: 16),
            detailsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            detailsGridView.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 16),
            detailsGridView.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 16),
            detailsGridView.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -16),
            detailsGridView.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Styling Helpers

    private func styleCard(_ view: UIView) {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func styleCardTitle(_ label: UILabel) {
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Populate Content

    private func populate(with model: WeatherDisplayModel) {
        applyGradient(top: model.gradientTop, bottom: model.gradientBottom)

        cityLabel.text = model.cityName
        temperatureLabel.text = model.temperature
        conditionLabel.text = model.conditionText
        feelsLikeLabel.text = model.feelsLike

        hourlyCollectionView.reloadData()

        dailyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, day) in model.dailyItems.enumerated() {
            dailyStackView.addArrangedSubview(DailyRowView(item: day))
            if index < model.dailyItems.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor.white.withAlphaComponent(0.15)
                divider.translatesAutoresizingMaskIntoConstraints = false
                dailyStackView.addArrangedSubview(divider)
                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                divider.leadingAnchor.constraint(equalTo: dailyStackView.leadingAnchor, constant: 16).isActive = true
                divider.trailingAnchor.constraint(equalTo: dailyStackView.trailingAnchor, constant: -16).isActive = true
            }
        }

        detailsGridView.subviews.forEach { $0.removeFromSuperview() }
        let detailItems: [(icon: String, title: String, value: String)] = [
            ("humidity", "ВЛАЖНОСТЬ", model.humidity),
            ("wind.fill", "ВЕТЕР", "\(model.windSpeed)\n\(model.windDirection)"),
            ("gauge", "ДАВЛЕНИЕ", model.pressure),
            ("eye.fill", "ВИДИМОСТЬ", model.visibility),
            ("sun.max.fill", "УФ-ИНДЕКС", model.uvIndex)
        ]
        buildDetailsGrid(items: detailItems)
    }

    private func buildDetailsGrid(items: [(icon: String, title: String, value: String)]) {
        var cells: [UIView] = items.map { DetailCell(icon: $0.icon, title: $0.title, value: $0.value) }
        if cells.count % 2 != 0 { cells.append(UIView()) }

        var previousRowBottom: NSLayoutYAxisAnchor = detailsGridView.topAnchor
        let spacing: CGFloat = 12
        var index = 0
        while index < cells.count {
            let left = cells[index]
            let right = cells[index + 1]
            left.translatesAutoresizingMaskIntoConstraints = false
            right.translatesAutoresizingMaskIntoConstraints = false
            detailsGridView.addSubview(left)
            detailsGridView.addSubview(right)

            let topConstant: CGFloat = index == 0 ? 0 : spacing
            NSLayoutConstraint.activate([
                left.topAnchor.constraint(equalTo: previousRowBottom, constant: topConstant),
                left.leadingAnchor.constraint(equalTo: detailsGridView.leadingAnchor),
                left.widthAnchor.constraint(equalTo: detailsGridView.widthAnchor, multiplier: 0.5, constant: -spacing / 2),
                right.topAnchor.constraint(equalTo: left.topAnchor),
                right.trailingAnchor.constraint(equalTo: detailsGridView.trailingAnchor),
                right.widthAnchor.constraint(equalTo: left.widthAnchor),
                right.heightAnchor.constraint(equalTo: left.heightAnchor)
            ])

            if index + 2 >= cells.count {
                left.bottomAnchor.constraint(equalTo: detailsGridView.bottomAnchor).isActive = true
            }
            previousRowBottom = left.bottomAnchor
            index += 2
        }
    }
}

// MARK: - WeatherViewProtocol

extension WeatherViewController: WeatherViewProtocol {

    func showLoading() {
        scrollView.isHidden = true
        errorView.isHidden = true
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }

    func showWeather(_ displayModel: WeatherDisplayModel) {
        currentDisplayModel = displayModel
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
        errorView.isHidden = true
        scrollView.isHidden = false
        populate(with: displayModel)
    }

    func showError(_ message: String) {
        scrollView.isHidden = true
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
        errorView.isHidden = false
        errorLabel.text = message
    }
}

// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentDisplayModel?.hourlyItems.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.reuseID, for: indexPath) as! HourlyCell
        if let item = currentDisplayModel?.hourlyItems[indexPath.item] {
            cell.configure(with: item)
        }
        return cell
    }
}

// MARK: - HourlyCell

final class HourlyCell: UICollectionViewCell {
    static let reuseID = "HourlyCell"

    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let tempLabel = UILabel()
    private let rainLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [timeLabel, iconImageView, tempLabel, rainLabel])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        tempLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        tempLabel.textColor = .white

        rainLabel.font = .systemFont(ofSize: 11)
        rainLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: WeatherDisplayModel.HourlyDisplayItem) {
        timeLabel.text = item.time
        iconImageView.image = UIImage(systemName: WeatherIconMapper.sfSymbol(for: item.conditionCode, isDay: item.isDay))
        tempLabel.text = item.temperature
        rainLabel.text = item.chanceOfRain > 0 ? "\(item.chanceOfRain)%" : ""
    }
}

// MARK: - DailyRowView

final class DailyRowView: UIView {

    init(item: WeatherDisplayModel.DailyDisplayItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let dayLabel = UILabel()
        dayLabel.text = item.dayName
        dayLabel.font = .systemFont(ofSize: 17, weight: .medium)
        dayLabel.textColor = .white
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dayLabel)

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: WeatherIconMapper.sfSymbol(for: item.conditionCode, isDay: true))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        let rainLabel = UILabel()
        if item.chanceOfRain > 0 {
            rainLabel.text = "\(item.chanceOfRain)%"
            rainLabel.textColor = UIColor(hex: "#90CAF9")
        }
        rainLabel.font = .systemFont(ofSize: 13)
        rainLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rainLabel)

        let tempLabel = UILabel()
        tempLabel.text = "\(item.tempMax)  \(item.tempMin)"
        tempLabel.font = .systemFont(ofSize: 17, weight: .medium)
        tempLabel.textColor = .white
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tempLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 90),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -20),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            rainLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4),
            rainLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rainLabel.widthAnchor.constraint(equalToConstant: 36),
            tempLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tempLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - DetailCell

final class DetailCell: UIView {

    init(icon: String, title: String, value: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.7)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 22, weight: .medium)
        valueLabel.textColor = .white
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
