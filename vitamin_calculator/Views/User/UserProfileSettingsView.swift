//
//  UserProfileSettingsView.swift
//  vitamin_calculator
//
//  Created for Sprint 6 - Task 5.2
//

import SwiftUI
import SwiftData

/// View for editing user profile settings and viewing personalized recommendations.
struct UserProfileSettingsView: View {
    @State private var viewModel: UserProfileViewModel

    init(userRepository: UserRepository, recommendationService: RecommendationService) {
        self._viewModel = State(initialValue: UserProfileViewModel(
            userRepository: userRepository,
            recommendationService: recommendationService
        ))
    }

    var body: some View {
        Form {
            // Basic Information Section
            Section("基本信息") {
                TextField("姓名", text: $viewModel.name)

                Picker("用户类型", selection: $viewModel.userType) {
                    Text("成年男性").tag(UserType.male)
                    Text("成年女性").tag(UserType.female)
                    Text("儿童").tag(UserType.child(age: 10))
                }
                .onChange(of: viewModel.userType) {
                    // If changed to child and no birthDate, set default
                    if case .child = viewModel.userType, viewModel.birthDate == nil {
                        viewModel.birthDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
                    }
                }
            }

            // Age Section (for children)
            if case .child = viewModel.userType {
                Section("年龄") {
                    DatePicker(
                        "出生日期",
                        selection: Binding(
                            get: { viewModel.birthDate ?? Date() },
                            set: { viewModel.birthDate = $0 }
                        ),
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }
            }

            // Special Needs Section
            Section("特殊需求") {
                Picker("特殊需求", selection: $viewModel.specialNeeds) {
                    ForEach(SpecialNeeds.allCases, id: \.self) { need in
                        Text(need.rawValue).tag(need)
                    }
                }

                if viewModel.specialNeeds != .none {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)

                        Text("推荐值将根据您的特殊需求调整")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Recommendations Section
            Section("我的推荐值") {
                if viewModel.userProfile != nil && !viewModel.recommendations.isEmpty {
                    NavigationLink {
                        RecommendationsListView(
                            recommendations: viewModel.recommendations,
                            userProfile: viewModel.userProfile!
                        )
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                            Text("查看我的营养推荐值")
                            Spacer()
                            Text("\(viewModel.recommendations.count) 项")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                } else {
                    Text("保存个人资料后即可查看推荐值")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // Save Confirmation
            if viewModel.isSaved {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("更改已保存")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .navigationTitle("个人资料")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isLoading ? "" : "保存") {
                    Task {
                        await viewModel.saveProfile()
                    }
                }
                .disabled(viewModel.isLoading || viewModel.name.isEmpty)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let context = ModelContext(container)

    let userRepository = UserRepository(modelContext: context)
    let recommendationService = RecommendationService()

    NavigationStack {
        UserProfileSettingsView(
            userRepository: userRepository,
            recommendationService: recommendationService
        )
    }
}
