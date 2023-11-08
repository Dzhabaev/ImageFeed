//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Chingiz on 04.10.2023.
//

import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data, let response = response as? HTTPURLResponse {
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(T.self, from: data)
                            completion(.success(result))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        if let errorMessage = String(data: data, encoding: .utf8) {
                            print("Ошибка данных ответа: \(errorMessage)")
                        } else {
                            print("Не удалось декодировать данные ошибки.")
                        }
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                } else {
                    completion(.failure(NetworkError.urlSessionError))
                }
            }
        }
        task.resume()
        return task
    }
}
