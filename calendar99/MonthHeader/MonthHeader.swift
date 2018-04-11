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
public final class NNMonthHeaderView: UIView {
  @IBOutlet fileprivate weak var backwardImg: UIImageView!
  @IBOutlet fileprivate weak var backwardBtn: UIButton!
  @IBOutlet fileprivate weak var forwardImg: UIImageView!
  @IBOutlet fileprivate weak var forwardBtn: UIButton!
  @IBOutlet fileprivate weak var monthLbl: UILabel!
  
  public var viewModel: NNMonthHeaderViewModelType? {
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
    NNCalendar.ViewUtil.initializeWithNib(view: self, "MonthHeader")
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    NNCalendar.ViewUtil.initializeWithNib(view: self, "MonthHeader")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    guard !initialized,
      backwardImg != nil,
      backwardBtn != nil,
      forwardImg != nil,
      forwardBtn != nil,
      monthLbl != nil else
    {
      return
    }

    initialized = true
    setupViews()
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - Views
public extension NNMonthHeaderView {
  fileprivate func setupViews() {
    let bundle = Bundle(for: NNMonthHeaderView.classForCoder())
    print(backwardImg, forwardImg)

    guard
      let backwardImg = self.backwardImg,
      let forwardImg = self.forwardImg,
      let backwardIcon = UIImage(named: "backward", in: bundle, compatibleWith: nil)?
        .withRenderingMode(.alwaysTemplate),
      let backwardCgImage = backwardIcon.cgImage
      else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    /// Flip programmatically to reuse assets.
    let forwardIcon = UIImage(cgImage: backwardCgImage,
                              scale: 1,
                              orientation: .down)
      .withRenderingMode(.alwaysTemplate)

    backwardImg.image = backwardIcon
    forwardImg.image = forwardIcon
  }
}

// MARK: - Bindings.
public extension NNMonthHeaderView {

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
      .bind(to: viewModel.currentMonthBackwardReceiver)
      .disposed(by: disposable)

    forwardBtn.rx.tap.map({1})
      .bind(to: viewModel.currentMonthForwardReceiver)
      .disposed(by: disposable)

    viewModel.monthDescriptionStream
      .observeOn(MainScheduler.instance)
      .bind(to: monthLbl.rx.text)
      .disposed(by: disposable)
  }
}
