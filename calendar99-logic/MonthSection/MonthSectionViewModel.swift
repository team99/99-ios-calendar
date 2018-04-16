//
//  MonthSectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Dependency for month section view model with components that cannot have
/// defaults.
public protocol NNMonthSectionNoDefaultViewModelDependency {

  /// Get the number of past months to include in the month data stream.
  var pastMonthsFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthsFromCurrent: Int { get }
}

/// Dependency for month section view model.
public protocol NNMonthSectionViewModelDependency:
  NNMonthSectionNoDefaultViewModelDependency,
  NNMonthGridViewModelDependency {}

/// View model for month section view.
public protocol NNMonthSectionViewModelType:
  NNMonthGridViewModelType,
  NNMonthControlViewModelType,
  NNSingleDaySelectionViewModelType,
  NNSelectHighlightFunction
{
  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream month components to display on the month section view.
  var monthCompStream: Observable<[NNCalendar.MonthComp]> { get }

  /// Stream the current month selection index. This will change, for e.g. when
  /// the user swipes the calendar view to reveal a new month.
  var currentMonthSelectionIndexStream: Observable<Int> { get }

  /// Stream grid selections changes based on selected dates. We need to
  /// calculate the grid selections in a way that memory usage is minimized.
  ///
  /// Beware that this stream only emits changes in grid selections by comparing
  /// the previous and current selections.
  var gridSelectionChangesStream: Observable<Set<NNCalendar.GridSelection>> { get }

  /// Calculate the day for a month and a first date offset.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                 _ firstDateOffset: Int) -> NNCalendar.Day?

  /// Set up month section bindings.
  func setupMonthSectionBindings()
}

// MARK: - All bindings.
public extension NNMonthSectionViewModelType {

  /// Set up all bindings and sub-bindings.
  public func setupAllBindingsAndSubBindings() {
    setupDaySelectionBindings()
    setupMonthControlBindings()
    setupMonthSectionBindings()
  }
}

public extension NNCalendar.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let monthGridVM: NNMonthGridViewModelType
    fileprivate let daySelectionVM: NNSingleDaySelectionViewModelType
    fileprivate let dependency: NNMonthSectionViewModelDependency
    fileprivate let model: NNMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthCompSbj: BehaviorSubject<[NNCalendar.MonthComp]?>

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ monthGridVM: NNMonthGridViewModelType,
                         _ daySelectionVM: NNSingleDaySelectionViewModelType,
                         _ dependency: NNMonthSectionViewModelDependency,
                         _ model: NNMonthSectionModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.dependency = dependency
      self.model = model
      monthCompSbj = BehaviorSubject(value: nil)
      disposable = DisposeBag()
    }

    convenience public init(_ dependency: NNMonthSectionViewModelDependency,
                            _ model: NNMonthSectionModelType) {
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      let monthGridVM = NNCalendar.MonthGrid.ViewModel(dependency, model)
      let daySelectionVM = NNCalendar.DaySelection.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, dependency, model)
    }

    convenience public init(_ dependency: NNMonthSectionNoDefaultViewModelDependency,
                            _ model: NNMonthSectionModelType) {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNMonthGridViewModelFunction
extension NNCalendar.MonthSection.ViewModel: NNMonthGridViewModelFunction {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
  }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<NNCalendar.GridSelection> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<NNCalendar.GridSelection> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthControlViewModelType {
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

// MARK: - NNDaySelectionFunction
extension NNCalendar.MonthSection.ViewModel: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }

  public func setupDaySelectionBindings() {
    daySelectionVM.setupDaySelectionBindings()
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendar.MonthSection.ViewModel: NNSelectHighlightFunction {
  public func calculateHighlightPos(_ date: Date) -> NNCalendar.HighlightPosition {
    return model.calculateHighlightPos(date)
  }
}

// MARK: - NNMonthSectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return 1
      + dependency.pastMonthsFromCurrent
      + dependency.futureMonthsFromCurrent
  }

  public var monthCompStream: Observable<[NNCalendar.MonthComp]> {
    return monthCompSbj.filter({$0.isSome}).map({$0!})
  }

  public var currentMonthSelectionIndexStream: Observable<Int> {
    return model.currentMonthStream
      .withLatestFrom(monthCompStream) {($0, $1)}
      .map({$1.map({$0.month}).index(of: $0)})
      .filter({$0.isSome}).map({$0!})
  }

  /// Keep track of the previous selections to know what have been deselected.
  public var gridSelectionChangesStream: Observable<Set<NNCalendar.GridSelection>> {
    let firstWeekday = dependency.firstWeekday

    return model.allDateSelectionStream
      .scan((prev: Set<Date>(), current: Set<Date>()),
            accumulator: {(prev: $0.current, current: $1)})
      .withLatestFrom(monthCompStream) {($1, prev: $0.prev, current: $0.current)}
      .map({[weak self] in self?.model
        .calculateGridSelectionChanges($0.0, firstWeekday, $0.prev, $0.current)})
      .filter({$0.isSome}).map({$0!})
  }

  public func calculateDayFromFirstDate(_ month: NNCalendar.Month,
                                        _ firstDateOffset: Int) -> NNCalendar.Day? {
    let firstWeekday = dependency.firstWeekday
    return model.calculateDayFromFirstDate(month, firstWeekday, firstDateOffset)
  }

  public func setupMonthSectionBindings() {
    let disposable = self.disposable
    let pCount = dependency.pastMonthsFromCurrent
    let fCount = dependency.futureMonthsFromCurrent
    let dayCount = dependency.rowCount * dependency.columnCount

    /// Must call onNext manually to avoid completed event, since this is a
    /// cold stream.
    model.initialMonthStream
      .map({[weak self] in self?.model.getAvailableMonths($0, pCount, fCount)})
      .filter({$0.isSome}).map({$0!})
      .map({$0.map({NNCalendar.MonthComp($0, dayCount)})})
      .asObservable()
      .subscribe(onNext: {[weak self] in self?.monthCompSbj.onNext($0)})
      .disposed(by: disposable)

    gridSelectionStream
      .withLatestFrom(monthCompStream) {($1, $0)}
      .filter({$1.monthIndex >= 0 && $1.monthIndex < $0.count})
      .map({[weak self] (months, index) -> Date? in
        let month = months[index.monthIndex].month
        return self?.calculateDayFromFirstDate(month, index.dayIndex)?.date
      })
      .filter({$0.isSome}).map({$0!})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - Default dependency.
extension NNCalendar.MonthSection.ViewModel {

  /// Default dependency for month section view model. We reuse the default
  /// dependency for the month view because they have many similarities.
  internal final class DefaultDependency: NNMonthSectionViewModelDependency {
    internal var firstWeekday: Int {
      return defaulted.firstWeekday
    }

    internal var columnCount: Int {
      return defaulted.columnCount
    }

    internal var rowCount: Int {
      return defaulted.rowCount
    }

    internal var pastMonthsFromCurrent: Int {
      return noDefault.pastMonthsFromCurrent
    }

    internal var futureMonthsFromCurrent: Int {
      return noDefault.futureMonthsFromCurrent
    }

    private let noDefault: NNMonthSectionNoDefaultViewModelDependency
    private let defaulted: NNMonthDisplayViewModelDependency

    internal init(_ dependency: NNMonthSectionNoDefaultViewModelDependency) {
      noDefault = dependency
      defaulted = NNCalendar.MonthDisplay.ViewModel.DefaultDependency()
    }
  }
}
