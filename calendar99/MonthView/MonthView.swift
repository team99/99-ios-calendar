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

/// Month view implementation. This view should be quite memory-efficient since
/// it calculates dates lazily based on the user's current month selection. As
/// a result, it does not have scrolling animations when switching months, so
/// if we are looking for feel instead of function, skip this.
public final class NNMonthView: UICollectionView {
  public typealias ViewModel = NNMonthDisplayViewModelType
  public typealias Dependency = ViewModel

  public var dependency: Dependency? {
    get { return nil }
    
    set {
      viewModel = newValue
      didSetViewModel()
    }
  }

  fileprivate var viewModel: NNMonthDisplayViewModelType? {
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
extension NNMonthView: UICollectionViewDelegateFlowLayout {
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
public extension NNMonthView {
  fileprivate var cellId: String {
    return "DateCell"
  }

  /// Set up views/sub-views in the calendar view.
  fileprivate func setupViews() {
    let bundle = Bundle(for: NNDateCell.classForCoder())
    let cellNib = UINib(nibName: "DateCell", bundle: bundle)
    register(cellNib, forCellWithReuseIdentifier: cellId)
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
      insertAnimation: .fade,
      reloadAnimation: .fade,
      deleteAnimation: .fade
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
    guard
      let viewModel = self.viewModel,
      let cell = view.dequeueReusableCell(
        withReuseIdentifier: cellId,
        for: indexPath) as? NNDateCell else
    {
      #if DEBUG
      fatalError("Unrecognized cell")
      #else
      return UICollectionViewCell()
      #endif
    }

    let selected = viewModel.isDateSelected(item.date)
    cell.setupWithDay(item.with(selected: selected))
    return cell
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

    viewModel.setupAllBindingsAndSubBindings()
    let disposable = self.disposable
    let dataSource = setupDataSource()
    self.rx.setDelegate(self).disposed(by: disposable)

    viewModel.dayStream
      .map({[Section(model: "", items: $0)]})
      .observeOn(MainScheduler.instance)
      .bind(to: self.rx.items(dataSource: dataSource))
      .disposed(by: disposable)

    self.rx.itemSelected
      .map({NNCalendar.GridSelection(0, $0.row)})
      .bind(to: viewModel.gridSelectionReceiver)
      .disposed(by: disposable)

    // Listen to day index selection to know where to reload.
    viewModel.gridDayIndexSelectionChangesStream
      .map({$0.map({IndexPath(row: $0, section: 0)})})
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {[weak self] in self?.reloadItems(at: $0)})
      .disposed(by: disposable)
  }
}

extension NNCalendar.Day: IdentifiableType {
  public typealias Identity = String

  public var identity: Identity {
    return "\(date).\(isCurrentMonth)"
  }
}
