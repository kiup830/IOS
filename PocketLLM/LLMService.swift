//
//  LLMService.swift
//  PocketLLM
//
//  Created by 문재현 on 2025/06/18.
//

import Foundation

class LLMService {
    static let shared = LLMService()

    private init() {}

    func runLLM(with text: String, completion: @escaping (String) -> Void) {
        guard let apiKey = loadAPIKey() else {
            completion("❌ API 키를 불러올 수 없습니다.")
            return
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",  // 또는 "gpt-4"
            "messages": [
                ["role": "user", "content": text]
            ],
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion("❌ 요청 본문 생성 실패: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("❌ 네트워크 오류: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion("❌ 데이터 없음")
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("❌ 응답 파싱 실패")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("❌ JSON 디코딩 실패: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    private func loadAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Secret", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENAI_API_KEY"] as? String else {
            return nil
        }
        return key
    }
}
