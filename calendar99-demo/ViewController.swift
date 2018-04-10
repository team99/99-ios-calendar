//
//  ViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import UIKit
import calendar99_logic
import calendar99

public final class ViewController: UIViewController  {
  @IBOutlet weak var calendarView: Calendar99MainView!
  fileprivate let monthSb = BehaviorSubject(value: 1)
  fileprivate let yearSb = BehaviorSubject(value: 2018)

  override public func viewDidLoad() {
    super.viewDidLoad()
    let model = Calendar99.Main.Model(self)
    let viewModel = Calendar99.Main.ViewModel(self, model)
    calendarView.viewModel = viewModel
  }
}

/// BEWARE MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: Calendar99MainModelDependency {
  public var monthStream: Observable<Int> {
    return monthSb
  }

  public var initialMonthStream: Single<Int> {
    let date = Date()
    let month = Calendar.current.component(.month, from: date)
    return Single.just(month)
  }

  public var yearStream: Observable<Int> {
    return yearSb
  }

  public var initialYearStream: Single<Int> {
    let date = Date()
    let year = Calendar.current.component(.year, from: date)
    return Single.just(year)
  }

  public var monthReceiver: AnyObserver<Int> {
    return monthSb.asObserver()
  }

  public var yearReceiver: AnyObserver<Int> {
    return yearSb.asObserver()
  }
}

extension ViewController: Calendar99MainViewModelDependency {}
