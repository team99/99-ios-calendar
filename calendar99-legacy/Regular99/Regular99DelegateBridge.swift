//
//  Regular99DelegateBridge.swift
//  calendar99-legacy
//
//  Created by Hai Pham on 24/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP
import calendar99_logic
import calendar99_presetLogic
import calendar99_preset

// MARK: - Delegate bridge.
extension NNCalendarLegacy.Regular99 {

  /// Delegate bridge for Regular99 calendar preset.
  final class Bridge {
    fileprivate weak var calendar: NNRegular99Calendar?
    fileprivate let delegate: NNRegular99CalendarDelegate?
    fileprivate let currentMonthSb: BehaviorSubject<Void>
    fileprivate let selectionSb: BehaviorSubject<Void>

    private init(_ delegate: NNRegular99CalendarDelegate) {
      self.delegate = delegate
      currentMonthSb = BehaviorSubject(value: ())
      selectionSb = BehaviorSubject(value: ())
    }

    convenience init(_ calendar: NNRegular99Calendar,
                     _ delegate: NNRegular99CalendarDelegate) {
      self.init(Wrapper(delegate))
      self.calendar = calendar
    }

    convenience init(_ calendar: NNRegular99Calendar,
                     _ delegate: NNRegular99CalendarNoDefaultDelegate) {
      self.init(DefaultDelegate(delegate))
      self.calendar = calendar
    }
  }
}

// MARK: - NNGridDisplayFunction
extension NNCalendarLegacy.Regular99.Bridge: NNGridDisplayFunction {
  var weekdayStacks: Int {
    return calendar.zipWith(delegate, {$1.weekdayStacks(for: $0)}).getOrElse(0)
  }
}

// MARK: - NNMonthAwareModelFunction
extension NNCalendarLegacy.Regular99.Bridge: NNMonthAwareModelFunction {
  var currentMonthStream: Observable<NNCalendarLogic.Month> {
    return currentMonthSb
      .map({[weak self] in (self?.calendar)
        .zipWith(self?.delegate, {$1.currentMonth(for: $0)})
        .flatMap({$0})})
      .filter({$0.isSome}).map({$0!})
  }
}

// MARK: - NNMonthControlFunction
extension NNCalendarLegacy.Regular99.Bridge: NNMonthControlFunction {
  var currentMonthReceiver: AnyObserver<NNCalendarLogic.Month> {
    return currentMonthSb.mapObserver({[weak self] month -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, currentMonthChanged: month)
      })
    })
  }
}

// MARK: - NNMonthControlModelFunction
extension NNCalendarLegacy.Regular99.Bridge: NNMonthControlModelFunction {
  var minimumMonth: NNCalendarLogic.Month {
    return calendar
      .zipWith(delegate, {$1.minimumMonth(for: $0)})
      .getOrElse(NNCalendarLogic.Month(Date()))
  }

  var maximumMonth: NNCalendarLogic.Month {
    return calendar
      .zipWith(delegate, {$1.maximumMonth(for: $0)})
      .getOrElse(NNCalendarLogic.Month(Date()))
  }

  var initialMonthStream: Single<NNCalendarLogic.Month> {
    return Single.just(calendar.zipWith(delegate, {$1.initialMonth(for: $0)})
      .getOrElse(NNCalendarLogic.Month(Date())))
  }
}

// MARK: - NNMonthHeaderModelFunction
extension NNCalendarLegacy.Regular99.Bridge: NNMonthHeaderModelFunction {
  func formatMonthDescription(_ month: NNCalendarLogic.Month) -> String {
    return calendar
      .zipWith(delegate, {$1.regular99($0, monthDescriptionFor: month)})
      .getOrElse("")
  }
}

// MARK: - NNMultiDaySelectionFunction
extension NNCalendarLegacy.Regular99.Bridge: NNMultiDaySelectionFunction {
  var allSelectionReceiver: AnyObserver<Set<NNCalendarLogic.Selection>> {
    return selectionSb.mapObserver({[weak self] selection -> Void in
      (self?.calendar).zipWith(self?.delegate, {
        $1.regular99($0, selectionChanged: selection)
      })})
  }

  var allSelectionStream: Observable<Try<Set<NNCalendarLogic.Selection>>> {
    return selectionSb
      .map({[weak self] in (self?.calendar)
        .zipWith(self?.delegate, {$1.currentSelections(for: $0)})
      })
      .filter({$0.isSome}).map({$0!.asTry()})
  }
}

// MARK: - NNMultiMonthGridSelectionCalculator
extension NNCalendarLegacy.Regular99.Bridge: NNMultiMonthGridSelectionCalculator {
  func gridSelectionChanges(_ monthComps: [NNCalendarLogic.MonthComp],
                            _ currentMonth: NNCalendarLogic.Month,
                            _ prev: Set<NNCalendarLogic.Selection>,
                            _ current: Set<NNCalendarLogic.Selection>)
    -> Set<NNCalendarLogic.GridPosition>
  {
    return calendar
      .zipWith(delegate, {
        $1.regular99($0, gridSelectionChangesFor: monthComps,
                     whileCurrentMonthIs: currentMonth,
                     withPreviousSelection: prev,
                     andCurrentSelection: current)})
      .getOrElse([])
  }
}

