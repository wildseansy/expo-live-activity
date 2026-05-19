import SwiftUI
import WidgetKit

struct LiveActivityMediumView: View {
  let contentState: LiveActivityAttributes.ContentState
  let attributes: LiveActivityAttributes
  @Binding var imageContainerSize: CGSize?
  let alignedImage: (String, HorizontalAlignment, Bool) -> AnyView

  private var hasImage: Bool {
    contentState.imageName != nil
  }

  private var isLeftImage: Bool {
    (attributes.imagePosition ?? "right").hasPrefix("left")
  }

  private var isStretch: Bool {
    (attributes.imagePosition ?? "right").contains("Stretch")
  }

  private var effectiveStretch: Bool {
    isStretch && hasImage
  }

  private var progressViewTint: Color? {
    attributes.progressViewTint.map { Color(hex: $0) }
  }

  private func formattedDuration(startMs: Double, endMs: Double) -> String {
    let totalSeconds = Int((endMs - startMs) / 1000)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%d:%02d", minutes, seconds)
  }

  var body: some View {
    let padding = attributes.resolvedPadding(defaultPadding: 24)

    let _ = contentState.logSegmentedProgressWarningIfNeeded()

    VStack(alignment: .leading) {
      HStack(alignment: .center) {
        if hasImage, isLeftImage {
          if let imageName = contentState.imageName {
            alignedImage(imageName, .leading, false)
          }
        }

        VStack(alignment: .leading, spacing: 2) {
          Text(contentState.title)
            .font(.title2)
            .fontWeight(.semibold)
            .modifier(ConditionalForegroundViewModifier(color: attributes.titleColor))

          if let subtitle = contentState.subtitle {
            Text(subtitle)
              .font(.title3)
              .modifier(ConditionalForegroundViewModifier(color: attributes.subtitleColor))
          }

          if effectiveStretch {
            if contentState.hasSegmentedProgress,
               let currentStep = contentState.currentStep,
               let totalSteps = contentState.totalSteps,
               totalSteps > 0
            {
              SegmentedProgressView(
                currentStep: currentStep,
                totalSteps: totalSteps,
                activeColor: attributes.segmentActiveColor,
                inactiveColor: attributes.segmentInactiveColor
              )
            } else if let startDate = contentState.elapsedTimerStartDateInMilliseconds {
              let labelColor = attributes.progressViewLabelColor.map { Color(hex: $0) }
              if let endDate = contentState.elapsedTimerEndDateInMilliseconds {
                HStack(spacing: 4) {
                  ElapsedTimerText(startTimeMilliseconds: startDate, color: labelColor)
                  Text("/ \(formattedDuration(startMs: startDate, endMs: endDate))")
                    .foregroundStyle(labelColor ?? .primary)
                }
                .monospacedDigit()
                .font(.title3)
                .fontWeight(.medium)
              } else {
                ElapsedTimerText(startTimeMilliseconds: startDate, color: labelColor)
                  .font(.title3)
                  .fontWeight(.medium)
              }
            } else if let date = contentState.timerEndDateInMilliseconds {
              ProgressView(timerInterval: Date.toTimerInterval(miliseconds: date))
                .tint(progressViewTint)
                .modifier(ConditionalForegroundViewModifier(color: attributes.progressViewLabelColor))
            } else if let progress = contentState.progress {
              ProgressView(value: progress)
                .tint(progressViewTint)
                .modifier(ConditionalForegroundViewModifier(color: attributes.progressViewLabelColor))
            }
          }
        }.layoutPriority(1)

        if hasImage, !isLeftImage {
          if let imageName = contentState.imageName {
            alignedImage(imageName, .trailing, false)
          }
        }
      }

      if !effectiveStretch {
        if contentState.hasSegmentedProgress,
           let currentStep = contentState.currentStep,
           let totalSteps = contentState.totalSteps,
           totalSteps > 0
        {
          SegmentedProgressView(
            currentStep: currentStep,
            totalSteps: totalSteps,
            activeColor: attributes.segmentActiveColor,
            inactiveColor: attributes.segmentInactiveColor
          )
        } else if let startDate = contentState.elapsedTimerStartDateInMilliseconds {
          let labelColor = attributes.progressViewLabelColor.map { Color(hex: $0) }
          if let endDate = contentState.elapsedTimerEndDateInMilliseconds {
            let startD = Date(timeIntervalSince1970: startDate / 1000)
            let endD = Date(timeIntervalSince1970: endDate / 1000)
            HStack(spacing: 4) {
              ElapsedTimerText(startTimeMilliseconds: startDate, color: labelColor)
              Text("/ \(formattedDuration(startMs: startDate, endMs: endDate))")
                .foregroundStyle(labelColor ?? .primary)
            }
            .monospacedDigit()
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
            styledLinearProgressView(tint: progressViewTint, labelColor: attributes.progressViewLabelColor) {
              ProgressView(
                timerInterval: startD...endD,
                countsDown: false,
                label: { EmptyView() },
                currentValueLabel: { EmptyView() }
              )
            }
          } else {
            ElapsedTimerText(startTimeMilliseconds: startDate, color: labelColor)
              .font(.title2)
              .fontWeight(.semibold)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.top, 4)
          }
        } else if let date = contentState.timerEndDateInMilliseconds {
          ProgressView(timerInterval: Date.toTimerInterval(miliseconds: date))
            .tint(progressViewTint)
            .modifier(ConditionalForegroundViewModifier(color: attributes.progressViewLabelColor))
        } else if let progress = contentState.progress {
          ProgressView(value: progress)
            .tint(progressViewTint)
            .modifier(ConditionalForegroundViewModifier(color: attributes.progressViewLabelColor))
        }
      }
    }
    .padding(padding)
  }
}
