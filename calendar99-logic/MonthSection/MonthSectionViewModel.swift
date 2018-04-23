//
//  MonthSectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// View model for month section view.
public protocol NNMonthSectionViewModelType:
  NNMonthControlViewModelType,
  NNMonthGridViewModelType,
  NNSelectHighlightDefaultFunction,
  NNSelectHighlightNoDefaultFunction,
  NNSingleDaySelectionViewModelType
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
  var gridSelectionChangesStream: Observable<Set<NNCalendar.GridPosition>> { get }

  /// Calculate the day for a month and a first date offset.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func dayFromFirstDate(_ month: NNCalendar.Month,
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

/// Factory for month section view model.
public protocol NNMonthSectionViewModelFactory {

  /// Get a month section view model.
  ///
  /// - Returns: A NNMonthSectionViewModelType instance.
  func monthSectionViewModel() -> NNMonthSectionViewModelType
}

public extension NNCalendar.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let monthGridVM: NNMonthGridViewModelType
    fileprivate let daySelectionVM: NNSingleDaySelectionViewModelType
    fileprivate let model: NNMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthCompSbj: BehaviorSubject<[NNCalendar.MonthComp]?>

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ monthGridVM: NNMonthGridViewModelType,
                         _ daySelectionVM: NNSingleDaySelectionViewModelType,
                         _ model: NNMonthSectionModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.model = model
      monthCompSbj = BehaviorSubject(value: nil)
      disposable = DisposeBag()
    }

    convenience public init(_ model: NNMonthSectionModelType) {
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      let monthGridVM = NNCalendar.MonthGrid.ViewModel(model)
      let daySelectionVM = NNCalendar.DaySelection.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, model)
    }
  }
}

// MARK: - NNGridDisplayDefaultFunction
extension NNCalendar.MonthSection.ViewModel: NNGridDisplayDefaultFunction {
  public var weekdayStacks: Int { return monthGridVM.weekdayStacks }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<NNCalendar.GridPosition> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<NNCalendar.GridPosition> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - NNMonthControlNoDefaultFunction
extension NNCalendar.MonthSection.ViewModel: NNMonthControlNoDefaultFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendar.Month> {
    return monthControlVM.currentMonthReceiver
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

// MARK: - NNSingleDaySelectionNoDefaultFunction
extension NNCalendar.MonthSection.ViewModel: NNSingleDaySelectionNoDefaultFunction {
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

// MARK: - NNSelectHighlightNoDefaultFunction
extension NNCalendar.MonthSection.ViewModel: NNSelectHighlightNoDefaultFunction {
  public func highlightPart(_ date: Date) -> NNCalendar.HighlightPart {
    return model.highlightPart(date)
  }
}

// MARK: - NNMonthSectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return 1 + model.pastMonthsFromCurrent + model.futureMonthsFromCurrent
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
  public var gridSelectionChangesStream: Observable<Set<NNCalendar.GridPosition>> {
    return model.allSelectionStream.map({$0.getOrElse([])})
      .scan((p: Set<NNCalendar.Selection>(), c: Set<NNCalendar.Selection>()),
            accumulator: {(p: $0.c, c: $1)})
      .withLatestFrom(model.currentMonthStream) {($1, p: $0.p, c: $0.c)}
      .withLatestFrom(monthCompStream) {($1, $0.0, p: $0.p, c: $0.c)}
      .map({[weak self] in self?.model.gridSelectionChanges($0.0, $0.1, $0.p, $0.c)})
      .filter({$0.isSome}).map({$0!})
  }

  public func dayFromFirstDate(_ month: NNCalendar.Month,
                               _ firstDateOffset: Int) -> NNCalendar.Day? {
    return model.dayFromFirstDate(month, firstDateOffset)
  }

  public func setupMonthSectionBindings() {
    let disposable = self.disposable
    let pCount = model.pastMonthsFromCurrent
    let fCount = model.futureMonthsFromCurrent
    let dayCount = monthGridVM.weekdayStacks * NNCalendar.Util.weekdayCount
    let firstWeekday = model.firstWeekday

    /// Must call onNext manually to avoid completed event, since this is a
    /// cold stream.
    model.initialMonthStream
      .map({NNCalendar.Util.getAvailableMonths($0, pCount, fCount)})
      .map({$0.map({NNCalendar.MonthComp($0, dayCount, firstWeekday)})})
      .asObservable()
      .subscribe(onNext: {[weak self] in self?.monthCompSbj.onNext($0)})
      .disposed(by: disposable)

    gridSelectionStream
      .withLatestFrom(monthCompStream) {($1, $0)}
      .filter({$1.monthIndex >= 0 && $1.monthIndex < $0.count})
      .map({[weak self] (months, index) -> Date? in
        let month = months[index.monthIndex].month
        return self?.dayFromFirstDate(month, index.dayIndex)?.date
      })
      .filter({$0.isSome}).map({$0!})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}
