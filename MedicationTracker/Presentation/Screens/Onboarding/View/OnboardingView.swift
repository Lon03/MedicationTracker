//
//  OnboardingView.swift
//  MedicationTracker
//
//  Created by Mike on 19.08.2026.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            TabView(selection: $viewModel.page) {
                ForEach(OnboardingPage.allCases) { page in
                    OnboardingPageView(
                        symbolName: page.symbolName,
                        title: page.title,
                        message: page.message
                    )
                    .tag(page)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .tint(AppTheme.Colors.accent)

            actions
                .screenPadding()
                .padding(.bottom, AppTheme.Spacing.large)
        }
        .background(AppTheme.Colors.screenBackground)
    }

    private var actions: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Button {
                if viewModel.state.isLastPage {
                    viewModel.handle(.enableReminders)
                } else {
                    withAnimation(AppTheme.Motion.onboardingPage) {
                        viewModel.handle(.next)
                    }
                }
            } label: {
                Text(primaryActionTitle)
                    .contentTransition(.opacity)
            }
            .buttonStyle(.primary)
            .disabled(viewModel.state.isRequestingPermission)

            if viewModel.state.isLastPage {
                Button { viewModel.handle(.notNow) } label: {
                    Text(.onboardingNotNow)
                }
                .buttonStyle(.secondary)
                .disabled(viewModel.state.isRequestingPermission)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(
            AppTheme.Motion.onboardingActions,
            value: viewModel.state.isLastPage
        )
    }

    private var primaryActionTitle: LocalizedStringResource {
        viewModel.state.isLastPage ? .onboardingEnable : .onboardingContinue
    }
}
