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
  @IBOutlet fileprivate weak var monthHeader: C99MonthHeaderView!
  @IBOutlet fileprivate weak var monthView: C99MonthView!
  fileprivate var componentSb: BehaviorSubject<Calendar99.Components?>!

  override public func viewDidLoad() {
    super.viewDidLoad()
    componentSb = BehaviorSubject(value: nil)

    let monthHeaderModel = Calendar99.MonthHeader.Model(self)
    let monthHeaderVM = Calendar99.MonthHeader.ViewModel(self, monthHeaderModel)
    monthHeader.viewModel = monthHeaderVM

    let monthViewModel = Calendar99.MonthDisplay.Model(self)
    let monthViewVM = Calendar99.MonthDisplay.ViewModel(self, monthViewModel)
    monthView.viewModel = monthViewVM
  }
}

/// BEWARE MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: C99MonthHeaderModelDependency {
  public var componentStream: Observable<Calendar99.Components> {
    return componentSb.map({$0!})
  }

  public var initialComponentStream: Single<Calendar99.Components> {
    let date = Date()
    let month = Calendar.current.component(.month, from: date)
    let year = Calendar.current.component(.year, from: date)
    let comps = Calendar99.Components(month: month, year: year)
    return Single.just(comps)
  }

  public var componentReceiver: AnyObserver<Calendar99.Components> {
    return componentSb.mapObserver(Optional.some)
  }

  public func formatMonthDescription(_ components: Calendar99.Components) -> String {
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

extension ViewController: C99MonthHeaderViewModelDependency {}

extension ViewController: C99MonthDisplayModelDependency {
  public var columnCount: Int {
    return 7
  }

  public var rowCount: Int {
    return 6
  }
}

extension ViewController: C99MonthDisplayViewModelDependency {}
