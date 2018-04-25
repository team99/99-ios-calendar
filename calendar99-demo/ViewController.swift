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

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    let decorator = AppDecorator()
    disposable = DisposeBag()

    let dependency = Singleton.instance
    let weekdayModel = NNCalendarLogic.SelectWeekday.Model(dependency)
    let weekdayVM = NNCalendarLogic.SelectWeekday.ViewModel(weekdayModel)
    let monthViewModel = NNCalendarLogic.MonthDisplay.Model(dependency)
    let monthViewVM = NNCalendarLogic.MonthDisplay.ViewModel(monthViewModel)
    let monthHeaderModel = NNCalendarLogic.MonthHeader.Model(dependency)
    let monthHeaderVM = NNCalendarLogic.MonthHeader.ViewModel(monthHeaderModel)
    let monthSectionModel = NNCalendarLogic.MonthSection.Model(dependency)
    let monthSectionVM = NNCalendarLogic.MonthSection.ViewModel(monthSectionModel)

    weekdayView.dependency = (weekdayVM, decorator)
    monthHeader.dependency = (monthHeaderVM, decorator)

    let pageCount = monthSectionVM.totalMonthCount
    let weekdayStacks = monthSectionVM.weekdayStacks
    let layout = NNMonthSectionHorizontalFlowLayout(pageCount, weekdayStacks)
    monthSectionView.setCollectionViewLayout(layout, animated: true)
    monthSectionView.dependency = (monthSectionVM, decorator)
    monthView.dependency = (monthViewVM, decorator)
  }
}
