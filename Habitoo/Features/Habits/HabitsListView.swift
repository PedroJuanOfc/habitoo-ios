//
//  HabitsListView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 04/09/25.
//

import SwiftUI

struct HabitsListView: View {
    @EnvironmentObject private var session: AppSession
    @State private var habits: [HabitDTO] = []
    @State private var loading = false
    @State private var alertMsg: String?
    @State private var newHabitName: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Novo hábito") {
                    HStack {
                        TextField("Nome do hábito", text: $newHabitName)
                        Button("Adicionar") {
                            Task { await createHabit() }
                        }
                        .disabled(newHabitName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Seus hábitos") {
                    if loading && habits.isEmpty {
                        ProgressView()
                    } else if habits.isEmpty {
                        Text("Nenhum hábito ainda.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(habits) { h in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(h.name).font(.headline)
                                Text(h.createdAt).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            Task { await deleteHabits(at: indexSet) }
                        }
                    }
                }
            }
            .navigationTitle("Hábitos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await load() }
                    } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .task { await load() }
            .alert("Aviso", isPresented: .constant(alertMsg != nil)) {
                Button("OK") { alertMsg = nil }
            } message: {
                Text(alertMsg ?? "")
            }
        }
    }

    func load() async {
        guard let token = session.token else { alertMsg = "Faça login."; return }
        loading = true
        defer { loading = false }
        do {
            habits = try await HabitsAPI.fetchHabits(token: token)
        } catch HabitsAPIError.badStatus(let code) {
            alertMsg = "Erro ao buscar hábitos (\(code))"
        } catch {
            alertMsg = error.localizedDescription
        }
    }

    func createHabit() async {
        let name = newHabitName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        guard let token = session.token,
              let url = URL(string: "http://127.0.0.1:8080/habits") else { return }

        do {
            let body: [String: Any] = ["name": name]
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            req.httpBody = data

            let (respData, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return }
            guard http.statusCode == 201 else { alertMsg = "Falha ao criar (\(http.statusCode))"; return }

            if let created = try? JSONDecoder().decode(HabitDTO.self, from: respData) {
                habits.insert(created, at: 0)
            } else {
                await load()
            }
            newHabitName = ""
        } catch {
            alertMsg = error.localizedDescription
        }
    }

    func deleteHabits(at indexSet: IndexSet) async {
        guard let token = session.token else { return }
        for index in indexSet {
            let h = habits[index]
            guard let url = URL(string: "http://127.0.0.1:8080/habits/\(h.id)") else { continue }
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                guard let http = resp as? HTTPURLResponse, http.statusCode == 204 else {
                    alertMsg = "Falha ao deletar"
                    continue
                }
                habits.remove(at: index)
            } catch {
                alertMsg = error.localizedDescription
            }
        }
    }
}

#Preview {
    HabitsListView().environmentObject(AppSession())
}
