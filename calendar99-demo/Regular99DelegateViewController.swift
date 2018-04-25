//
//  Regular99DelegateViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic
import calendar99_preset
import calendar99_legacy

public final class Regular99DelegateViewController: UIViewController {
  @IBOutlet fileprivate weak var regular99Calendar: NNRegular99Calendar!
  fileprivate var currentMonth: NNCalendarLogic.Month?
  fileprivate var selections: Set<NNCalendarLogic.Selection>?

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    regular99Calendar!.noDefaultLegacyDependency = (self, decorator)
  }
}

extension Regular99DelegateViewController: NNRegular99CalendarNoDefaultDelegate {
  public func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(4, 2018)
  }

  public func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(10, 2018)
  }

  public func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(6, 2018)
  }

  public func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return currentMonth ?? initialMonth(for: calendar)
  }

  public func regular99(_ calendar: NNRegular99Calendar,
                        onCurrentMonthChangedTo month: NNCalendarLogic.Month) {
    currentMonth = month
  }

  public func currentSelections(for calendar: NNRegular99Calendar)
    -> Set<NNCalendarLogic.Selection>?
  {
    return selections
  }

  public func regular99(_ calendar: NNRegular99Calendar,
                        onSelectionChangedTo selections: Set<NNCalendarLogic.Selection>) {
    self.selections = selections
  }

  public func regular99(_ calendar: NNRegular99Calendar,
                        isDateSelected date: Date) -> Bool {
    return selections?.contains(where: {$0.contains(date)}) ?? false
  }

  public func regular99(_ calendar: NNRegular99Calendar,
                        highlightPartFor date: Date) -> NNCalendarLogic.HighlightPart {
    return selections.map({NNCalendarLogic.Util.highlightPart($0, date)}).getOrElse(.none)
  }
}
