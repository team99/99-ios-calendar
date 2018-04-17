//
//  DateCellState.swift
//  calendar99
//
//  Created by Hai Pham on 16/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Different states for background.
public enum NNDateCellBackgroundState {
  case normal             // This is mutex with isNotCurrentMonth.
  case isNotCurrentMonth  // This is mutex with normal.
  case isSelected         // This overrides everything.
}

/// Different states for date description label.
public enum NNDateCellDescState {
  case normal             // This is mutex with isNotCurrentMonth.
  case isNotCurrentMonth  // This is mutex with normal.
  case isToday            // This overrides everything.
  case isSelected         // This has priority over normal.
}
