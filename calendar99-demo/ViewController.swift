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
  @IBOutlet weak var weekdayView: NNWeekdayView!
  @IBOutlet fileprivate weak var monthHeader: NNMonthHeaderView!
  @IBOutlet fileprivate weak var monthSectionView: NNMonthSectionView!
  @IBOutlet fileprivate weak var monthView: NNMonthView!
  fileprivate var monthSb: BehaviorSubject<NNCalendar.Month>!
  fileprivate var dateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var disposable: DisposeBag!
  fileprivate var sequentialCalculator: NNCalendar.DateCalc.Sequential!

  override public func viewDidLoad() {
    super.viewDidLoad()

    let decorator = AppDecorator()
    monthSb = BehaviorSubject(value: NNCalendar.Month(Date()))
    dateSelectionSb = BehaviorSubject(value: Set())
    disposable = DisposeBag()

    let weekdayModel = NNCalendar.SelectWeekday.Model(self)
    let weekdayVM = NNCalendar.SelectWeekday.ViewModel(weekdayModel)
    let monthViewModel = NNCalendar.MonthDisplay.Model(self)
    let monthViewVM = NNCalendar.MonthDisplay.ViewModel(monthViewModel)
    let monthHeaderModel = NNCalendar.MonthHeader.Model(self)
    let monthHeaderVM = NNCalendar.MonthHeader.ViewModel(monthHeaderModel)
    let monthSectionModel = NNCalendar.MonthSection.Model(self)
    let monthSectionVM = NNCalendar.MonthSection.ViewModel(monthSectionModel)

    sequentialCalculator = NNCalendar.DateCalc.Sequential(
      monthSectionVM.rowCount,
      monthSectionVM.columnCount,
      weekdayModel.firstWeekday)

    weekdayView.dependency = (weekdayVM, decorator)
    monthHeader.dependency = (monthHeaderVM, decorator)

    let pageCount = monthSectionVM.totalMonthCount
    let rowCount = monthSectionVM.rowCount
    let columnCount = monthSectionVM.columnCount
    let layout = NNMonthSectionHorizontalFlowLayout(pageCount, rowCount, columnCount)
    monthSectionView.setCollectionViewLayout(layout, animated: true)
    monthSectionView.dependency = (monthSectionVM, decorator)
    monthView.dependency = (monthViewVM, decorator)
  }
}

/// BEWARE: INTENTIONAL MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: NNMonthHeaderNoDefaultModelDependency {
  public var initialMonthStream: Single<NNCalendar.Month> {
    let date = Date()
    let monthValue = Calendar.current.component(.month, from: date)
    let yearValue = Calendar.current.component(.year, from: date)
    return Single.just(NNCalendar.Month(monthValue, yearValue))
  }

  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthSb.asObserver()
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    return monthSb.asObservable()
  }
}

extension ViewController: NNMonthSectionNoDefaultModelDependency {
  public var pastMonthsFromCurrent: Int {
    return 1000
  }

  public var futureMonthsFromCurrent: Int {
    return 1000
  }

  public var allDateSelectionReceiver: AnyObserver<Set<Date>> {
    return dateSelectionSb.asObserver()
  }

  public var allDateSelectionStream: Observable<Set<Date>> {
    return dateSelectionSb.asObservable()
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return (try? dateSelectionSb.value().contains(date)) ?? false
  }

  public func calculateHighlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    let selections = (try? dateSelectionSb.value()) ?? Set()
    return sequentialCalculator.calculateHighlightPart(selections, date)
  }
}

extension ViewController: NNMonthDisplayNoDefaultModelDependency {}
extension ViewController: NNSelectableWeekdayNoDefaultModelDependency {}
