//
//  Cell.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99_logic

/// Date implementation for calendar view.
public final class NNDateCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var dateLbl: UILabel!

  /// Set up the current cell with a Day.
  ///
  /// - Parameter day: A Day instance.
  public func setupWithDay(_ day: NNCalendar.Day) {
    backgroundColor = day.isCurrentMonth ? .clear : .lightGray
    dateLbl?.text = day.dateDescription
  }
}
