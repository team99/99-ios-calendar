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
  NNSelectHighlightFunction,
  NNSingleDaySelectionViewModelType
{
  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream month components to display on the month section view.
  var monthCompStream: Observable<[NNCalendarLogic.MonthComp]> { get }

  /// Stream the current month selection index. This will change, for e.g. when
  /// the user swipes the calendar view to reveal a new month.
  var currentMonthSelectionIndexStream: Observable<Int> { get }

  /// Stream grid selections changes based on selected dates. We need to
  /// calculate the grid selections in a way that memory usage is minimized.
  ///
  /// Beware that this stream only emits changes in grid selections by comparing
  /// the previous and current selections.
  var gridSelectionChangesStream: Observable<Set<NNCalendarLogic.GridPosition>> { get }

  /// Calculate the day for a month and a first date offset.
  ///
  /// - Parameters:
  ///   - month: A Month instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                        _ firstDateOffset: Int) -> NNCalendarLogic.Day?

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

public extension NNCalendarLogic.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let monthGridVM: NNMonthGridViewModelType
    fileprivate let daySelectionVM: NNSingleDaySelectionViewModelType
    fileprivate let model: NNMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthCompSbj: BehaviorSubject<[NNCalendarLogic.MonthComp]?>

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
      let monthControlVM = NNCalendarLogic.MonthControl.ViewModel(model)
      let monthGridVM = NNCalendarLogic.MonthGrid.ViewModel(model)
      let daySelectionVM = NNCalendarLogic.DaySelect.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, model)
    }
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarLogic.MonthSection.ViewModel: NNGridDisplayFunction {
  public var weekdayStacks: Int { return monthGridVM.weekdayStacks }
}

// MARK: - NNMonthGridViewModelType
extension NNCalendarLogic.MonthSection.ViewModel: NNMonthGridViewModelType {
  public var gridSelectionReceiver: AnyObserver<NNCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionReceiver
  }

  public var gridSelectionStream: Observable<NNCalendarLogic.GridPosition> {
    return monthGridVM.gridSelectionStream
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLogic.MonthSection.ViewModel: NNMonthControlFunction {
  public var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return monthControlVM.currentMonthReceiver
  }
}

// MARK: - NNMonthControlViewModelType
extension NNCalendarLogic.MonthSection.ViewModel: NNMonthControlViewModelType {
  public var currentMonthForwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthForwardReceiver
  }

  public var currentMonthBackwardReceiver: AnyObserver<Void> {
    return monthControlVM.currentMonthBackwardReceiver
  }

  public func setupMonthControlBindings() {
    monthControlVM.setupMonthControlBindings()
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLogic.MonthSection.ViewModel: NNSingleDaySelectionFunction {
  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendarLogic.MonthSection.ViewModel: NNSingleDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }

  public func setupDaySelectionBindings() {
    daySelectionVM.setupDaySelectionBindings()
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendarLogic.MonthSection.ViewModel: NNSelectHighlightFunction {
  public func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return model.highlightPart(date)
  }
}

// MARK: - NNMonthSectionViewModelType
extension NNCalendarLogic.MonthSection.ViewModel: NNMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return NNCalendarLogic.Util.monthCount(model.minimumMonth, model.maximumMonth)
  }

  public var monthCompStream: Observable<[NNCalendarLogic.MonthComp]> {
    return monthCompSbj.filter({$0.isSome}).map({$0!})
  }

  public var currentMonthSelectionIndexStream: Observable<Int> {
    return model.currentMonthStream
      .withLatestFrom(monthCompStream) {($0, $1)}
      .map({$1.map({$0.month}).index(of: $0)})
      .filter({$0.isSome}).map({$0!})
  }

  /// Keep track of the previous selections to know what have been deselected.
  public var gridSelectionChangesStream: Observable<Set<NNCalendarLogic.GridPosition>> {
    return model.allSelectionStream.map({$0.getOrElse([])})
      .scan((p: Set<NNCalendarLogic.Selection>(), c: Set<NNCalendarLogic.Selection>()),
            accumulator: {(p: $0.c, c: $1)})
      .withLatestFrom(model.currentMonthStream) {($1, p: $0.p, c: $0.c)}
      .withLatestFrom(monthCompStream) {($1, $0.0, p: $0.p, c: $0.c)}
      .map({[weak self] in self?.model.gridSelectionChanges($0.0, $0.1, $0.p, $0.c)})
      .filter({$0.isSome}).map({$0!})
  }

  public func dayFromFirstDate(_ month: NNCalendarLogic.Month,
                               _ firstDateOffset: Int) -> NNCalendarLogic.Day? {
    return model.dayFromFirstDate(month, firstDateOffset)
  }

  public func setupMonthSectionBindings() {
    let disposable = self.disposable
    let minMonth = model.minimumMonth
    let maxMonth = model.maximumMonth
    let dayCount = monthGridVM.weekdayStacks * NNCalendarLogic.Util.weekdayCount
    let firstWeekday = model.firstWeekday

    /// Must call onNext manually to avoid completed event, since this is a
    /// cold stream.
    Observable.just(NNCalendarLogic.Util.monthRange(minMonth, maxMonth))
      .map({$0.map({NNCalendarLogic.MonthComp($0, dayCount, firstWeekday)})})
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
