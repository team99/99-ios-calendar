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

  /// Store some properties here to perform some custom drawing.
  private var currentDay: NNCalendar.Day?
  private var selectionHighlighter: NNSelectionHighlighterType?

  override public func draw(_ rect: CGRect) {
    super.draw(rect)

    guard
      let context = UIGraphicsGetCurrentContext(),
      let currentDay = self.currentDay,
      let selectionHighlighter = self.selectionHighlighter else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let positions = [NNCalendar.HighlightPosition.start, .end, .mid, .startAndEnd]
    let index = Int(arc4random_uniform(UInt32(positions.count) - 0) + 0)
    let highlightPosition = NNCalendar.HighlightPosition.mid
    selectionHighlighter.drawHighlight(context, rect, highlightPosition)
  }
  
  /// Set up the current cell with a Day.
  ///
  /// - Parameter day: A Day instance.
  public func setupWithDay(_ decorator: NNDateCellDecoratorType,
                           _ day: NNCalendar.Day) {
    self.currentDay = day
    self.selectionHighlighter = decorator.selectionHighlighter
    guard let dateLbl = self.dateLbl else { return }

    if day.isCurrentMonth {
      backgroundColor = decorator.dateCellBackground(.normal)
    } else {
      backgroundColor = decorator.dateCellBackground(.isNotCurrentMonth)
    }

    if day.isSelected {
      backgroundColor = decorator.dateCellBackground(.isSelected)
    }

    dateLbl.text = day.dateDescription
    dateLbl.textColor = decorator.dateCellDescTextColor(.normal)

    contentView.subviews
      .filter({$0.accessibilityIdentifier == circleMarkerId})
      .forEach({$0.removeFromSuperview()})

    // If the day is today, add a circle marker programmatically.
    if day.isToday {
      let circleWidth = bounds.size.width * 2 / 3
      let circleSize = CGSize(width: circleWidth, height: circleWidth)
      let circleFrame = CGRect(origin: CGPoint.zero, size: circleSize)
      let circleMarker = UIView(frame: circleFrame)
      circleMarker.backgroundColor = decorator.dateCellTodayMarkerBackground
      circleMarker.center = CGPoint(x: bounds.midX, y: bounds.midY)
      circleMarker.layer.cornerRadius = circleWidth / 2
      circleMarker.accessibilityIdentifier = circleMarkerId
      contentView.insertSubview(circleMarker, at: 0)
      dateLbl.textColor = decorator.dateCellDescTextColor(.isToday)
    }

    if day.isSelected {
      dateLbl.textColor = decorator.dateCellDescTextColor(.isSelected)
    }
  }
}
