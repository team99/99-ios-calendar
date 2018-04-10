//
//  Entry.swift
//  calendar99-logic
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// This is the entry point to all features, and acts as a namespace to the
/// underlying logic.
public final class NNCalendar {}

public extension NNCalendar {

  /// Represents views that can control months.
  internal final class MonthControl {}

  /// Represents the month header display view.
  public final class MonthHeader {}

  /// Represents the month view display view.
  public final class MonthDisplay {}

  /// Represents date calculators.
  public final class DateCalculator {}
}
