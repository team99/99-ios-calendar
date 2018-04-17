# 99-ios-calendar

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/team99/99-ios-calendar.svg?branch=master)](https://travis-ci.org/team99/99-ios-calendar)
[![Coverage Status](https://coveralls.io/repos/github/team99/99-ios-calendar/badge.svg?branch=master)](https://coveralls.io/github/team99/99-ios-calendar?branch=master&dummy=true)

Almost fully-configurable calendar view for iOS applications that runs entirely on Rx. 

Reactive programming allows us to produce truly decoupled components that are open to extensions but closed for modications. For example, date selections in a month view are driven by a selected date stream (**Observable[Set[Date]]**), so if we want to add a weekday bar view with logic such that clicking on a weekday (e.g. **Monday**) selects the entire date range (corresponding to said weekday), all we need to do is just push a custom set of selected dates into the stream and we will see those dates being selected automatically.

If ever so required, we can write bridges that connect imperative and reactive to cater to legacy code, but it's best to minimize such bridges if we want to build scalable applications.

The relevant components included in this repository are:

- **MonthView**: A simple calendar view that does date calculations lazily depending on the currently selected month. It's very lightweight, but lacks the flipping animations present in **MonthSectionView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthSectionView**: Traditional swipe calendar view that caches months as specified. Since this view needs to store months and cell attributes, it is a bit slower than **MonthView**. It's capable of: **MonthGrid**, **MonthControl**, **SingleDaySelection**.

- **MonthHeaderView**: Header view that displays the currently selected month and possesses buttons that allow month navigations. It's capable of: **MonthControl**.

- **WeekdayView**: Simple list-based view that displays weekdays. It's capable of: **WeedayDisplay**.

- **SelectableWeekdayView**: **WeekdayView** decorator that allows the user to select all dates with a particular weekday. It's capable of: **WeekdayDisplay**, **MultiDaySelection**. 

Each of these views requires its own **ViewModel** and **Model**, so we must be sure to inject those after creating them.
