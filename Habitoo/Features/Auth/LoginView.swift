//
//  LoginView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 01/09/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: AppSession
    @State private var email = ""
    @State private var password = ""
    @State private var resultText = ""
    @State private var showingAlert = false

    var onTapRegister: () -> Void = {}

    var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Login")
                .font(.largeTitle).bold()

            CardContainer {
                FormField(title: "E-mail", text: $email, kind: .email)
                FormField(title: "Senha", text: $password, kind: .secure)

                PrimaryButton(title: "Entrar", enabled: isFormValid) {
                    Task { await login() }
                }
            }
            .padding(.top, 8)

            HStack(spacing: 6) {
                Text("Ainda não possui conta?")
                    .foregroundStyle(.secondary)
                Button("Cadastrar") { onTapRegister() }
                    .fontWeight(.semibold)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .alert("Resposta", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultText)
        }
    }

    func login() async {
        guard let url = URL(string: "http://127.0.0.1:8080/auth/login") else { return }
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
                session.token = tok
                resultText = "Login OK"
            } else {
                resultText = "Falha no login (\(http.statusCode))"
            }
        } catch {
            resultText = "Erro: \(error.localizedDescription)"
        }
        showingAlert = true
    }
}

#Preview { LoginView().environmentObject(AppSession()) }
