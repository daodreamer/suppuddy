//
//  ContentView.swift
//  vitamin_calculator
//
//  Created by Jiongdao Wang on 25.01.26.
//

import SwiftUI
import SwiftData

/// Main content view with tab-based navigation
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab
            DashboardView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)

            // Intake Record tab
            IntakeRecordView()
                .tabItem {
                    Label("记录", systemImage: "plus.circle.fill")
                }
                .tag(1)

            // Supplements tab
            SupplementListView()
                .tabItem {
                    Label("补剂", systemImage: "pills.fill")
                }
                .tag(2)

            // History tab
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "calendar")
                }
                .tag(3)

            // Profile tab
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

/// Profile view for user settings
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userProfile: UserProfile?

    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    if let profile = userProfile {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(userTypeDisplayName(profile.userType))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("未设置用户")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("点击设置个人信息")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // Settings Section
                Section("设置") {
                    NavigationLink {
                        let userRepository = UserRepository(modelContext: modelContext)
                        let recommendationService = RecommendationService()
                        UserProfileSettingsView(
                            userRepository: userRepository,
                            recommendationService: recommendationService
                        )
                    } label: {
                        Label("个人资料", systemImage: "person")
                    }
                }

                // Data Section
                Section("数据") {
                    NavigationLink {
                        let userRepository = UserRepository(modelContext: modelContext)
                        let supplementRepository = SupplementRepository(modelContext: modelContext)
                        let intakeRepository = IntakeRecordRepository(modelContext: modelContext)

                        let exportService = DataExportService(
                            userRepository: userRepository,
                            supplementRepository: supplementRepository,
                            intakeRepository: intakeRepository
                        )
                        let importService = DataImportService(
                            userRepository: userRepository,
                            supplementRepository: supplementRepository,
                            intakeRepository: intakeRepository
                        )

                        DataManagementView(
                            exportService: exportService,
                            importService: importService
                        )
                    } label: {
                        Label("数据管理", systemImage: "square.and.arrow.up.on.square")
                    }
                }

                // Stats Section
                Section("统计信息") {
                    StatRow(label: "总补剂数", value: supplementCount)
                    StatRow(label: "总记录数", value: recordCount)
                }

                // About Section
                Section("关于") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("关于", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("我的")
            .task {
                loadUserProfile()
            }
        }
    }

    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
    }

    private func userTypeDisplayName(_ userType: UserType) -> String {
        switch userType {
        case .male:
            return "成年男性"
        case .female:
            return "成年女性"
        case .child(let age):
            return "儿童 (\(age)岁)"
        }
    }

    private var supplementCount: String {
        let descriptor = FetchDescriptor<Supplement>()
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        return "\(count)"
    }

    private var recordCount: String {
        let descriptor = FetchDescriptor<IntakeRecord>()
        let count = (try? modelContext.fetch(descriptor).count) ?? 0
        return "\(count)"
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "pill.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        Text("Vitamin Calculator")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }

            Section("关于") {
                Text("Vitamin Calculator 帮助您追踪每日营养素摄入，基于德国营养学会 (DGE) 推荐值提供健康建议。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("数据来源") {
                Link(destination: URL(string: "https://www.dge.de/wissenschaft/referenzwerte/")!) {
                    HStack {
                        Text("DGE 参考值")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
