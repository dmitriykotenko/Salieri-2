// @ Dmitry Kotenko

import RxCocoa
import RxSwift
import SnapKit
import UIKit

import AVFoundation


class AudioChannelsView: View {

  var channelEvent = PublishSubject<AudioChannelEvent>()

  private var melodyContainer: MelodyContainer

  private var channelViews: [AudioChannelView] = []

  private var childrenDisposeBag = DisposeBag()

  private let spacing: CGFloat = 16

  private let disposeBag = DisposeBag()

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  init(melodyContainer: MelodyContainer) {
    self.melodyContainer = melodyContainer
    super.init()
    channelsListUpdated()
  }

  func channelsListUpdated() {
    channelViews = melodyContainer.channels.map { AudioChannelView(channel: $0) }
    setupLayout()
    listenForChildEvents()
  }

  private func setupLayout() {
    subviews.forEach { $0.removeFromSuperview() }

    let contentView = View()
    contentView.addVerticalStack(
      ofChildViews: channelViews,
      spacing: spacing
    )

    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(0)
      $0.bottom.equalToSuperview().offset(0)
    }
  }

  private func listenForChildEvents() {
    childrenDisposeBag = DisposeBag()

    channelViews.forEach { listenForChildEvents(of: $0) }
  }

  private func listenForChildEvents(of channelView: AudioChannelView) {
    channelView.channelEvent
      .subscribe(onNext: { [weak self, weak channelView] event in
        if let channelView {
          self?.updateChannel(channelView.channel, with: event)
        }
      })
      .disposed(by: childrenDisposeBag)

    channelView.deleteChannel
      .subscribe(onNext: { [weak self] in self?.deleteChannel($0) })
      .disposed(by: childrenDisposeBag)
  }

  func updateChannel(_ channel: AudioChannel,
                     with event: AudioChannelEvent) {
    melodyContainer.process(
      event: .channelChange(event)
    )
  }

  func channelAdded(_ channel: AudioChannel) {
    melodyContainer.process(event: .channelAdded(channel))
    channelsListUpdated()
  }

  func update() {
    zip(melodyContainer.channels, channelViews).forEach { channel, view in
      _ = view.with(channel: channel)
    }
  }

  private func deleteChannel(_ channel: AudioChannel) {
    melodyContainer.process(event: .channelDeleted(id: channel.id))

    let channelHeight = channelViews.first { $0.channel.id == channel.id }?.frame.height ?? 0
    let heightToDelete = channelHeight + spacing

    UIView.animate(
      withDuration: 0.25,
      animations: { [weak self] in
        self?.subviews.first?.snp.updateConstraints {
          $0.top.equalToSuperview().offset(heightToDelete)
          $0.bottom.equalToSuperview().offset(heightToDelete)
        }
        self?.superview?.setNeedsLayout()
        self?.superview?.layoutIfNeeded()
      },
      completion: { [weak self] isFinished in
        self?.channelsListUpdated()

        if isFinished {
          self?.subviews.first?.snp.updateConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.bottom.equalToSuperview().offset(0)
          }
          self?.superview?.setNeedsLayout()
          self?.superview?.layoutIfNeeded()
        }
      }
    )
  }
}
