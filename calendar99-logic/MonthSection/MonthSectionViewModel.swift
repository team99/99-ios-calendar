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
public protocol NNMonthSectionNonDefaultableViewModelDependency {

  /// Get the number of past months to include in the month data stream.
  var pastMonthCountFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthCountFromCurrent: Int { get }
}

/// Dependency for month section view model.
public protocol NNMonthSectionViewModelDependency:
  NNMonthSectionNonDefaultableViewModelDependency,
  NNMonthGridViewModelDependency {}

/// View model for month section view.
public protocol NNMonthSectionViewModelType:
  NNMonthGridViewModelType,
  NNMonthControlViewModelType,
  NNDaySelectionViewModelType
{
  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream months to display on the month section view.
  var monthStream: Observable<[NNCalendar.Month]> { get }

  /// Stream the current month selection index.
  var currentMonthSelectionIndex: Observable<Int> { get }

  /// Calculate the day for a month component and a first date offset.
  ///
  /// - Parameters:
  ///   - comps: A MonthComp instance.
  ///   - firstDateOffset: Offset from the initial date in the grid.
  /// - Returns: A Day instance.
  func calculateDay(_ comps: NNCalendar.MonthComp,
                    _ firstDateOffset: Int) -> NNCalendar.Day?
}

public extension NNCalendar.MonthSection {

  /// View model implementation for the month section view.
  public final class ViewModel {
    fileprivate let monthControlVM: NNMonthControlViewModelType
    fileprivate let monthGridVM: NNMonthGridViewModelType
    fileprivate let daySelectionVM: NNDaySelectionViewModelType
    fileprivate let dependency: NNMonthSectionViewModelDependency
    fileprivate let model: NNMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthSbj: BehaviorSubject<[NNCalendar.Month]?>

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ monthGridVM: NNMonthGridViewModelType,
                         _ daySelectionVM: NNDaySelectionViewModelType,
                         _ dependency: NNMonthSectionViewModelDependency,
                         _ model: NNMonthSectionModelType) {
      self.monthControlVM = monthControlVM
      self.monthGridVM = monthGridVM
      self.daySelectionVM = daySelectionVM
      self.dependency = dependency
      self.model = model
      monthSbj = BehaviorSubject(value: nil)
      disposable = DisposeBag()
    }

    convenience public init(_ dependency: NNMonthSectionViewModelDependency,
                            _ model: NNMonthSectionModelType) {
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      let monthGridVM = NNCalendar.MonthGrid.ViewModel(dependency, model)
      let daySelectionVM = NNCalendar.DaySelection.ViewModel(model)
      self.init(monthControlVM, monthGridVM, daySelectionVM, dependency, model)
    }

    convenience public init(
      _ dependency: NNMonthSectionNonDefaultableViewModelDependency,
      _ model: NNMonthSectionModelType)
    {
      let defaultDp = DefaultDependency(dependency)
      self.init(defaultDp, model)
    }
  }
}

// MARK: - NNMonthGridViewModelFunctionality
extension NNCalendar.MonthSection.ViewModel: NNMonthGridViewModelFunctionality {
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

  public func setupBindings() {
    monthControlVM.setupBindings()
    daySelectionVM.setupBindings()
    let disposable = self.disposable
    let pCount = dependency.pastMonthCountFromCurrent
    let fCount = dependency.futureMonthCountFromCurrent
    let dayCount = dependency.rowCount * dependency.columnCount

    /// Must call onNext manually to avoid completed event, since this is a
    /// cold stream.
    model.initialMonthCompStream
      .map({[weak self] in self?.model.componentRange($0, pCount, fCount)})
      .filter({$0.isSome}).map({$0!})
      .map({$0.map({NNCalendar.Month($0, dayCount)})})
      .asObservable()
      .subscribe(onNext: {[weak self] in self?.monthSbj.onNext($0)})
      .disposed(by: disposable)

    gridSelectionStream
      .withLatestFrom(monthStream) {($1, $0)}
      .filter({$1.monthIndex >= 0 && $1.monthIndex < $0.count})
      .map({[weak self] (months, index) -> Date? in
        let monthComp = months[index.monthIndex].monthComp
        return self?.calculateDay(monthComp, index.dayIndex)?.date
      })
      .filter({$0.isSome}).map({$0!})
      .subscribe(dateSelectionReceiver)
      .disposed(by: disposable)
  }
}

// MARK: - NNDaySelectionFunctionality
extension NNCalendar.MonthSection.ViewModel: NNDaySelectionFunctionality {
  public var allDateSelectionStream: Observable<Set<Date>> {
    return daySelectionVM.allDateSelectionStream
  }

  public func isDateSelected(_ date: Date) -> Bool {
    return daySelectionVM.isDateSelected(date)
  }
}

// MARK: - NNDaySelectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNDaySelectionViewModelType {
  public var dateSelectionReceiver: AnyObserver<Date> {
    return daySelectionVM.dateSelectionReceiver
  }
}

// MARK: - NNMonthSectionViewModelType
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelType {
  public var totalMonthCount: Int {
    return 1
      + dependency.pastMonthCountFromCurrent
      + dependency.futureMonthCountFromCurrent
  }

  public var monthStream: Observable<[NNCalendar.Month]> {
    return monthSbj.filter({$0.isSome}).map({$0!})
  }

  public var currentMonthSelectionIndex: Observable<Int> {
    return model.currentMonthCompStream
      .withLatestFrom(monthStream) {($0, $1)}
      .map({$1.map({$0.monthComp}).index(of: $0)})
      .filter({$0.isSome}).map({$0!})
      .distinctUntilChanged()
  }

  public func calculateDay(_ comps: NNCalendar.MonthComp,
                           _ firstDateOffset: Int) -> NNCalendar.Day? {
    return model.calculateDay(comps, dependency.firstDayOfWeek, firstDateOffset)
  }
}

// MARK: - Default dependency.
extension NNCalendar.MonthSection.ViewModel {

  /// Default dependency for month section view model. We reuse the default
  /// dependency for the month view because they have many similarities.
  internal final class DefaultDependency: NNMonthSectionViewModelDependency {
    public var pastMonthCountFromCurrent: Int {
      return nonDefaultable.pastMonthCountFromCurrent
    }

    public var futureMonthCountFromCurrent: Int {
      return nonDefaultable.futureMonthCountFromCurrent
    }

    public var firstDayOfWeek: Int {
      return defaultable.firstDayOfWeek
    }

    public var columnCount: Int {
      return defaultable.columnCount
    }

    public var rowCount: Int {
      return defaultable.rowCount
    }

    private let nonDefaultable: NNMonthSectionNonDefaultableViewModelDependency
    private let defaultable: NNMonthDisplayViewModelDependency

    internal init(_ dependency: NNMonthSectionNonDefaultableViewModelDependency) {
      self.nonDefaultable = dependency
      self.defaultable = NNCalendar.MonthDisplay.ViewModel.DefaultDependency()
    }
  }
}