// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class SliderView: View {

  var value = BehaviorSubject<Float?>(value: nil)

  private let titleLabel = UILabel.small
  private let valueLabel = UILabel.small.with(textAlignment: .right)
  private let slider = UISlider().preparedForAutoLayout()

  private lazy var tapGesture = UITapGestureRecognizer(
    target: self,
    action: #selector(onTap)
  )

  private let valueFormatter = NumberFormatter.float

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(title: String?,
       bounds: ClosedRange<Float>) {
    super.init()

    titleLabel.text = title
    setupSlider(bounds: bounds)
    setupLayout()
    valueUpdated()
  }

  private func setupLayout() {
    clipsToBounds = false

    addSubview(titleLabel)
    titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    titleLabel.snp.makeConstraints {
      $0.width.equalTo(90)
      $0.centerY.leading.equalToSuperview()
    }

    addSubview(slider)
    slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
    slider.setContentCompressionResistancePriority(.required, for: .horizontal)
    slider.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.equalTo(titleLabel.snp.trailing).offset(16)
    }

    addSubview(valueLabel)
    valueLabel.setContentHuggingPriority(.required, for: .horizontal)
    valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    valueLabel.snp.makeConstraints {
      $0.width.equalTo(44)
      $0.centerY.trailing.equalToSuperview()
      $0.leading.equalTo(slider.snp.trailing)
    }
  }

  private func setupSlider(bounds: ClosedRange<Float>) {
    slider.minimumValue = bounds.lowerBound
    slider.maximumValue = bounds.upperBound

    slider.rx.value
      .subscribe(onNext: { [weak self] _ in self?.userDidUpdateValue() })
      .disposed(by: disposeBag)

    addGestureRecognizer(tapGesture)
  }

  @objc
  private func onTap() {
    let tapLocation = tapGesture.location(in: slider)
    if slider.bounds.contains(tapLocation) {
      let fraction = tapLocation.x / slider.bounds.width
      let unsafeNewValue = slider.minimumValue + Float(fraction) * (slider.maximumValue - slider.minimumValue)
      let newValue = unsafeNewValue.clamped(inside: slider.minimumValue...slider.maximumValue)
      slider.value = newValue
      userDidUpdateValue()
    }
  }

  private func userDidUpdateValue() {
    value.onNext(slider.value)
    valueUpdated()
  }

  private func valueUpdated() {
    valueLabel.text = valueFormatter.string(from: slider.value as NSNumber)
  }

  func with(value: Float) -> Self {
    self.value.onNext(value)
    slider.value = value
    valueUpdated()
    return self
  }
}
