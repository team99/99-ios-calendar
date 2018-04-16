//
//  Decorator.swift
//  calendar99-demo
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99
import calendar99_logic

public struct AppDecorator {
  fileprivate let dateCellHighlighter: NNSelectionHighlighterType

  public init() {
    dateCellHighlighter = NNHorizontalSelectionHighlighter()
  }
}

extension AppDecorator: NNMonthHeaderDecoratorType {
  public var navigationButtonTintColor: UIColor {
    return .red
  }

  public var monthDescriptionTextColor: UIColor {
    return .red
  }

  public var monthDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 16)
  }
}

extension AppDecorator: NNWeekdayViewDecoratorType {
  public func weekdayCellDecorator(_ indexPath: IndexPath,
                                   _ item: NNCalendar.Weekday)
    -> NNWeekdayCellDecoratorType
  {
    return self
  }
}

extension AppDecorator: NNWeekdayCellDecoratorType {
  public var weekdayDescriptionTextColor: UIColor {
    return UIColor.red
  }

  public var weekdayDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 17)
  }
}

extension AppDecorator: NNDateCellDecoratorType {
  public var selectionHighlighter: NNSelectionHighlighterType {
    return dateCellHighlighter
  }

  public var dateCellTodayMarkerBackground: UIColor {
    return .magenta
  }

  public func dateCellDescTextColor(_ state: NNDateCellDescState) -> UIColor {
    switch state {
    case .normal: return .black
    case .isSelected: return .white
    case .isToday: return .white
    }
  }

  public func dateCellBackground(_ state: NNDateCellBackgroundState) -> UIColor {
    switch state {
    case .normal: return .white
    case .isSelected: return .red
    case .isNotCurrentMonth: return .lightGray
    }
  }
}

extension AppDecorator: NNMonthViewDecoratorType {
  public var monthViewBackgroundColor: UIColor {
    return .white
  }
}

extension AppDecorator: NNMonthSectionDecoratorType {
  public var monthSectionBackgroundColor: UIColor {
    return .white
  }

  public var monthSectionPagingEnabled: Bool {
    return true
  }

  public func dateCellDecorator(_ indexPath: IndexPath, _ item: NNCalendar.Day)
    -> NNDateCellDecoratorType
  {
    return self
  }
}
