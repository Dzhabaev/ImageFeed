//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Chingiz on 22.11.2023.
//

@testable import ImageFeed
import Foundation
import XCTest

// MARK: - WebViewTests

final class WebViewTests: XCTestCase {
    
    let webViewViewController = WebViewViewController()
    
    // Тест проверяет, что метод viewDidLoad вызывается при загрузке контроллера.
    func testViewControllerCallsViewDidLoad() {
        // Готовим объекты для теста.
        let webViewViewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        webViewViewController.presenter = presenter
        presenter.view = webViewViewController
        
        // Вызываем view для загрузки ViewController.
        _ = webViewViewController.view
        
        // Проверяем, что метод viewDidLoad был вызван.
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    // Тест проверяет, что метод viewDidLoad в презентере вызывает загрузку запроса.
    func testPresenterCallsLoadRequest() {
        // Готовим объекты для теста.
        let webViewViewControllerSpy = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        webViewViewControllerSpy.presenter = presenter
        presenter.view = webViewViewControllerSpy
        
        // Вызываем метод viewDidLoad в презентере.
        presenter.viewDidLoad()
        
        // Проверяем, что был вызван метод загрузки запроса в контроллере.
        XCTAssertTrue(webViewViewControllerSpy.loadRequestCalled)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authorizeURL))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
}

// MARK: - WebViewPresenterSpy
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

// MARK: - WebViewViewControllerSpy
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
