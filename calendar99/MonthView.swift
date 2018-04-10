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

/// Month view implementation.
public final class NNMonthView: UICollectionView {
  public var viewModel: NNMonthDisplayViewModelType? {
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
  private lazy var initialized = false

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

// MARK: - UICollectionViewDelegateFlowLayout
extension NNMonthView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int)
    -> CGSize
  {
    return CGSize.zero
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let containerHeight = collectionView.bounds.height
    let containerWidth = collectionView.bounds.width

    return viewModel
      .map({(containerWidth / CGFloat($0.columnCount),
             containerHeight / CGFloat($0.rowCount))})
      .map({CGSize(width: $0, height: $1)})
      .getOrElse(CGSize.zero)
  }
}

// MARK: - Views.
public extension NNMonthView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  /// Set up views/sub-views in the calendar view.
  fileprivate func setupViews() {
    register(UINib(nibName: "DateCell", bundle: nil),
             forCellWithReuseIdentifier: cellId)
  }
}

// MARK: - Data source.
public extension NNMonthView {
  typealias Section = AnimatableSectionModel<String, NNCalendar.Day>
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

    dataSource.animationConfiguration = AnimationConfiguration(
      insertAnimation: .left,
      reloadAnimation: .fade,
      deleteAnimation: .right
    )

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    return NNDateCell()
  }

  private func configureSupplementaryView(_ source: CVSource,
                                          _ view: UICollectionView,
                                          _ kind: String,
                                          _ indexPath: IndexPath)
    -> UICollectionReusableView
  {
    return UICollectionReusableView()
  }
}

// MARK: - View model bindings.
public extension NNMonthView {
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
    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.dayStream
      .map({[Section(model: "", items: $0)]})
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)
  }
}

extension NNCalendar.Day: IdentifiableType {
  public typealias Identity = Date

  public var identity: Identity {
    return date
  }
}
