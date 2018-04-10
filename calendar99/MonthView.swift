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
public final class Calendar99MonthView: UICollectionView {
  public var viewModel: Calendar99MainViewModelType? {
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
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension Calendar99MonthView: UICollectionViewDelegateFlowLayout {
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
public extension Calendar99MonthView {
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
public extension Calendar99MonthView {
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
    return Calendar99DateCell()
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
