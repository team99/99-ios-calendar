//
//  Regular99ViewController.swift
//  calendar99-demo
//
//  Created by Hai Pham on 23/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import calendar99_preset
import calendar99_presetLogic

public final class Regular99ViewController: UIViewController {
  @IBOutlet fileprivate weak var regular99Calendar: NNRegular99Calendar!

  override public func viewDidLoad() {
    super.viewDidLoad()
    let decorator = AppDecorator()
    let model = NNCalendarPreset.Regular99.Model(Singleton.instance)
    let viewModel = NNCalendarPreset.Regular99.ViewModel(model)
    regular99Calendar.dependency = (viewModel, decorator)
  }
}
