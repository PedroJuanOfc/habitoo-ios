//
//  LoginView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 01/09/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var token: String?
    @State private var resultText = ""
    @State private var showingAlert = false

    var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Acesso") {
                    TextField("E-mail", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Senha", text: $password)
                        .textContentType(.password)
                }

                Section {
                    Button("Entrar") {
                        Task { await login() }
                    }
                    .disabled(!isFormValid)
                }

            }
            .navigationTitle("Habitoo — Login")
            .alert("Resposta", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(resultText)
            }
        }
    }

    func login() async {
        guard let url = URL(string: "http://localhost:8080/auth/login") else { return }
        let body: [String: Any] = ["email": email, "password": password]
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = data

            let (respData, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return }
            if http.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: respData) as? [String: Any],
               let tok = json["token"] as? String {
                token = tok
                resultText = "Login OK"
            } else {
                resultText = "Falha no login (\(http.statusCode))"
            }
        } catch {
            resultText = "Erro: \(error.localizedDescription)"
        }
        showingAlert = true
    }

    func fetchMe() async {
        guard let token, let url = URL(string: "http://localhost:8080/me") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { return }
            if http.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                resultText = "me: \(json)"
            } else {
                resultText = "Falha no /me (\(http.statusCode))"
            }
        } catch {
            resultText = "Erro: \(error.localizedDescription)"
        }
        showingAlert = true
    }
}

#Preview { LoginView() }
