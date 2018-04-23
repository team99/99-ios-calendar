//
//  Regular99Calendar.swift
//  calendar99-preset
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99
import calendar99_presetLogic
import UIKit

/// Regular calendar for 99 applications.
public final class NNRegular99Calendar: UIView {
  public typealias Decorator = NNRegular99CalendarDecoratorType
  public typealias ViewModel = NNRegular99CalendarViewModelType
  public typealias Dependency = (ViewModel, Decorator)

  private var monthHeaderId: String {
    return "regular99_monthHeader"
  }

  private var weekdayViewId: String {
    return "regular99_weekdayView"
  }

  private var monthSectionId: String {
    return "regular99_monthSection"
  }

  fileprivate var monthHeaderView: NNMonthHeaderView? {
    return subviews.first(where: {$0.accessibilityIdentifier == monthHeaderId})
      as? NNMonthHeaderView
  }

  fileprivate var weekdayView: NNWeekdayView? {
    return subviews.first(where: {$0.accessibilityIdentifier == weekdayViewId})
      as? NNWeekdayView
  }

  fileprivate var monthSectionView: NNMonthSectionView? {
    return subviews.first(where: {$0.accessibilityIdentifier == monthSectionId})
      as? NNMonthSectionView
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeViews()
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    initializeViews()
  }

  private func initializeViews() {
    let monthHeader = NNMonthHeaderView()
    let weekdayView = NNWeekdayView()
    let monthSection = NNMonthSectionView()
    monthHeader.accessibilityIdentifier = monthHeaderId
    weekdayView.accessibilityIdentifier = weekdayViewId
    monthSection.accessibilityIdentifier = monthSectionId
    addSubview(monthHeader)
    addSubview(weekdayView)
    addSubview(monthSection)

    // Month header constraints
    let monthHeaderTop =
      NSLayoutConstraint(item: monthHeader,
                         attribute: .top,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .top,
                         multiplier: 1,
                         constant: 0)

    let monthHeaderLeft =
      NSLayoutConstraint(item: monthHeader,
                         attribute: .left,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .left,
                         multiplier: 1,
                         constant: 0)

    let monthHeaderRight =
      NSLayoutConstraint(item: monthHeader,
                         attribute: .right,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .right,
                         multiplier: 1,
                         constant: 0)

    let monthHeaderHeight =
      NSLayoutConstraint(item: monthHeader,
                         attribute: .height,
                         relatedBy: .equal,
                         toItem: nil,
                         attribute: .notAnAttribute,
                         multiplier: 1,
                         constant: 44)

    // Weekday view constraints
    let weekdayViewTop =
      NSLayoutConstraint(item: monthSection,
                         attribute: .bottom,
                         relatedBy: .equal,
                         toItem: weekdayView,
                         attribute: .top,
                         multiplier: 1,
                         constant: 0)

    let weekdayViewLeft =
      NSLayoutConstraint(item: weekdayView,
                         attribute: .left,
                         relatedBy: .equal,
                         toItem: monthHeader,
                         attribute: .left,
                         multiplier: 1,
                         constant: 0)

    let weekdayViewRight =
      NSLayoutConstraint(item: weekdayView,
                         attribute: .right,
                         relatedBy: .equal,
                         toItem: monthSection,
                         attribute: .right,
                         multiplier: 1,
                         constant: 0)

    let weekdayViewHeight =
      NSLayoutConstraint(item: weekdayView,
                         attribute: .height,
                         relatedBy: .equal,
                         toItem: monthHeader,
                         attribute: .height,
                         multiplier: 1,
                         constant: 0)

    // Month section constraints
    let monthSectionTop =
      NSLayoutConstraint(item: weekdayView,
                         attribute: .bottom,
                         relatedBy: .equal,
                         toItem: monthSection,
                         attribute: .top,
                         multiplier: 1,
                         constant: 0)

    let monthSectionLeft =
      NSLayoutConstraint(item: monthSection,
                         attribute: .left,
                         relatedBy: .equal,
                         toItem: weekdayView,
                         attribute: .left,
                         multiplier: 1,
                         constant: 0)

    let monthSectionRight =
      NSLayoutConstraint(item: monthSection,
                         attribute: .right,
                         relatedBy: .equal,
                         toItem: weekdayView,
                         attribute: .right,
                         multiplier: 1,
                         constant: 0)

    let monthSectionBottom =
      NSLayoutConstraint(item: monthSection,
                         attribute: .bottom,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .bottom,
                         multiplier: 1,
                         constant: 0)

    addConstraints([monthHeaderTop,
                    monthHeaderLeft,
                    monthHeaderRight,
                    monthHeaderHeight,
                    weekdayViewTop,
                    weekdayViewLeft,
                    weekdayViewRight,
                    weekdayViewHeight,
                    monthSectionTop,
                    monthSectionLeft,
                    monthSectionRight,
                    monthSectionBottom])
  }
}

// MARK: - Dependencies
public extension NNRegular99Calendar {
  public var dependency: Dependency? {
    get { return nil }
    set { didSetDependency(newValue) }
  }

  private func didSetDependency(_ dependency: Dependency?) {
    guard
      let dependency = dependency,
      let monthHeader = self.monthHeaderView,
      let monthSection = self.monthSectionView,
      let weekdayView = self.weekdayView else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let vm = dependency.0
    let decorator = dependency.1
    monthHeader.dependency = (vm.monthHeaderViewModel(), decorator)
    monthSection.dependency = (vm.monthSectionViewModel(), decorator)
    weekdayView.dependency = (vm.selectableWeekdayViewModel(), decorator)
  }
}
