//
//  MonthSectionViewModel.swift
//  calendar99-logic
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Shared functionalities between the view model and its dependency, so that
/// the former can expose the same properties.
public protocol NNMonthSectionViewModelFunctionality:
  NNMonthDisplayViewModelFunctionality {}

/// Dependency for month section view model with components that cannot have
/// defaults.
public protocol NNMonthSectionNonDefaultableViewModelDependency:
  NNDaySelectionViewModelDependency
{
  /// Get the number of past months to include in the month data stream.
  var pastMonthCountFromCurrent: Int { get }

  /// Get the number of future months to include in the month data stream.
  var futureMonthCountFromCurrent: Int { get }
}

/// Dependency for month section view model.
public protocol NNMonthSectionViewModelDependency:
  NNMonthSectionNonDefaultableViewModelDependency,
  NNMonthDisplayViewModelDependency {}

/// View model for month section view.
public protocol NNMonthSectionViewModelType:
  NNMonthSectionViewModelFunctionality,
  NNMonthControlViewModelType,
  NNDaySelectionViewModelType
{
  /// Get the total month count.
  var totalMonthCount: Int { get }
  
  /// Stream months to display on the month section view.
  var monthStream: Observable<[NNCalendar.Month]> { get }

  /// Stream the current month selection index.
  var currentMonthSelectionIndex: Observable<Int> { get }

  /// Calculate the day for a month components and a first date offset.
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
    fileprivate let daySelectionVM: NNDaySelectionViewModelType
    fileprivate let dependency: NNMonthSectionViewModelDependency
    fileprivate let model: NNMonthSectionModelType
    fileprivate let disposable: DisposeBag

    /// Cache here to improve performance.
    fileprivate let monthSbj: BehaviorSubject<[NNCalendar.Month]?>

    required public init(_ monthControlVM: NNMonthControlViewModelType,
                         _ daySelectionVM: NNDaySelectionViewModelType,
                         _ dependency: NNMonthSectionViewModelDependency,
                         _ model: NNMonthSectionModelType) {
      self.monthControlVM = monthControlVM
      self.daySelectionVM = daySelectionVM
      self.dependency = dependency
      self.model = model
      monthSbj = BehaviorSubject(value: nil)
      disposable = DisposeBag()
    }

    convenience public init(_ dependency: NNMonthSectionViewModelDependency,
                            _ model: NNMonthSectionModelType) {
      let monthControlVM = NNCalendar.MonthControl.ViewModel(model)
      let daySelectionVM = NNCalendar.DaySelection.ViewModel(dependency, model)
      self.init(monthControlVM, daySelectionVM, dependency, model)
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

// MARK: - NNMonthSectionViewModelFunctionality
extension NNCalendar.MonthSection.ViewModel: NNMonthSectionViewModelFunctionality {
  public var columnCount: Int {
    return dependency.columnCount
  }

  public var rowCount: Int {
    return dependency.rowCount
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

    /// Must call onNext manually to avoid completed event, since this is
    /// most likely a cold stream.
    model.initialComponentStream
      .map({[weak self] in self?.model.componentRange($0, pCount, fCount)})
      .filter({$0.isSome}).map({$0!})
      .map({$0.map({NNCalendar.Month($0, dayCount)})})
      .asObservable()
      .subscribe(onNext: {[weak self] in self?.monthSbj.onNext($0)})
      .disposed(by: disposable)
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
    return model.currentComponentStream
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
