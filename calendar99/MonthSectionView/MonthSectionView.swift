//
//  MonthSectionView.swift
//  calendar99
//
//  Created by Hai Pham on 11/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxDataSources
import RxSwift
import UIKit
import calendar99_logic

/// Divide months into sections. This view should provide swiping animations
/// when switching from one month to another, but the caveat is that there are
/// a finite number of months. However, if we set that number high enough, I
/// doubt the user would be able to scroll past the limits anyway.
public final class NNMonthSectionView: UICollectionView {
  private lazy var initialized = false

  override public func layoutSubviews() {
    super.layoutSubviews()
    guard !initialized else { return }
    initialized = true
    setupViews()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NNMonthSectionView: UICollectionViewDelegateFlowLayout {}

// MARK: - Views.
extension NNMonthSectionView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  fileprivate func setupViews() {
    let bundle = Bundle(for: NNDateCell.classForCoder())
    let cellNib = UINib(nibName: "DateCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
  }
}

// MARK: - Data source.
extension NNMonthSectionView {
  typealias Section = SectionModel<String, NNCalendar.Month>
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedReloadDataSource<Section>

  /// Use RxDataSource to drive data.
  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(configureCell: {[weak self] in
      if let `self` = self {
        return self.configureCell($0, $1, $2, $3)
      } else {
        return UICollectionViewCell()
      }
    })

    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    guard let cell = view.dequeueReusableCell(
      withReuseIdentifier: cellId,
      for: indexPath) as? NNDateCell else
    {
      #if DEBUG
      fatalError("Unrecognized cell")
      #else
      return UICollectionViewCell()
      #endif
    }

    return cell
  }
}
