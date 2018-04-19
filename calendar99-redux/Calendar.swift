//
//  Calendar.swift
//  calendar99-redux
//
//  Created by Hai Pham on 18/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import calendar99_logic

/// Grouping for calendar-related Redux components.
public final class ReduxCalendar {

  /// Calendar actions, including month, date selections etc.
  public enum Action: ReduxActionType {
    case updateCurrentMonth(NNCalendar.Month)
    case updateSelection(Set<NNCalendar.Selection>)
    case clearAll

    fileprivate static var basePath: String {
      return "calendar99.calendar"
    }

    public static var currentMonthPath: String {
      return "\(basePath).currentMonth"
    }

    public static var selectionPath: String {
      return "\(basePath).selection"
    }
  }

  /// Calendar reducers.
  public final class Reducer {

    /// Reduce calendar actions to produce a new state.
    ///
    /// - Parameters:
    ///   - prevState: A TreeState instance.
    ///   - action: An Action instance.
    /// - Returns: A TreeState instance.
    public static func reduce(_ prevState: TreeState<Any>,
                              _ action: Action) -> TreeState<Any> {
      switch action {
      case .updateCurrentMonth(let month):
        return prevState.updateValue(Action.currentMonthPath, month)

      case .updateSelection(let selection):
        return prevState.updateValue(Action.selectionPath, selection)

      case .clearAll:
        return prevState
          .removeValue(Action.currentMonthPath)
          .removeValue(Action.selectionPath)
      }
    }
  }
}
