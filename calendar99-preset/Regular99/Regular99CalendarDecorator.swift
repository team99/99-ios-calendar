//
//  Regular99CalendarDecorator.swift
//  calendar99-preset
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import calendar99

/// Decorator for Regular99 Calendar.
public protocol NNRegular99CalendarDecoratorType:
  NNMonthHeaderDecoratorType,
  NNMonthSectionDecoratorType,
  NNWeekdayViewDecoratorType {}
