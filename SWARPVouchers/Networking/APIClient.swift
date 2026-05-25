import Foundation

protocol APIClient {
    func login(email: String, password: String) async throws -> UserSession
    func register(email: String, name: String) async throws -> UserSession
    func catalog() async throws -> [VoucherProduct]
    func orders() async throws -> [VoucherOrder]
    func receipt(id: String) async throws -> Receipt
    func claimPreview(linkValue: String) async throws -> ClaimPreview
    func submitSupport(_ draft: SupportTicketDraft) async throws -> String
    func metrics() async throws -> [DashboardMetric]
}

final class URLSessionAPIClient: APIClient {
    private let config: EnvironmentConfig
    private let session: URLSession

    init(config: EnvironmentConfig = .localDemo, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func login(email: String, password: String) async throws -> UserSession {
        try await request(path: "/auth/login", method: "POST", body: ["email": email])
    }

    func register(email: String, name: String) async throws -> UserSession {
        try await request(path: "/auth/register", method: "POST", body: ["email": email, "name": name])
    }

    func catalog() async throws -> [VoucherProduct] {
        try await request(path: "/gift-shop/products", method: "GET", body: Optional<String>.none)
    }

    func orders() async throws -> [VoucherOrder] {
        try await request(path: "/gift-shop/orders", method: "GET", body: Optional<String>.none)
    }

    func receipt(id: String) async throws -> Receipt {
        try await request(path: "/gift-shop/receipts/\(id)", method: "GET", body: Optional<String>.none)
    }

    func claimPreview(linkValue: String) async throws -> ClaimPreview {
        try await request(path: "/public/claim-preview", method: "POST", body: ["linkValue": linkValue])
    }

    func submitSupport(_ draft: SupportTicketDraft) async throws -> String {
        let response: [String: String] = try await request(path: "/support/public-intake", method: "POST", body: draft)
        return response["id"] ?? "submitted"
    }

    func metrics() async throws -> [DashboardMetric] {
        try await request(path: "/demo/metrics", method: "GET", body: Optional<String>.none)
    }

    private func request<Response: Decodable, Body: Encodable>(path: String, method: String, body: Body?) async throws -> Response {
        var request = URLRequest(url: config.apiBaseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw SafeUIError.unavailable
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw SafeUIError.invalidResponse
        }
    }
}
