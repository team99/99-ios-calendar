//
//  View.swift
//  calendar99
//
//  Created by Hai Pham on 10/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import SwiftFP
import calendar99_logic

/// Calendar view implementation.
public final class Calendar99MainView: UICollectionView {
  public var viewModel: Calendar99ViewModelType? {
    willSet {
      #if DEBUG
      if viewModel != nil {
        fatalError("Cannot mutate view model!")
      }
      #endif
    }
  }

  fileprivate lazy var disposable: DisposeBag = DisposeBag()

  private lazy var initialized = false

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard !initialized else { return }
    defer { initialized = true }
    setupViews()
    bindViewModel()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension Calendar99MainView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int)
    -> CGSize
  {
    return CGSize(width: collectionView.bounds.width, height: 60)
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize.zero
  }
}

// MARK: - Views.
public extension Calendar99MainView {
  fileprivate var headerId: String {
    return "MonthHeader"
  }

  /// Set up views/sub-views in the calendar view.
  fileprivate func setupViews() {
    register(UINib(nibName: "MonthHeader", bundle: nil),
             forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
             withReuseIdentifier: headerId)
  }
}

// MARK: - Data source.
public extension Calendar99MainView {
  typealias Section = AnimatableSectionModel<String, String>
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedAnimatedDataSource<Section>

  /// Use RxDataSources to drive data.
  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(
      configureCell: {[weak self] in
        if let `self` = self {
          return self.configureCell($0, $1, $2, $3)
        } else {
          return UICollectionViewCell()
        }
      },
      configureSupplementaryView: {[weak self] in
        if let `self` = self {
          return self.configureSupplementaryView($0, $1, $2, $3)
        } else {
          return UICollectionReusableView()
        }
    })

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    return Calendar99MainCell()
  }

  private func configureSupplementaryView(_ source: CVSource,
                                          _ view: UICollectionView,
                                          _ kind: String,
                                          _ indexPath: IndexPath)
    -> UICollectionReusableView
  {
    switch kind {
    case UICollectionElementKindSectionHeader:
      guard let monthHeader = view.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: headerId,
        for: indexPath) as? Calendar99MonthHeader else
      {
        break
      }

      bindMonthHeaderView(monthHeader)
      return monthHeader

    default:
      break
    }

    return UICollectionReusableView()
  }
}

// MARK: - Bindings.
public extension Calendar99MainView {

  /// Set up stream bindings.
  fileprivate func bindViewModel() {
    guard let viewModel = self.viewModel else {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let disposable = self.disposable
    let dataSource = setupDataSource()
    viewModel.setupBindings()
    self.rx.setDelegate(self).disposed(by: disposable)
  }

  /// Bind month header views.
  ///
  /// - Parameter monthHeader: A MonthHeader instance.
  fileprivate func bindMonthHeaderView(_ monthHeader: Calendar99MonthHeader) {
    guard
      let viewModel = self.viewModel,
      let monthForward = monthHeader.forwardBtn,
      let monthBackward = monthHeader.backwardBtn else
    {
      #if DEBUG
      fatalError("Properties cannot be nil")
      #else
      return
      #endif
    }

    let disposable = self.disposable

    monthForward.rx.tap.map({1})
      .bind(to: viewModel.monthForwardReceiver)
      .disposed(by: disposable)

    monthBackward.rx.tap.map({1})
      .bind(to: viewModel.monthBackwardReceiver)
      .disposed(by: disposable)
  }
}
