import Foundation
import SwiftSoup
import MobileCoreServices

class Session {
    private var session: URLSession = URLSession.shared

    init() {
        self.session.configuration.httpCookieAcceptPolicy = .always
    }

    func get(url: String, result: @escaping (String)->()) {
        let task = session.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                result("")
                return
            }
            guard (200 ... 299) ~= response.statusCode else {
                return
            }
            result(String(data: data, encoding: .utf8) ?? "")
        })
        task.resume()
    }

    func post(url: String, data: [String:String], result: @escaping (String)->()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data.percentEncoded()

        let task = self.session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                      result("")
                return
            }
            guard (200 ... 299) ~= response.statusCode else {
                result("")
                return
            }
            result(String(data: data, encoding: .utf8) ?? "")
        }
        task.resume()
    }

    func multiPartRequest(url: String, fileFieldName: String, fileUrl: String, data: [String:String], result: @escaping (String)->()) {
        do {
            let boundary = self.generateBoundaryString()
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = try self.createBody(with: newData, filePathKey: fileFieldName, paths: [fileUrl], boundary: boundary)

            let task = self.session.dataTask(with: request) { (addData, response, error) in
                guard let data = addData, let response = response as? HTTPURLResponse, error == nil else {
                    result("")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    result("")
                    return
                }
                result(String(data: data, encoding: .utf8) ?? "")
            }
            task.resume()
        } catch {
            result("")
        }
    }

    private func createBody(with parameters: [String: String]?, filePathKey: String, paths: [String], boundary: String) throws -> Data {
        var body = Data()

        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }

        for path in paths {
            let url = URL(fileURLWithPath: path)
            let filename = url.lastPathComponent
            let data = try Data(contentsOf: url)
            let mimetype = mimeType(for: path)

            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }


    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

    private func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            if escapedValue != "" {
                return escapedKey + "=" + escapedValue
            }
            else {
                return escapedKey
            }
        }.joined(separator: "&").data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}