// MARK: - NNSelectHighlightFunction
extension NNCalendarLegacy.Regular99.Bridge: NNSelectHighlightFunction {
  func highlightPart(_ date: Date) -> NNCalendarLogic.HighlightPart {
    return calendar
      .zipWith(delegate, {$1.regular99($0, highlightPartFor: date)})
      .getOrElse(.none)
  }
}

// MARK: - NNSingleDaySelectionFunction
extension NNCalendarLegacy.Regular99.Bridge: NNSingleDaySelectionFunction {
  func isDateSelected(_ date: Date) -> Bool {
    return calendar
      .zipWith(delegate, {$1.regular99($0, isDateSelected: date)})
      .getOrElse(false)
  }
}

// MARK: - NNWeekdayAwareModelFunction
extension NNCalendarLegacy.Regular99.Bridge: NNWeekdayAwareModelFunction {
  var firstWeekday: Int {
    return calendar.zipWith(delegate, {$1.firstWeekday(for: $0)}).getOrElse(1)
  }
}

// MARK: - NNWeekdayDisplayModelFunction
extension NNCalendarLegacy.Regular99.Bridge: NNWeekdayDisplayModelFunction {
  func weekdayDescription(_ weekday: Int) -> String {
    return calendar
      .zipWith(delegate, {$1.regular99($0, weekdayDescriptionFor: weekday)})
      .getOrElse("")
  }
}

// MARK: - NNRegular99CalendarModelDependency
extension NNCalendarLegacy.Regular99.Bridge: NNRegular99CalendarModelDependency {}

// MARK: - Delegate wrapper.
extension NNCalendarLegacy.Regular99.Bridge {

  /// Wrapper for delegate to store reference weakly. This is because we need
  /// to store a strong reference to the delegate in the bridge class to cater
  /// to default dependencies.
  final class Wrapper: NNRegular99CalendarDelegate {
    private weak var delegate: NNRegular99CalendarDelegate?

    init(_ delegate: NNRegular99CalendarDelegate) {
      self.delegate = delegate
    }

    /// Defaultable.
    func firstWeekday(for calendar: NNRegular99Calendar) -> Int {
      return delegate?.firstWeekday(for: calendar) ?? 1
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return delegate?.regular99(calendar, weekdayDescriptionFor: weekday) ?? ""
    }

    func weekdayStacks(for calendar: NNRegular99Calendar) -> Int {
      return delegate?.weekdayStacks(for: calendar) ?? 0
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   monthDescriptionFor month: NNCalendarLogic.Month) -> String {
      return NNCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   gridSelectionChangesFor months: [NNCalendarLogic.MonthComp],
                   whileCurrentMonthIs month: NNCalendarLogic.Month,
                   withPreviousSelection prev: Set<NNCalendarLogic.Selection>,
                   andCurrentSelection current: Set<NNCalendarLogic.Selection>)
      -> Set<NNCalendarLogic.GridPosition>
    {
      return delegate?.regular99(calendar,
                                 gridSelectionChangesFor: months,
                                 whileCurrentMonthIs: month,
                                 withPreviousSelection: prev,
                                 andCurrentSelection: current) ?? []
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate
        .map({$0.minimumMonth(for: calendar)})
        .getOrElse(NNCalendarLogic.Month(Date()))
    }

    func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate
        .map({$0.maximumMonth(for: calendar)})
        .getOrElse(NNCalendarLogic.Month(Date()))
    }

    func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate
        .map({$0.initialMonth(for: calendar)})
        .getOrElse(NNCalendarLogic.Month(Date()))
    }

    func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month? {
      return delegate?.currentMonth(for: calendar)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   currentMonthChanged month: NNCalendarLogic.Month) {
      delegate?.regular99(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: NNRegular99Calendar) -> Set<NNCalendarLogic.Selection>? {
      return delegate?.currentSelections(for: calendar) ?? []
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   selectionChanged selections: Set<NNCalendarLogic.Selection>) {
      delegate?.regular99(calendar, selectionChanged: selections)
    }

    func regular99(_ calendar: NNRegular99Calendar, isDateSelected date: Date) -> Bool {
      return delegate?.regular99(calendar, isDateSelected: date) ?? false
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   highlightPartFor date: Date) -> NNCalendarLogic.HighlightPart {
      return delegate?.regular99(calendar, highlightPartFor: date) ?? .none
    }
  }
}

// MARK: - Default delegate
extension NNCalendarLegacy.Regular99.Bridge {

  /// This default delegate also includes embedded storage for current month
  /// and selections, all of which are guarded by a lock for concurrent access.
  /// As a result, using these defaults will dramatically reduce the number of
  /// methods to be implemented by a delegate.
  final class DefaultDelegate: NNRegular99CalendarDelegate {
    private weak var delegate: NNRegular99CalendarNoDefaultDelegate?
    private let highlightCalc: NNCalendarLogic.DateCalc.HighlightPart
    private let lock: NSLock
    private var _currentMonth: NNCalendarLogic.Month?
    private var _currentSelections: Set<NNCalendarLogic.Selection>?

