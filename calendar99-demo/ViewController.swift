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
  @IBOutlet fileprivate weak var monthSectionView: NNMonthSectionView!
  @IBOutlet fileprivate weak var monthView: NNMonthView!
  fileprivate var componentSb: BehaviorSubject<NNCalendar.MonthComp>!
  fileprivate var dateSelectionSb: BehaviorSubject<Set<Date>>!
  fileprivate var disposable: DisposeBag!

  override public func viewDidLoad() {
    super.viewDidLoad()
    componentSb = BehaviorSubject(value: NNCalendar.MonthComp(Date()))
    dateSelectionSb = BehaviorSubject(value: Set())
    disposable = DisposeBag()

    let monthHeaderModel = NNCalendar.MonthHeader.Model(self)
    let monthHeaderVM = NNCalendar.MonthHeader.ViewModel(monthHeaderModel)
    monthHeader.viewModel = monthHeaderVM

    let monthSectionModel = NNCalendar.MonthSection.Model(self)
    let monthSectionVM = NNCalendar.MonthSection.ViewModel(self, monthSectionModel)
    let pageCount = monthSectionVM.totalMonthCount
    let rowCount = monthSectionVM.rowCount
    let columnCount = monthSectionVM.columnCount
    let layout = NNMonthSectionHorizontalFlowLayout(pageCount, rowCount, columnCount)
    monthSectionView.setCollectionViewLayout(layout, animated: true)
    monthSectionView.viewModel = monthSectionVM

    let monthViewModel = NNCalendar.MonthDisplay.Model(self)
    let monthViewVM = NNCalendar.MonthDisplay.ViewModel(monthViewModel)
    monthView.viewModel = monthViewVM

    dateSelectionSb.do(onNext: {print($0)}).subscribe().disposed(by: disposable!)
  }
}

/// BEWARE MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: NNMonthHeaderModelDependency {
  public var currentComponentStream: Observable<NNCalendar.MonthComp> {
    return componentSb
  }

  public var initialComponentStream: Single<NNCalendar.MonthComp> {
    let date = Date()
    let month = Calendar.current.component(.month, from: date)
    let year = Calendar.current.component(.year, from: date)
    let comps = NNCalendar.MonthComp(month: month, year: year)
    return Single.just(comps)
  }

  public var currentComponentReceiver: AnyObserver<NNCalendar.MonthComp> {
    return componentSb.asObserver()
  }

  public func formatMonthDescription(_ comps: NNCalendar.MonthComp) -> String {
    let components = comps.dateComponents()
    let date = Calendar.current.date(from: components)!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM yyyy"
    return dateFormatter.string(from: date)
  }
}

extension ViewController: NNMonthSectionNonDefaultableModelDependency {
  public var dateSelectionReceiver: AnyObserver<Set<Date>> {
    return dateSelectionSb.asObserver()
  }

  public var dateSelectionStream: Observable<Set<Date>> {
    return dateSelectionSb.asObservable()
  }
}

extension ViewController: NNMonthSectionNonDefaultableViewModelDependency {
  public var pastMonthCountFromCurrent: Int {
    return 100
  }

  public var futureMonthCountFromCurrent: Int {
    return 100
  }
}

extension ViewController: NNMonthDisplayNonDefaultableModelDependency {}
