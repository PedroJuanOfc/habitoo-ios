//
//  AuthView.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 01/09/25.
//

import SwiftUI

enum AuthMode: String, CaseIterable {
    case login = "Entrar"
    case register = "Registrar"
}

struct AuthView: View {
    @EnvironmentObject private var session: AppSession
    @State private var mode: AuthMode = .login

    var body: some View {
        if session.token != nil {
            HabitsListView()
        } else {
            NavigationStack {
                VStack {
                    Picker("Modo", selection: $mode) {
                        ForEach(AuthMode.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    Group {
                        switch mode {
                        case .login:
                            LoginView()
                        case .register:
                            RegisterView()
                        }
                    }
                    .animation(.easeInOut, value: mode)
                }
                .navigationTitle("Habitoo")
            }
        }
    }
}

#Preview {
    AuthView().environmentObject(AppSession())
}