    private var currentMonth: NNCalendarLogic.Month? {
      get { lock.lock(); defer { lock.unlock() }; return _currentMonth }
      set { lock.lock(); defer { lock.unlock() }; _currentMonth = newValue }
    }

    private var currentSelections: Set<NNCalendarLogic.Selection>? {
      get { lock.lock(); defer { lock.unlock() }; return _currentSelections }
      set { lock.lock(); defer { lock.unlock() }; _currentSelections = newValue }
    }

    init(_ delegate: NNRegular99CalendarNoDefaultDelegate) {
      self.delegate = delegate
      let weekdayStacks = 6
      let sequentialCalc = NNCalendarLogic.DateCalc.Default(weekdayStacks, 1)
      highlightCalc = NNCalendarLogic.DateCalc.HighlightPart(sequentialCalc, weekdayStacks)
      lock = NSLock()
    }

    /// Defaultable.
    func firstWeekday(for calendar: NNRegular99Calendar) -> Int {
      return 1
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   weekdayDescriptionFor weekday: Int) -> String {
      return NNCalendarLogic.Util.defaultWeekdayDescription(weekday)
    }

    func weekdayStacks(for calendar: NNRegular99Calendar) -> Int {
      return highlightCalc.weekdayStacks
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   monthDescriptionFor month: NNCalendarLogic.Month) -> String {
      return NNCalendarLogic.Util.defaultMonthDescription(month)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   gridSelectionChangesFor months: [NNCalendarLogic.MonthComp],
                   whileCurrentMonthIs month: NNCalendarLogic.Month,
                   withPreviousSelection prev: Set<NNCalendarLogic.Selection>,
                   andCurrentSelection current: Set<NNCalendarLogic.Selection>)
      -> Set<NNCalendarLogic.GridPosition>
    {
      return highlightCalc.gridSelectionChanges(months, month, prev, current)
    }

    /// Non-defaultable.
    func minimumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate?.minimumMonth(for: calendar) ?? NNCalendarLogic.Month(Date())
    }

    func maximumMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate?.maximumMonth(for: calendar) ?? NNCalendarLogic.Month(Date())
    }

    func initialMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month {
      return delegate?.initialMonth(for: calendar) ?? NNCalendarLogic.Month(Date())
    }

    func currentMonth(for calendar: NNRegular99Calendar) -> NNCalendarLogic.Month? {
      return currentMonth
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   currentMonthChanged month: NNCalendarLogic.Month) {
      currentMonth = month
      delegate?.regular99(calendar, currentMonthChanged: month)
    }

    func currentSelections(for calendar: NNRegular99Calendar) -> Set<NNCalendarLogic.Selection>? {
      return currentSelections
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   selectionChanged selections: Set<NNCalendarLogic.Selection>) {
      currentSelections = selections
      delegate?.regular99(calendar, selectionChanged: selections)
    }

    func regular99(_ calendar: NNRegular99Calendar, isDateSelected date: Date) -> Bool {
      return currentSelections
        .map({$0.contains(where: {$0.contains(date)})})
        .getOrElse(false)
    }

    func regular99(_ calendar: NNRegular99Calendar,
                   highlightPartFor date: Date) -> NNCalendarLogic.HighlightPart {
      return currentSelections
        .map({NNCalendarLogic.Util.highlightPart($0, date)})
        .getOrElse(.none)
    }
  }
}

// MARK: - Delegate bridge
public extension NNRegular99Calendar {
  public typealias NoDefaultDelegate = NNRegular99CalendarNoDefaultDelegate
  public typealias Delegate = NNRegular99CalendarDelegate
  public typealias NoDefaultLegacyDependency = (NoDefaultDelegate, Decorator)
  public typealias LegacyDependency = (Delegate, Decorator)

  /// All-inclusive legacy dependency, with no default components.
  public var legacyDependencyLevel1: LegacyDependency? {
    get { return nil }

    set {
      guard let newValue = newValue else {
        #if DEBUG
        fatalError("Properties cannot be nil")
        #else
        return
        #endif
      }

      let modelDp = NNCalendarLegacy.Regular99.Bridge(self, newValue.0)
      let model = NNCalendarPreset.Regular99.Model(modelDp)
      let viewModel = NNCalendarPreset.Regular99.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }

  /// Only need to implement non-defaultable legacy dependencies. Others will
  /// be provided with defaults.
  public var legacyDependencyLevel2: NoDefaultLegacyDependency? {
    get { return nil }

    set {
      guard let newValue = newValue else {
        #if DEBUG
        fatalError("Properties cannot be nil")
        #else
        return
        #endif
      }

      let modelDp = NNCalendarLegacy.Regular99.Bridge(self, newValue.0)
      let model = NNCalendarPreset.Regular99.Model(modelDp)
      let viewModel = NNCalendarPreset.Regular99.ViewModel(model)
      dependency = (viewModel, newValue.1)
    }
  }
}
