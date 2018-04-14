//
//  SelectableWeekdayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 13/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency.
public protocol NNSelectableWeekdayViewModelFunction:
  NNWeekdayDisplayViewModelFunction {}

/// Dependency for selectable weekday display view model.
public protocol NNSelectableWeekdayViewModelDependency:
  NNWeekdayDisplayViewModelDependency {}

/// View model for selectable weekday display view. This is a decorator over the
/// week display view model.
public protocol NNSelectableWeekdayViewModelType:
  NNSelectableWeekdayViewModelFunction,
  NNWeekdayDisplayViewModelType {}

// MARK: - View model.
public extension NNCalendar.SelectWeekday {

  /// View model implementation.
  public final class ViewModel {
    fileprivate let weekdayVM: NNWeekdayDisplayViewModelType
    fileprivate let dependency: NNSelectableWeekdayViewModelDependency
    fileprivate let model: NNSelectableWeekdayModelType
    fileprivate let disposable: DisposeBag

    required public init(_ weekdayVM: NNWeekdayDisplayViewModelType,
                         _ dependency: NNSelectableWeekdayViewModelDependency,
                         _ model: NNSelectableWeekdayModelType) {
      self.weekdayVM = weekdayVM
      self.dependency = dependency
      self.model = model
      disposable = DisposeBag()
    }

    convenience public init(_ dependency: NNSelectableWeekdayViewModelDependency,
                            _ model: NNSelectableWeekdayModelType) {
      let weekdayVM = NNCalendar.WeekdayDisplay.ViewModel(dependency, model)
      self.init(weekdayVM, dependency, model)
    }

    convenience public init(_ model: NNSelectableWeekdayModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNWeekdayDisplayViewModelType
extension NNCalendar.SelectWeekday.ViewModel: NNWeekdayDisplayViewModelType {
  public var weekdayCount: Int {
    return weekdayVM.weekdayCount
  }

  public var weekdayStream: Observable<[NNCalendar.Weekday]> {
    return weekdayVM.weekdayStream
  }

  public var weekdaySelectionIndexReceiver: AnyObserver<Int> {
    return weekdayVM.weekdaySelectionIndexReceiver
  }

  public var weekdaySelectionStream: Observable<Int> {
    return weekdayVM.weekdaySelectionStream
  }

  public func setupWeekDisplayBindings() {
    weekdayVM.setupWeekDisplayBindings()
    let disposable = self.disposable

    // In case:
    // - The user selects a weekday range (e.g. all Mondays).
    // - The user then deselects a Monday within said weekday range.
    // - The next time they selects the same range, some cells will be selected
    // (i.e. the previously deselected date) while the rest becomes deselected.
    weekdaySelectionStream
      .withLatestFrom(model.currentMonthCompStream) {($1, $0)}
      .map({$0.datesWithWeekday($1)})
      .withLatestFrom(model.allDateSelectionStream) {$0.symmetricDifference($1)}
      .subscribe(model.allDateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - NNSelectableWeekdayViewModelType
extension NNCalendar.SelectWeekday.ViewModel: NNSelectableWeekdayViewModelType {}

// MARK: - Default dependency.
public extension NNCalendar.SelectWeekday.ViewModel {
  internal final class DefaultDependency: NNSelectableWeekdayViewModelDependency {
    internal var weekdayCount: Int {
      return weekdayDp.weekdayCount
    }

    internal var firstDayOfWeek: Int {
      return weekdayDp.firstDayOfWeek
    }

    private let weekdayDp: NNWeekdayDisplayViewModelDependency

    internal init() {
      weekdayDp = NNCalendar.WeekdayDisplay.ViewModel.DefaultDependency()
    }
  }
}
