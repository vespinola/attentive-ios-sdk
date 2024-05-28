//
//  ATTSDK.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-27.
//

import Foundation
import WebKit

/// Define initialization mode for SDK
public enum ATTSDKMode: String {
  case debug
  case production
}

public final class ATTSDK: NSObject {
  // MARK: Constants
  private enum Constants {
    static var visibilityEvent: String { "document-visibility:" }
    static var scriptMessageHandlerName: String { "log" }
  }

  private enum ScriptStatus {
    case success
    case timeout
    case unknown(String)

    static func getRawValue(from value: Any) -> ScriptStatus? {
      guard let stringValue = value as? String else { return nil }
      switch stringValue {
      case "SUCCESS":
        return .success
      case "TIMED OUT":
        return .timeout
      default:
        return .unknown(stringValue)
      }
    }
  }

  // MARK: Static Properties
  private static var isCreativeOpen = false

  // MARK: Instance Properties
  private var parentView: UIView?
  private var webView: WKWebView?
  private var triggerHandler: ATTNCreativeTriggerCompletionHandler?

  private let api: ATTNAPI
  private let userIdentity: ATTNUserIdentity

  private var domain: String
  private var mode: ATTSDKMode

  // MARK: Init
  convenience public init(domain: String, mode: ATTSDKMode = .production) {
    self.init(domain: domain, mode: mode.rawValue)
  }

  public init(domain: String, mode: String = "production") {
//    NSLog("init attentive_ios_sdk v%@", SDK_VERSION)
    self.domain = domain
    self.mode = ATTSDKMode(rawValue: mode) ?? .production

    self.userIdentity = .init()
    self.api = .init(domain: domain)

    super.init()

    self.sendInfoEvent()
  }

  // MARK: Public API
  public func identify(userIdentifiers: [String: String]) {
    userIdentity.mergeIdentifiers(userIdentifiers)
    api.send(userIdentity)
  }

  public func trigger(theView view: UIView, handler: ATTNCreativeTriggerCompletionHandler? = nil) {
    parentView = view
    triggerHandler = handler

    NSLog("Called showWebView in creativeSDK with domain: %@", domain)

    guard !ATTSDK.isCreativeOpen else {
      NSLog("Attempted to trigger creative, but creative is currently open. Taking no action")
      return
    }

    guard #available(iOS 14, *) else {
      NSLog("Not showing the Attentive creative because the iOS version is too old.")
      triggerHandler?(CREATIVE_TRIGGER_STATUS_NOT_OPENED)
      return
    }
    NSLog("The iOS version is new enough, continuing to show the Attentive creative.")

    let creativePageUrl = ATTNCreativeUrlFormatter.buildCompanyCreativeUrl(
      forDomain: domain,
      mode: mode.rawValue,
      userIdentity: userIdentity
    )

    NSLog("Requesting creative page url: %@", creativePageUrl)

    guard let url = URL(string: creativePageUrl) else {
      NSLog("URL could not be created.")
      return
    }

    let request = URLRequest(url: url)

    let configuration = WKWebViewConfiguration()
    configuration.userContentController.add(self, name: Constants.scriptMessageHandlerName)

    let userScriptWithEventListener = String(format: "window.addEventListener('message', (event) => {if (event.data && event.data.__attentive) {window.webkit.messageHandlers.log.postMessage(event.data.__attentive.action);}}, false);window.addEventListener('visibilitychange', (event) => {window.webkit.messageHandlers.log.postMessage(`%@ ${document.hidden}`);}, false);", Constants.visibilityEvent)
    let userScript = WKUserScript(source: userScriptWithEventListener, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    configuration.userContentController.addUserScript(userScript)

    webView = WKWebView(frame: view.frame, configuration: configuration)

    guard let webView = webView else { return }

    webView.navigationDelegate = self
    webView.load(request)

    if mode == .debug {
      parentView?.addSubview(webView)
    } else {
      webView.isOpaque = false
      webView.backgroundColor = .clear
    }
  }

  public func clearUser() {
    userIdentity.clearUser()
  }

  public func closeCreative() {
    webView?.removeFromSuperview()
    ATTSDK.isCreativeOpen = false
    triggerHandler?(CREATIVE_TRIGGER_STATUS_CLOSED)
    NSLog("Successfully closed creative")
  }
}

// MARK: Private Helpers
fileprivate extension ATTSDK {
  func sendInfoEvent() {
    api.send(ATTNInfoEvent(), userIdentity: userIdentity)
  }
}

// MARK: WKScriptMessageHandler
extension ATTSDK: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    let messageBody = message.body as? String ?? ""
    NSLog("Web event message: %@. isCreativeOpen: %@", messageBody, ATTSDK.isCreativeOpen ? "YES" : "NO")

    if messageBody == "CLOSE" {
      closeCreative()
    } else if messageBody == "IMPRESSION" {
      NSLog("Creative opened and generated impression event")
      ATTSDK.isCreativeOpen = true
    } else if messageBody == String(format: "%@ true", Constants.visibilityEvent), ATTSDK.isCreativeOpen {
      NSLog("Nav away from creative, closing")
      closeCreative()
    }
  }
}

// MARK: WKNavigationDelegate
extension ATTSDK: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let asyncJs = """
      var p = new Promise(resolve => {
          var timeoutHandle = null;
          const interval = setInterval(function() {
              e = document.querySelector('iframe');
              if(e && e.id === 'attentive_creative') {
                  clearInterval(interval);
                  resolve('SUCCESS');
                  if (timeoutHandle != null) {
                      clearTimeout(timeoutHandle);
                  }
              }
          }, 100);
          timeoutHandle = setTimeout(function() {
              clearInterval(interval);
              resolve('TIMED OUT');
          }, 5000);
      });
      var status = await p;
      status;
    """

    guard #available(iOS 14.0, *) else { return }

    webView.callAsyncJavaScript(asyncJs, in: nil, in: .defaultClient) { [weak self] result in
      guard let self = self else { return }
      guard case let .success(statusAny) = result else {
        NSLog("No status returned from JS. Not showing WebView.")
        self.triggerHandler?(CREATIVE_TRIGGER_STATUS_NOT_OPENED)
        return
      }

      switch ScriptStatus.getRawValue(from: statusAny) {
      case .success:
        NSLog("Found creative iframe, showing WebView.")
        if self.mode == .production {
          self.parentView?.addSubview(webView)
        }
        self.triggerHandler?(CREATIVE_TRIGGER_STATUS_OPENED)
      case .timeout:
        NSLog("Creative timed out. Not showing WebView.")
        self.triggerHandler?(CREATIVE_TRIGGER_STATUS_NOT_OPENED)
      case .unknown(let statusString):
        NSLog("Received unknown status: %@. Not showing WebView", statusString)
        self.triggerHandler?(CREATIVE_TRIGGER_STATUS_NOT_OPENED)
      default: break
      }
    }
  }

  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }

    if url.scheme == "sms" {
      UIApplication.shared.open(url)
      decisionHandler(.cancel)
    } else if let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
      if navigationAction.targetFrame == nil {
        UIApplication.shared.open(url)
        decisionHandler(.cancel)
      } else {
        decisionHandler(.allow)
      }
    } else {
      decisionHandler(.allow)
    }
  }
}
