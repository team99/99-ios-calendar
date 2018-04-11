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
  public var viewModel: NNMonthSectionViewModelType? {
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
    guard !initialized else { return }
    initialized = true
    setupViews()
  }

  private func didSetViewModel() {
    bindViewModel()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NNMonthSectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize
  {
    return CGSize.zero
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int) -> CGFloat
  {
    return 0
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  {
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cHeight = collectionView.bounds.height
    let cWidth = collectionView.bounds.width

    return viewModel
      .map({(cWidth / CGFloat($0.columnCount), cHeight / CGFloat($0.rowCount))})
      .map({CGSize(width: $0, height: $1)})
      .getOrElse(CGSize.zero)
  }
}

// MARK: - Views.
public extension NNMonthSectionView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  fileprivate func setupViews() {
    let bundle = Bundle(for: NNDateCell.classForCoder())
    let cellNib = UINib(nibName: "DateCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    isPagingEnabled = true
  }
}

// MARK: - Data source.
public extension NNMonthSectionView {
  typealias Section = NNCalendar.Month
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

    dataSource.canMoveItemAtIndexPath = {(_, _) in false}
    return dataSource
  }

  private func configureCell(_ source: CVSource,
                             _ view: UICollectionView,
                             _ indexPath: IndexPath,
                             _ item: Section.Item)
    -> UICollectionViewCell
  {
    let sections = source.sectionModels
    let section = indexPath.section

    guard
      section >= 0 && section < source.sectionModels.count,
      let viewModel = self.viewModel,
      let day = viewModel.calculateDay(sections[section].monthComp, item),
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: cellId,
        for: indexPath) as? NNDateCell else
    {
      #if DEBUG
      fatalError("Invalid properties")
      #else
      return UICollectionViewCell()
      #endif
    }

    cell.setupWithDay(day)
    return cell
  }
}

// MARK: - View model bindings.
public extension NNMonthSectionView {

  /// Bind month section view model.
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
//    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.monthStream
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)
  }
}

/// Notice that we don't actually store any data here - this is done so that
/// the memory footprint is as small as possible. If a cell requires data to
/// display, that data will be calculated at the time it's requested.
extension NNCalendar.Month: SectionModelType {
  public typealias Item = Int

  public var items: [Item] {
    return (0..<dayCount).map({$0})
  }

  public init(original: NNCalendar.Month, items: [Item]) {
    self.init(original.monthComp, items.count)
  }
}
