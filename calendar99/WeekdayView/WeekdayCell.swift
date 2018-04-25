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

  public func setupWithWeekday(_ decorator: NNWeekdayCellDecoratorType,
                               _ weekday: NNCalendarLogic.Weekday) {
    guard let weekdayLbl = self.weekdayLbl else { return }
    weekdayLbl.text = weekday.description
    weekdayLbl.textColor = decorator.weekdayDescriptionTextColor
    weekdayLbl.font = decorator.weekdayDescriptionFont
  }
}
