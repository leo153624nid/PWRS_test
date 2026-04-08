//
//  InfoPresenter.swift
//  PWRS_test
//
//  VIPER Presenter for the Info module.
//

import Foundation

final class InfoPresenter: InfoPresenterProtocol {

    // MARK: - References

    weak var view: InfoViewProtocol?
    var router: InfoRouterProtocol?

    // MARK: - InfoPresenterProtocol

    func viewDidLoad() {
        view?.display(
            title: "О приложении",
            description: """
            PWRS Weather — приложение для просмотра актуальной погоды.

            Показывает текущую температуру, почасовой и трёхдневный прогноз, а также подробные метеопараметры: влажность, ветер, давление, видимость и УФ-индекс.

            Данные предоставляются сервисом WeatherAPI и обновляются при каждом запуске.

            Версия 1.0
            """
        )
    }

    func closeTapped() {
        router?.dismiss()
    }
}
