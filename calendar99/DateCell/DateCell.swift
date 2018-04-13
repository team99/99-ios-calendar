//
//  Cell.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99_logic

/// Date cell implementation for calendar view. This is the default cell that
/// will be used if no custom cells are specified.
public final class NNDateCell: UICollectionViewCell {
  @IBOutlet fileprivate weak var dateLbl: UILabel!

  /// Set up the current cell with a Day.
  ///
  /// - Parameter day: A Day instance.
  public func setupWithDay(_ day: NNCalendar.Day) {
    backgroundColor = day.isCurrentMonth ? .white : .lightGray
    backgroundColor = day.isSelected ? .red : backgroundColor
    dateLbl?.text = day.dateDescription
  }
}
