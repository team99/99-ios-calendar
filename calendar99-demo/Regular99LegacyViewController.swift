//
//  Regular99LegacyViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic
import calendar99_preset
import calendar99_legacy

public final class Regular99LegacyViewController: UIViewController {
  @IBOutlet fileprivate weak var regular99Calendar: NNRegular99Calendar!

  deinit {
    print("DEINIT \(self)")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    regular99Calendar!.legacyDependencyLevel2 = (self, decorator)
  }
}

// MARK: - NNRegular99CalendarNoDefaultDelegate
extension Regular99LegacyViewController: NNRegular99CalendarNoDefaultDelegate {
  public func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(4, 2018)
  }

  public func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(10, 2018)
  }

  public func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
    return NNCalendarLogic.Month(6, 2018)
  }

  public func regular99(_ calendar: NNRegular99Calendar,
                        currentMonthChanged month: NNCalendarLogic.Month) {}

  public func regular99(_ calendar: NNRegular99Calendar,
                        selectionChanged selections: Set<NNCalendarLogic.Selection>) {}
}
