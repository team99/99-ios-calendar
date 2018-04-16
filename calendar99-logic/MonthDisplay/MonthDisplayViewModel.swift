//
//  MonthDisplayViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month display view model.
public protocol NNMonthDisplayViewModelDependency: NNMonthGridViewModelDependency {}

/// View model for month display view.
public protocol NNMonthDisplayViewModelType:
  NNMonthControlViewModelType,
  NNMonthGridViewModelType,
  NNSingleDaySelectionViewModelType
{
  /// Stream days to display on the month view.
  var dayStream: Observable<[NNCalendar.Day]> { get }

  /// Stream day index selections changed based on the selected dates. These
  /// indexes can be used to reload the cells with said selected dates. Beware
  /// that this stream only emits changes between the previous and current
  /// selections.
  ///
  /// For e.g., the previous selections were [1, 2, 3] and the new selections
  /// are [1, 2, 3, 4], only 4 is emitted.
  ///
  /// We only return the day indexes because for this view since there is only
  /// one month active at any time.
  var gridDayIndexSelectionChangesStream: Observable<Set<Int>> { get }

  /// Set up month display bindings.
  func setupMonthDisplayBindings()
}

// MARK: - All bindings.
public extension NNMonthDisplayViewModelType {
  public func setupAllBindingsAndSubBindings() {
    setupMonthControlBindings()
    setupDaySelectionBindings()
    setupMonthDisplayBindings()
  }
}

public extension NNCalendar.MonthDisplay {

  /// Month display view model implementation.
  public final class ViewModel {
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let monthGridVM: NNMonthGridViewModelType
    fileprivate let daySelectionVM: NNSingleDaySelectionViewModelType
    fileprivate let dependency: NNMonthDisplayViewModelDependency
    fileprivate let model: NNMonthDisplayModelType
    fileprivate let daySbj: BehaviorSubject<[NNCalendar.Day]?>
    fileprivate let disposable: DisposeBag

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ monthGridVM: NNMonthGridViewModelType,
                         _ daySelectionVM: NNSingleDaySelectionViewModelType,
                         _ dependency: NNMonthDisplayViewModelDependency,
                         _ model: NNMonthDisplayModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.dependency = dependency
      self.model = model
      disposable = DisposeBag()
      daySbj = BehaviorSubject(value: nil)
    }

    convenience public init(_ dependency: NNMonthDisplayViewModelDependency,
                            _ model: NNMonthDisplayModelType) {
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      let monthGridVM = NNCalendar.MonthGrid.ViewModel(dependency, model)
      let daySelectionVM = NNCalendar.DaySelection.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, dependency, model)
    }

    convenience public init(_ model: NNMonthDisplayModelType) {
      let defaultDp = DefaultDependency()
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendar.MonthDisplay.ViewModel: NNMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<UInt> {
    return monthControlVM.currentMonthForwardReceiver
  }

  public var currentMonthBackwardReceiver: AnyObserver<UInt> {
    return monthControlVM.currentMonthBackwardReceiver
  }

  public func setupMonthControlBindings() {
    monthControlVM.setupMonthControlBindings()
  }
}

// MARK: - NNMonthGridViewModelFunction
extension NNCalendar.MonthDisplay.ViewModel: NNMonthGridViewModelFunction {
  public var rowCount: Int {
    return dependency.rowCount
  }

  public var columnCount: Int {
    return dependency.columnCount
  }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendar.MonthDisplay.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<NNCalendar.GridSelection> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<NNCalendar.GridSelection> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - NNMonthDisplayViewModelType
extension NNCalendar.MonthDisplay.ViewModel: NNMonthDisplayViewModelType {
  public var dayStream: Observable<[NNCalendar.Day]> {
    return daySbj.filter({$0.isSome}).map({$0!})
  }

  /// Convenient stream that emits month components.
  private var monthCompStream: Observable<NNCalendar.MonthComp> {
    let dayCount = rowCount * columnCount
    return model.currentMonthStream.map({NNCalendar.MonthComp($0, dayCount)})
  }

  public var gridDayIndexSelectionChangesStream: Observable<Set<Int>> {
    let firstWeekday = dependency.firstWeekday

    return model.allDateSelectionStream
      .scan((prev: Set<Date>(), current: Set<Date>()),
            accumulator: {(prev: $0.current, current: $1)})
      .withLatestFrom(monthCompStream) {($1, $0)}
      .map({[weak self] in self?.model
        .calculateGridSelectionChanges($0, firstWeekday, $1.prev, $1.current)})
      .filter({$0.isSome}).map({$0!})
      .map({Set($0.map({$0.dayIndex}))})
  }

  public func setupMonthDisplayBindings() {
    let firstWeekday = dependency.firstWeekday
    let rowCount = dependency.rowCount
    let columnCount = dependency.columnCount

    // Every time the user switches month, we need to update the day stream.
    model.currentMonthStream
      .map({[weak self] month in self?.model
        .calculateDayRange(month, firstWeekday, rowCount, columnCount)})
      .filter({$0.isSome}).map({$0!})
      .distinctUntilChanged({$0 == $1})
      .map(Optional.some)
      .subscribe(daySbj)
      .disposed(by: disposable)

    // We only take the dayIndex because this view has no sections.
    gridSelectionStream
      .withLatestFrom(dayStream) {($1, $0)}
      .filter({$1.dayIndex >= 0 && $1.dayIndex < $0.count})
      .map({(days, index) in days[index.dayIndex].date})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - NNDaySelectionFunction
extension NNCalendar.MonthDisplay.ViewModel: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendar.MonthDisplay.ViewModel: NNSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }

  public func setupDaySelectionBindings() {
    daySelectionVM.setupDaySelectionBindings()
  }
}

// MARK: - Default dependency.
public extension NNCalendar.MonthDisplay.ViewModel {

  /// Default dependency for month display model. The defaults here represent
  /// most commonly used set-up, for e.g. horizontal calendar with 42 date cells
  /// in total.
  internal final class DefaultDependency: NNMonthDisplayViewModelDependency {
    public var firstWeekday: Int {
      return monthGridDp.firstWeekday
    }

    public var columnCount: Int {
      return monthGridDp.columnCount
    }

    public var rowCount: Int {
      return monthGridDp.rowCount
    }

    private let monthGridDp: NNMonthGridViewModelDependency

    internal init() {
      monthGridDp = NNCalendar.MonthGrid.ViewModel.DefaultDependency()
    }
  }
}
