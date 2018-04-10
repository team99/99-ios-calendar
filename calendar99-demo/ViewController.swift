//
//  ViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import UIKit
import calendar99_logic
import calendar99

public final class ViewController: UIViewController  {
  @IBOutlet fileprivate weak var monthHeader: NNMonthHeaderView!
  @IBOutlet fileprivate weak var monthView: NNMonthView!
  fileprivate var componentSb: BehaviorSubject<NNCalendar.Components?>!

  override public func viewDidLoad() {
    super.viewDidLoad()
    componentSb = BehaviorSubject(value: nil)

    let monthHeaderModel = NNCalendar.MonthHeader.Model(self)
    let monthHeaderVM = NNCalendar.MonthHeader.ViewModel(monthHeaderModel)
    monthHeader.viewModel = monthHeaderVM

    let monthViewModel = NNCalendar.MonthDisplay.Model(self)
    let monthViewVM = NNCalendar.MonthDisplay.ViewModel(self, monthViewModel)
    monthView.viewModel = monthViewVM
  }
}

/// BEWARE MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: NNMonthHeaderModelDependency {
  public var componentStream: Observable<NNCalendar.Components> {
    return componentSb.map({$0!})
  }

  public var initialComponentStream: Single<NNCalendar.Components> {
    let date = Date()
    let month = Calendar.current.component(.month, from: date)
    let year = Calendar.current.component(.year, from: date)
    let comps = NNCalendar.Components(month: month, year: year)
    return Single.just(comps)
  }

  public var componentReceiver: AnyObserver<NNCalendar.Components> {
    return componentSb.mapObserver(Optional.some)
  }

  public func formatMonthDescription(_ components: NNCalendar.Components) -> String {
    let month = components.month
    let year = components.year
    var components = DateComponents()
    components.setValue(month, for: .month)
    components.setValue(year, for: .year)
    let date = Calendar.current.date(from: components)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM yyyy"
    return dateFormatter.string(from: date)
  }
}

extension ViewController: NNMonthDisplayModelDependency {
  public var dateCalculator: NNDateCalculatorType {
    return NNCalendar.DateCalculator.Sequential()
  }

  public var firstDayOfWeek: Int {
    return 1
  }

  public var columnCount: Int {
    return 7
  }

  public var rowCount: Int {
    return 6
  }
}

extension ViewController: NNMonthDisplayViewModelDependency {}
