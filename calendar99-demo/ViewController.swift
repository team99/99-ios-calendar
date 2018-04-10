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

  public var monthStream: Observable<Int> {
    return monthSb
  }

  public var yearStream: Observable<Int> {
    return yearSb
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    let model = Calendar99.Main.Model(self)
    let viewModel = Calendar99.Main.ViewModel(self, model)
    calendarView.viewModel = viewModel
  }
}

/// BEWARE MEMORY LEAKS HERE. THIS IS ONLY TEMPORARY.

extension ViewController: Calendar99ModelDependency {}

extension ViewController: Calendar99ViewModelDependency {}
