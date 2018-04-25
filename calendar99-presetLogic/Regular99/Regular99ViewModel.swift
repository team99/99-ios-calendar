//
//  Regular99ViewModel.swift
//  calendar99-presetLogic
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic

/// View model for Regular99 preset. Note that this view model only extends
/// from factory protocols - this is because each component view model could
/// have its own state, so it's unwise to let this view model implement all
/// their features. This is different from the preset model (which implements
/// all component features) because the model itself does not carry any state
/// operations, and thus is just a collection of dependencies and pure functions.
public protocol NNRegular99CalendarViewModelType:
  NNMonthHeaderViewModelFactory,
  NNMonthSectionViewModelFactory,
  NNSelectWeekdayViewModelFactory {}

// MARK: - ViewModel
public extension NNCalendarPreset.Regular99 {

  /// View model implementation for Regular99 preset.
  public final class ViewModel {
    fileprivate let model: NNRegular99CalendarModelType

    required public init(_ model: NNRegular99CalendarModelType) {
      self.model = model
    }
  }
}

// MARK: - NNMonthHeaderViewModelFactory
extension NNCalendarPreset.Regular99.ViewModel: NNMonthHeaderViewModelFactory {
  public func monthHeaderViewModel() -> NNMonthHeaderViewModelType {
    return NNCalendarLogic.MonthHeader.ViewModel(model)
  }
}

// MARK: - NNMonthSectionViewModelFactory
extension NNCalendarPreset.Regular99.ViewModel: NNMonthSectionViewModelFactory {
  public func monthSectionViewModel() -> NNMonthSectionViewModelType {
    return NNCalendarLogic.MonthSection.ViewModel(model)
  }
}

// MARK: - NNSelectWeekdayViewModelFactory
extension NNCalendarPreset.Regular99.ViewModel: NNSelectWeekdayViewModelFactory {
  public func selectableWeekdayViewModel() -> NNSelectWeekdayViewModelType {
    return NNCalendarLogic.SelectWeekday.ViewModel(model)
  }
}

// MARK: - NNRegular99CalendarViewModelType
extension NNCalendarPreset.Regular99.ViewModel: NNRegular99CalendarViewModelType {}
