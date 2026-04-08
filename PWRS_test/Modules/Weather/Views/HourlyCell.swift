//
//  HourlyCell.swift
//  PWRS_test
//

import UIKit

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
