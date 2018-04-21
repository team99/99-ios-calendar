//
//  ViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import UIKit
import calendar99_logic
import calendar99_redux
import calendar99

public final class ViewController: UIViewController  {
  @IBOutlet weak var weekdayView: NNWeekdayView!
  @IBOutlet fileprivate weak var monthHeader: NNMonthHeaderView!
  @IBOutlet fileprivate weak var monthSectionView: NNMonthSectionView!
  @IBOutlet fileprivate weak var monthView: NNMonthView!
  fileprivate var disposable: DisposeBag!

  override public func viewDidLoad() {
    super.viewDidLoad()

    let decorator = AppDecorator()
    disposable = DisposeBag()

    let weekdayModel = NNCalendar.SelectWeekday.Model(self)
    let weekdayVM = NNCalendar.SelectWeekday.ViewModel(weekdayModel)
    let monthViewModel = NNCalendar.MonthDisplay.Model(self)
    let monthViewVM = NNCalendar.MonthDisplay.ViewModel(monthViewModel)
    let monthHeaderModel = NNCalendar.MonthHeader.Model(self)
    let monthHeaderVM = NNCalendar.MonthHeader.ViewModel(monthHeaderModel)
    let monthSectionModel = NNCalendar.MonthSection.Model(self)
    let monthSectionVM = NNCalendar.MonthSection.ViewModel(monthSectionModel)

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
    return Singleton.instance.reduxStore.actionTrigger()
      .mapObserver(ReduxCalendar.Action.updateCurrentMonth)
  }

  public var currentMonthStream: Observable<NNCalendar.Month> {
    let path = ReduxCalendar.Action.currentMonthPath

    return Singleton.instance.reduxStore
      .stateValueStream(NNCalendar.Month.self, path)
      .filter({$0.isSuccess}).map({$0.value!})
  }
}

extension ViewController: NNMonthSectionNoDefaultModelDependency {
  public var firstWeekday: Int {
    return 5
  }

  public var pastMonthsFromCurrent: Int {
    return 1000
  }

  public var futureMonthsFromCurrent: Int {
    return 1000
  }

  public var allSelectionReceiver: AnyObserver<Set<NNCalendar.Selection>> {
    return Singleton.instance.reduxStore.actionTrigger()
      .mapObserver(ReduxCalendar.Action.updateSelection)
  }

  public var allSelectionStream: Observable<Try<Set<NNCalendar.Selection>>> {
    let path = ReduxCalendar.Action.selectionPath
    
    return Singleton.instance.reduxStore
      .stateValueStream(Set<NNCalendar.Selection>.self, path)
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return Singleton.instance.reduxStore
      .lastState.flatMap({$0.stateValue(ReduxCalendar.Action.selectionPath)})
      .cast(Set<NNCalendar.Selection>.self)
      .map({$0.contains(where: {$0.contains(date)})})
      .getOrElse(false)
  }

  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return Singleton.instance.reduxStore
      .lastState.flatMap({$0.stateValue(ReduxCalendar.Action.selectionPath)})
      .cast(Set<NNCalendar.Selection>.self)
      .map({NNCalendar.Util.highlightPart($0, date)})
      .getOrElse(.none)
  }
}

extension ViewController: NNMonthDisplayNoDefaultModelDependency {}
extension ViewController: NNSelectableWeekdayNoDefaultModelDependency {}
