//
//  WeekdayCell.swift
//  calendar99
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_logic

/// Default weekday cell.
public final class NNWeekdayCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var weekdayLbl: UILabel!

  public func setupWithWeekday(_ weekday: NNCalendar.Weekday) {
    weekdayLbl.text = weekday.description
  }
}
