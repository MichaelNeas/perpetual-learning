import Foundation

enum APIError: Error {
    case invalidURL
    case requestError(error: Error)
    case noData
    case jsonDecodingError(error: Error)
    case imageError
}

enum Endpoint {
    case popular
    case topRated
    case upcoming
    case nowPlaying
    case trending
    case movieDetail(movie: Int)
    
    var path: String {
        switch self {
        case .popular:
            return "movie/popular"
        case .topRated:
            return "movie/top_rated"
        case .upcoming:
            return "movie/upcoming"
        case .nowPlaying:
            return "movie/now_playing"
        case .trending:
            return "trending/movie/day"
        case let .movieDetail(movie):
            return "movie/\(movie))"
        }
    }
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

func processRequest<T: Decodable>(_ validURL: URLRequest, _ completion: @escaping (Result<T, APIError>) -> Void) {
   let task = URLSession.shared.dataTask(with: validURL) { data, response, error in
       guard error == nil else { /* Handle errors */ return }
       guard let data = data else { /* Handle errors */ return }
       do {
           let object = try JSONDecoder().decode(T.self, from: data)
           completion(.success(object))
       } catch { /* Handle errors */ return }
   }
   task.resume()
}

func setupRequest(_ baseURL: URL, _ apiKey: String, _ method: HTTPMethod, _ endpoint: Endpoint, _ parameters: [String: String]?) -> URLRequest? {
    let queryURL = baseURL.appendingPathComponent(endpoint.path)
    var components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)!
    components.queryItems = [
        URLQueryItem(name: "api_key", value: apiKey),
        URLQueryItem(name: "language", value: Locale.preferredLanguages[0])
    ]
    parameters?.forEach { components.queryItems?.append(URLQueryItem(name: $0, value: $1)) }
    guard let validURL = components.url else { /* Handle errors */ return nil }
    var request = URLRequest(url: validURL)
    request.httpMethod = method.rawValue
    return request
}

struct AnyCodableResponse: Codable {}

let MovieAPI = { (baseURL: URL) in
    { (apiKey: String) in
        { (method: HTTPMethod) in
            { (endpoint: Endpoint) in
                { (params: [String: String]?) in
                    { (completion: (@escaping (Result<AnyCodableResponse, APIError>) -> Void)) in
                        processRequest(setupRequest(baseURL, apiKey, method, endpoint, params)!, completion)
                    }
                }
            }
        }
    }
}

let url = URL(string: "https://api.themoviedb.org/3")!
let apiKey = "06be028eff04f0991b1d67e9a1da3bf2"
let handler = { (result: Result<AnyCodableResponse, APIError>) in
    switch result {
    case .success(let response):
        print("handle \(response)")
    case .failure: print("Error handle the things")
    }
}

let getMovieRequests = MovieAPI(url)(apiKey)(.GET)
let topRatedMovies = getMovieRequests(.topRated)(nil)
topRatedMovies(handler)


