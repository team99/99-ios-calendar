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
    dateCellHighlighter = NNHorizontalSelectHighlighter()
      .with(cornerRadius: 10)
      .with(horizontalInset: 5)
      .with(verticalInset: 5)
      .with(highlightFillColor: UIColor(
        red: 237 / 255,
        green: 246 / 255,
        blue: 251 / 255,
        alpha: 1))
  }
}

extension AppDecorator: NNMonthHeaderDecoratorType {
  public var navigationButtonTintColor: UIColor {
    return .black
  }

  public var monthDescriptionTextColor: UIColor {
    return .black
  }

  public var monthDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 17)
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
    return UIColor.black
  }

  public var weekdayDescriptionFont: UIFont {
    return UIFont.systemFont(ofSize: 16)
  }
}

extension AppDecorator: NNDateCellDecoratorType {
  public var selectionHighlighter: NNSelectionHighlighterType? {
    return dateCellHighlighter
  }

  public var dateCellTodayMarkerBackground: UIColor {
    return UIColor(red: 56 / 255, green: 147 / 255, blue: 217 / 255, alpha: 1)
  }

  public func dateCellDescTextColor(_ state: NNDateCellDescState) -> UIColor {
    switch state {
    case .normal: return .black
    case .isNotCurrentMonth: return .white

    case .isSelected: return UIColor(
      red: 56 / 255,
      green: 147 / 255,
      blue: 217 / 255,
      alpha: 1)

    case .isToday: return .white
    }
  }

  public func dateCellDescFont(_ state: NNDateCellDescState) -> UIFont {
    switch state {
    case .isSelected, .isToday: return UIFont.boldSystemFont(ofSize: 16)
    default: return UIFont.systemFont(ofSize: 16)
    }
  }

  public func dateCellBackground(_ state: NNDateCellBackgroundState) -> UIColor {
    switch state {
    case .normal: return .white
    case .isSelected: return .white
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
