//
//  HabitsAPI.swift
//  Habitoo
//
//  Created by Pedro Juan Ferreira Saraiva on 04/09/25.
//

import Foundation

struct HabitDTO: Decodable, Identifiable {
    let id: Int64
    let name: String
    let createdAt: String
}

enum HabitsAPIError: Error {
    case noToken
    case badStatus(Int)
}

final class HabitsAPI {
    static func fetchHabits(token: String) async throws -> [HabitDTO] {
        guard let url = URL(string: "http://127.0.0.1:8080/habits") else { return [] }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { return [] }
        guard http.statusCode == 200 else { throw HabitsAPIError.badStatus(http.statusCode) }

        return try JSONDecoder().decode([HabitDTO].self, from: data)
    }
}
