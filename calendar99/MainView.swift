//
//  MainView.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import UIKit
import calendar99_logic

/// Header view for calendar.
public final class Calendar99MainView: UIView {
  @IBOutlet weak var backwardImg: UIImageView!
  @IBOutlet weak var backwardBtn: UIButton!
  @IBOutlet weak var forwardImg: UIImageView!
  @IBOutlet weak var forwardBtn: UIButton!

  public var viewModel: Calendar99MainViewModelType? {
    willSet {
      #if DEBUG
      if viewModel != nil {
        fatalError("Cannot mutate view model!")
      }
      #endif
    }

    didSet {
      didSetViewModel()
    }
  }

  fileprivate lazy var disposable: DisposeBag = DisposeBag()
  fileprivate lazy var initialized = false

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    Calendar99.ViewUtil.initializeWithNib(view: self, "MainView")
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    Calendar99.ViewUtil.initializeWithNib(view: self, "MainView")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard !initialized else { return }
    defer { initialized = true }
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - Views
public extension Calendar99MainView {
  fileprivate func setupViews() {
    
  }
}

// MARK: - Bindings.
public extension Calendar99MainView {

  /// Set up stream bindings.
  fileprivate func bindViewModel() {
    guard
      let viewModel = self.viewModel,
      let backwardBtn = self.backwardBtn,
      let forwardBtn = self.forwardBtn else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let disposable = self.disposable
    viewModel.setupBindings()

    backwardBtn.rx.tap.map({1})
      .bind(to: viewModel.monthBackwardReceiver)
      .disposed(by: disposable)

    forwardBtn.rx.tap.map({1})
      .bind(to: viewModel.monthForwardReceiver)
      .disposed(by: disposable)
  }
}
