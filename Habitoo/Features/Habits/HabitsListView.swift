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
                Section {
                    HStack(spacing: 12) {
                        TextField("Nome do hábito", text: $newHabitName)
                            .textInputAutocapitalization(.words)
                        Button {
                            Task { await createHabit() }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                        }
                        .disabled(newHabitName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Novo hábito")
                }

                Section {
                    if loading && habits.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView().padding()
                            Spacer()
                        }
                    } else if habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 40, weight: .regular))
                                .foregroundStyle(.tertiary)
                            Text("Nenhum hábito ainda")
                                .font(.headline)
                            Text("Comece criando um hábito acima. Você pode editar depois.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(habits) { h in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(h.name).font(.headline)
                                Text(formatDate(h.createdAt))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            Task { await deleteHabits(at: indexSet) }
                        }
                    }
                } header: {
                    Text("Seus hábitos")
                } footer: {
                    if !habits.isEmpty {
                        Text("Dica: deslize um item para apagar")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
                withAnimation {
                    habits.insert(created, at: 0)
                }
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
                withAnimation {
                    habits.remove(at: index)
                }
            } catch {
                alertMsg = error.localizedDescription
            }
        }
    }

    func formatDate(_ isoString: String) -> String {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: isoString) {
            let f = DateFormatter()
            f.dateFormat = "dd/MM/yyyy HH:mm"
            return f.string(from: date)
        }
        return isoString
    }
}

#Preview {
    HabitsListView().environmentObject(AppSession())
}
