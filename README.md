# 99-ios-calendar

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/team99/99-ios-calendar.svg?branch=master)](https://travis-ci.org/team99/99-ios-calendar)
[![Coverage Status](https://coveralls.io/repos/github/team99/99-ios-calendar/badge.svg?branch=master&dummy=false)](https://coveralls.io/github/team99/99-ios-calendar?branch=master&dummy=false)

Almost fully-configurable calendar view for iOS applications that runs entirely on Rx.

<img width="418" alt="screen shot 2018-04-24 at 3 44 19 pm" src="https://user-images.githubusercontent.com/12141908/39176228-851bc97e-47d6-11e8-9ac0-6b65e8ca6d14.png">

Note that the top and bottom calendars are two different types of views that are driven by the same streams, so any selection or change in month from one view will also show up on the other.

Reactive programming allows us to produce truly decoupled components that are open to extensions but closed for modications. For example, date selections in a month view are driven by a selected date stream (**Observable[Set[Date]]**), so if we want to add a weekday bar view with logic such that clicking on a weekday (e.g. **Monday**) selects the entire date range (corresponding to said weekday), all we need to do is just push a custom set of selected dates into the stream and we will see those dates being selected automatically.

If ever so required, we can write bridges that connect imperative and reactive to cater to legacy code, but it's best to minimize such bridges if we want to build scalable applications.

The relevant components included in this repository are:

- **MonthView**: A simple calendar view that does date calculations lazily depending on the currently selected month. It's very lightweight, but lacks the flipping animations present in **MonthSectionView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthSectionView**: Traditional swipe calendar view that caches months as specified. Since this view needs to store months and cell attributes, it is a bit slower than **MonthView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthHeaderView**: Header view that displays the currently selected month and possesses buttons that allow month navigations. It's capable of: **MonthControl**.

- **WeekdayView**: Simple list-based view that displays weekdays. It's capable of: **WeedayDisplay**.

- **SelectableWeekdayView**: **WeekdayView** decorator that allows the user to select all dates with a particular weekday. It's capable of: **WeekdayDisplay**, **MultiDaySelection**. 

Each of these views requires its own **ViewModel** and **Model**, so we must be sure to inject those after creating them.

## Terminologies

- Any protocol that ends with **Function** means it contains functionalities which are shared between/among two or more classes/protocols. For example, **NNxxFunction** contains shared functionalities between a model and view model for a specific view; **NNxxModelFunction** is the same for a model and its dependency.

- Any protocol whose name contains **Default** or **NoDefault** has properties that are defaultable or non-defaultable. For e.g., **NNGridDisplayDefaultFunction** has **weekdayStacks** property with a default value of 6. Default protocols only extend from other defaults, and likewise for NoDefaults (e.g., **NNMonthGridDefaultFunction** extends from **NNGridDisplayDefaultFunction**, but not **NNGridDisplayNoDefaultFunction**). There are internal **DefaultDependency** classes that provide default values. 

- Usually protocols will have the postfix **Type**, (e.g. **ViewModelType**, **ModelType**), but not always. A **ViewModel** will have a protocol **ViewModelType** and an implementation.

- Actual model and view model implementations are nested in classes defined in **Entry.swift** (e.g. **NNCalendarLogic.MonthSection.ViewModel**).

## Presets

- The target **calendar99-preset** contains preset views with commonly used templates. For example, we have **Regular99**, which is a regular calendar view that can be used in 99's related applications.

- More presets will be added if the need arises.

## Namespace

- **NNCalendarLogic** contains basic logic, **Model** and **ViewModel** for views in **calendar99** target. All classes under this namespace can be found in **calendar99-logic**, and the entry file for this namespace is **LogicEntry.swift**.

- **NNCalendarRedux** contains Redux components. All classes under this namespace can be found in **calendar99-redux**, and the entry file for this namespace is **ReduxEntry.swift**.

- **NNCalendarLegacy** contains legacy components. All classes under this namespace can be found in **calendar99-legacy**, and the entry file for this namespace is **LegacyEntry.swift**.

- Since protocols cannot be nested in classes, they are defined at top level, depending on the features they are supposed to provide (e.g. **NNMultiDaySelectionNoDefaultFunction** contains non-defaultable multi-date selection features).

## Legacy bridge

- If you find the amount of dependencies to implement too daunting, and have reservations towards reactive programming, check out legacy bridges in **calendar99-legacy**. Currently only delegate bridges for **Regular99** are provided. 

- The minimum amount of methods for **NNRegular99CalendarNoDefaultDelegate** is just 5 (at the time of writing). Please run the demo app and open **Regular99LegacyViewController** to see the bridge in action.
