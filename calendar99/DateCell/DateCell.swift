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

  private var circleMarkerId: String {
    return "DateCellCircleMarker"
  }
  
  /// Set up the current cell with a Day.
  ///
  /// - Parameter day: A Day instance.
  public func setupWithDay(_ day: NNCalendar.Day) {
    guard let dateLbl = self.dateLbl else { return }
    backgroundColor = day.isCurrentMonth ? .white : .lightGray
    backgroundColor = day.isSelected ? .red : backgroundColor
    dateLbl.text = day.dateDescription
    dateLbl.textColor = .black

    contentView.subviews
      .first(where: {$0.accessibilityIdentifier == circleMarkerId})?
      .removeFromSuperview()

    // If the day is today, add a circle marker programmatically.
    if day.isToday {
      let circleWidth = bounds.size.width * 2 / 3
      let circleSize = CGSize(width: circleWidth, height: circleWidth)
      let circleFrame = CGRect(origin: CGPoint.zero, size: circleSize)
      let circleMarker = UIView(frame: circleFrame)
      circleMarker.backgroundColor = .blue
      circleMarker.center = CGPoint(x: bounds.midX, y: bounds.midY)
      circleMarker.layer.cornerRadius = circleWidth / 2
      circleMarker.accessibilityIdentifier = circleMarkerId
      contentView.insertSubview(circleMarker, at: 0)
      dateLbl.textColor = .white
    }

    dateLbl.textColor = day.isSelected ? .white : dateLbl.textColor
  }
}
