//
//  MonthHeader.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import UIKit
import calendar99_logic

/// Month header view for calendar.
public final class C99MonthHeaderView: UIView {
  @IBOutlet fileprivate weak var backwardImg: UIImageView!
  @IBOutlet fileprivate weak var backwardBtn: UIButton!
  @IBOutlet fileprivate weak var forwardImg: UIImageView!
  @IBOutlet fileprivate weak var forwardBtn: UIButton!
  @IBOutlet fileprivate weak var monthLbl: UILabel!
  
  public var viewModel: C99MonthHeaderViewModelType? {
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
    Calendar99.ViewUtil.initializeWithNib(view: self, "MonthHeader")
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    Calendar99.ViewUtil.initializeWithNib(view: self, "MonthHeader")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    var didInitialize = false

    objc_sync_enter() {
      didInitialize = self.initialized
      if !self.initialized { self.initialized = true }
    }

    guard !didInitialize else { return }
    setupViews()
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - Views
public extension C99MonthHeaderView {
  fileprivate func setupViews() {}
}

// MARK: - Bindings.
public extension C99MonthHeaderView {

  /// Set up stream bindings.
  fileprivate func bindViewModel() {
    guard
      let viewModel = self.viewModel,
      let monthLbl = self.monthLbl,
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

    viewModel.monthDescriptionStream
      .observeOn(MainScheduler.instance)
      .bind(to: monthLbl.rx.text)
      .disposed(by: disposable)
  }
}
