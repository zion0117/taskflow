//
//  ContentView.swift
//  TaskFlow
//
//  Created by suyeonkim on 3/19/26.
//

import SwiftUI
import SwiftData

// MARK: - Main Content View

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var items: [Item]

    @State private var showingAddTask = false
    @State private var newTaskTitle = ""

    var pendingItems: [Item] { items.filter { !$0.isCompleted } }
    var completedItems: [Item] { items.filter { $0.isCompleted } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // 날짜 헤더
                        DateHeaderView()
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        // 할 일 목록
                        if pendingItems.isEmpty && completedItems.isEmpty {
                            EmptyStateView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(pendingItems) { item in
                                    TaskRowView(item: item)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)

                            if !completedItems.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("완료됨")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.top, 24)
                                        .padding(.bottom, 8)

                                    VStack(spacing: 0) {
                                        ForEach(completedItems) { item in
                                            TaskRowView(item: item)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal, 16)
                                }
                            }
                        }

                        Spacer().frame(height: 100)
                    }
                }

                // 하단 추가 버튼
                AddTaskBar(
                    showingAddTask: $showingAddTask,
                    newTaskTitle: $newTaskTitle,
                    onAdd: addTask
                )
            }
            .navigationTitle("오늘")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        deleteCompletedTasks()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(completedItems.isEmpty ? Color.secondary : Color.blue)
                    }
                    .disabled(completedItems.isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            modelContext.insert(Item(title: trimmed))
            newTaskTitle = ""
            showingAddTask = false
        }
    }

    private func deleteCompletedTasks() {
        withAnimation {
            completedItems.forEach { modelContext.delete($0) }
        }
    }
}

// MARK: - Date Header

struct DateHeaderView: View {
    private var weekday: String {
        Date().formatted(.dateTime.weekday(.wide))
    }
    private var dateString: String {
        Date().formatted(.dateTime.month(.wide).day())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(weekday)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Text(dateString)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // 원형 체크박스
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    item.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(item.isCompleted ? Color.blue : Color(.systemGray3), lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            // 제목
            Text(item.title)
                .font(.body)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .strikethrough(item.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)

            // 삭제 버튼
            Button {
                withAnimation {
                    modelContext.delete(item)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray3))
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
        }
        .padding(.horizontal, 4)
        Divider()
            .padding(.leading, 42)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Color(.systemGray4))
            Text("오늘 할 일이 없어요")
                .font(.body)
                .foregroundStyle(.secondary)
            Text("아래 + 버튼으로 추가해보세요")
                .font(.footnote)
                .foregroundStyle(Color(.systemGray3))
        }
    }
}

// MARK: - Add Task Bar

struct AddTaskBar: View {
    @Binding var showingAddTask: Bool
    @Binding var newTaskTitle: String
    let onAdd: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if showingAddTask {
                HStack(spacing: 12) {
                    Circle()
                        .strokeBorder(Color(.systemGray3), lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    TextField("새로운 할 일", text: $newTaskTitle)
                        .font(.body)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit(onAdd)

                    Button(action: onAdd) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(newTaskTitle.isEmpty ? Color(.systemGray4) : Color.blue)
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(.systemBackground))
                .onAppear { isFocused = true }
            }

            Divider()

            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showingAddTask.toggle()
                        if !showingAddTask { newTaskTitle = "" }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showingAddTask ? "xmark" : "plus")
                            .font(.system(size: 16, weight: .semibold))
                        if !showingAddTask {
                            Text("새 할 일")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 4)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .shadow(color: .black.opacity(0.06), radius: 8, y: -4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
