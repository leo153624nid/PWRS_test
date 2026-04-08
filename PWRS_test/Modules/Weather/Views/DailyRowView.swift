//
//  DailyRowView.swift
//  PWRS_test
//

import UIKit

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
