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
  public typealias ViewModel = NNMonthSectionViewModelType
  public typealias Dependency = ViewModel

  public var dependency: Dependency? {
    get { return nil }
    
    set {
      viewModel = newValue
      didSetViewModel()
    }
  }

  fileprivate var viewModel: ViewModel? {
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
    backgroundColor = .white
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    isPagingEnabled = true
  }
}

// MARK: - Data source.
public extension NNMonthSectionView {
  typealias Section = NNCalendar.MonthComp
  typealias CVSource = CollectionViewSectionedDataSource<Section>
  typealias RxDataSource = RxCollectionViewSectionedAnimatedDataSource<Section>

  /// Use RxDataSource to drive data.
  fileprivate func setupDataSource() -> RxDataSource {
    let dataSource = RxDataSource(
      configureCell: {[weak self] in
        if let `self` = self {
          return self.configureCell($0, $1, $2, $3)
        } else {
          return UICollectionViewCell()
        }
      },
      configureSupplementaryView: {(_, _, _, _) in UICollectionReusableView()}
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
    let sections = source.sectionModels
    let section = indexPath.section

    guard
      section >= 0 && section < source.sectionModels.count,
      let viewModel = self.viewModel,
      let day = viewModel.calculateDayFromFirstDate(sections[section].month, item),
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

    let selected = viewModel.isDateSelected(day.date)    
    cell.setupWithDay(day.with(selected: selected))
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

    viewModel.setupAllBindingsAndSubBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()

    viewModel.monthCompStream
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    let selectionStream = viewModel.currentMonthSelectionIndexStream.share(replay: 1)

    // The scroll position actually affects the cell layout, so be sure to
    // choose carefully.
    selectionStream
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak self] in
        self?.scrollToItem(at: IndexPath(row: 0, section: $0),
                           at: .left,
                           animated: true)
      })
      .disposed(by: disposable)

    // Detect swipes to change current selection.
    let movementStream = self.rx.didEndDecelerating
      .withLatestFrom(selectionStream)
      .map({[weak self] in (self?.calculateOffsetChange($0)) ?? 0})
      .share(replay: 1)

    movementStream
      .filter({$0 >= 0}).map({UInt($0)})
      .bind(to: viewModel.currentMonthForwardReceiver)
      .disposed(by: disposable)

    movementStream
      .filter({$0 < 0})
      .map({UInt(Swift.abs($0))})
      .bind(to: viewModel.currentMonthBackwardReceiver)
      .disposed(by: disposable)

    self.rx.itemSelected
      .map({NNCalendar.GridSelection($0.section, $0.row)})
      .bind(to: viewModel.gridSelectionReceiver)
      .disposed(by: disposable)

    viewModel.gridSelectionChangesStream
      .map({$0.map({IndexPath(row: $0.dayIndex, section: $0.monthIndex)})})
      .observeOn(MainScheduler.instance)
      .bind(onNext: {[weak self] in self?.reloadItems(at: $0)})
      .disposed(by: disposable)
  }

  /// Calculate the change in offset relative to the previous selection index.
  private func calculateOffsetChange(_ pix: Int) -> Int {
    let offset = self.contentOffset
    let bounds = self.bounds

    // Since this view can either be horizontal or vertical, only one origin
    // coordinate (x or y) will be positive, so we need to check for both cases.
    // We also compare with the offset for the previous selection index.
    if offset.x == 0 && offset.y == 0 {
      return -pix
    } else if offset.x > 0 {
      return Int((offset.x - CGFloat(pix) * bounds.width) / bounds.width)
    } else {
      return Int((offset.y - CGFloat(pix) * bounds.height) / bounds.height)
    }
  }
}

// MARK: - IdentifiableType
extension NNCalendar.MonthComp: IdentifiableType {
  public typealias Identity = String

  public var identity: String {
    return "\(month.month)-\(month.year)"
  }
}

/// Notice that we don't actually store any data here - this is done so that
/// the memory footprint is as small as possible. If a cell requires data to
/// display, that data will be calculated at the time it's requested.
extension NNCalendar.MonthComp: AnimatableSectionModelType {
  public typealias Item = Int

  public var items: [Item] {
    return (0..<dayCount).map({$0})
  }

  public init(original: NNCalendar.MonthComp, items: [Item]) {
    self.init(original.month, items.count)
  }
}
