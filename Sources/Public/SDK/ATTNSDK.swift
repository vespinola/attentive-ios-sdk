//
//  ATTNSDK.swift
//  attentive-ios-sdk-framework
//
//  Created by Vladimir - Work on 2024-05-27.
//

import Foundation
import WebKit

public typealias ATTNCreativeTriggerCompletionHandler = (String) -> Void

@objc(ATTNSDK)
public final class ATTNSDK: NSObject {
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

  private(set) var api: ATTNAPIProtocol
  private(set) var userIdentity: ATTNUserIdentity

  private var domain: String
  private var mode: ATTNSDKMode
  private var urlBuilder: ATTNCreativeUrlProviding = ATTNCreativeUrlProvider()

  /// Determinates if fatigue rules evaluation will be skipped for Creative. Default value is false.
  @objc public var skipFatigueOnCreative: Bool = false

  public init(domain: String, mode: ATTNSDKMode) {
    Loggers.creative.trace("Init ATTNSDKFramework v\(ATTNConstants.sdkVersion), Mode: \(mode.rawValue), Domain: \(domain)")

    self.domain = domain
    self.mode = mode

    self.userIdentity = .init()
    self.api = ATTNAPI(domain: domain)

    super.init()

    self.sendInfoEvent()
    self.initializeSkipFatigueOnCreatives()
  }

  @objc(initWithDomain:)
  public convenience init(domain: String) {
    self.init(domain: domain, mode: .production)
  }

  @available(swift, deprecated: 0.6, message: "Please use init(domain: String, mode: ATTNSDKMode) instead.")
  @objc(initWithDomain:mode:)
  public convenience init(domain: String, mode: String) {
    self.init(domain: domain, mode: ATTNSDKMode(rawValue: mode) ?? .production)
  }

  // MARK: Public API
  @objc(identify:)
  public func identify(_ userIdentifiers: [String: Any]) {
    userIdentity.mergeIdentifiers(userIdentifiers)
    api.send(userIdentity: userIdentity)
    Loggers.event.debug("Send User Identifiers: \(userIdentifiers)")
  }

  @objc(trigger:)
  public func trigger(_ view: UIView) {
    launchCreative(parentView: view)
  }

  @objc(trigger:handler:)
  public func trigger(_ view: UIView, handler: ATTNCreativeTriggerCompletionHandler?) {
    launchCreative(parentView: view, handler: handler)
  }

  @objc(trigger:creativeId:)
  public func trigger(_ view: UIView, creativeId: String) {
    launchCreative(parentView: view, creativeId: creativeId, handler: nil)
  }

  @objc(trigger:creativeId:handler:)
  public func trigger(_ view: UIView, creativeId: String, handler: ATTNCreativeTriggerCompletionHandler?) {
    launchCreative(parentView: view, creativeId: creativeId, handler: handler)
  }

  @objc(clearUser)
  public func clearUser() {
    userIdentity.clearUser()
    Loggers.creative.debug("Clear user. New visitor id: \(self.userIdentity.visitorId, privacy: .public)")
  }

  @objc(updateDomain:)
  public func update(domain: String) {
    guard self.domain != domain else { return }
    self.domain = domain
    api.update(domain: domain)
    Loggers.creative.trace("Updated SDK with new domain: \(domain)")
    api.send(userIdentity: userIdentity)
    Loggers.creative.trace("Retrigger Identity Event with new domain '\(domain)'")
  }
}

// MARK: Private Helpers
fileprivate extension ATTNSDK {
  func sendInfoEvent() {
    api.send(event: ATTNInfoEvent(), userIdentity: userIdentity)
  }

  func closeCreative() {
    webView?.removeFromSuperview()
    webView = nil
    ATTNSDK.isCreativeOpen = false
    triggerHandler?(ATTNCreativeTriggerStatus.closed)
    Loggers.creative.trace("Successfully closed creative")
  }

  func launchCreative(
    parentView view: UIView,
    creativeId: String? = nil,
    handler: ATTNCreativeTriggerCompletionHandler? = nil
  ) {
    parentView = view
    triggerHandler = handler

    Loggers.creative.trace("Called showWebView in creativeSDK with domain: \(self.domain, privacy: .public)")

    guard !ATTNSDK.isCreativeOpen else {
      Loggers.creative.trace("Attempted to trigger creative, but creative is currently open. Taking no action")
      return
    }

    guard #available(iOS 14, *) else {
      Loggers.creative.trace("Not showing the Attentive creative because the iOS version is too old.")
      triggerHandler?(ATTNCreativeTriggerStatus.notOpened)
      return
    }
    Loggers.creative.trace("The iOS version is new enough, continuing to show the Attentive creative.")

    let creativePageUrl = urlBuilder.buildCompanyCreativeUrl(
      configuration: ATTNCreativeUrlConfig(
        domain: domain,
        creativeId: creativeId,
        skipFatigue: skipFatigueOnCreative,
        mode: mode.rawValue,
        userIdentity: userIdentity
      )
    )

    Loggers.creative.trace("Requesting creative page url: \(creativePageUrl)" )

    guard let url = URL(string: creativePageUrl) else {
      Loggers.creative.trace("URL could not be created.")
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
}

// MARK: WKScriptMessageHandler
extension ATTNSDK: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    let messageBody = message.body as? String ?? ""
    Loggers.creative.trace("Web event message: \(messageBody). isCreativeOpen: \(ATTNSDK.isCreativeOpen ? "YES" : "NO")")

    if messageBody == "CLOSE" {
      closeCreative()
    } else if messageBody == "IMPRESSION" {
      Loggers.creative.trace("Creative opened and generated impression event")
      ATTNSDK.isCreativeOpen = true
    } else if messageBody == String(format: "%@ true", Constants.visibilityEvent), ATTNSDK.isCreativeOpen {
      Loggers.creative.trace("Nav away from creative, closing")
      closeCreative()
    }
  }
}

// MARK: WKNavigationDelegate
extension ATTNSDK: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard #available(iOS 14.0, *) else { return }
    let asyncJs =
        """
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
        return status;
        """
    webView.callAsyncJavaScript(
      asyncJs,
      in: nil,
      in: .defaultClient
    ) { [weak self] result in
      guard let self = self else { return }
      guard case let .success(statusAny) = result else {
        Loggers.creative.trace("No status returned from JS. Not showing WebView.")
        self.triggerHandler?(ATTNCreativeTriggerStatus.notOpened)
        return
      }

      switch ScriptStatus.getRawValue(from: statusAny) {
      case .success:
        Loggers.creative.trace("Found creative iframe, showing WebView.")
        if self.mode == .production {
          self.parentView?.addSubview(webView)
        }
        self.triggerHandler?(ATTNCreativeTriggerStatus.opened)
      case .timeout:
        Loggers.creative.error("Creative timed out. Not showing WebView.")
        self.triggerHandler?(ATTNCreativeTriggerStatus.notOpened)
      case .unknown(let statusString):
        Loggers.creative.error("Received unknown status: \(statusString). Not showing WebView")
        self.triggerHandler?(ATTNCreativeTriggerStatus.notOpened)
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

// MARK: Internal Helpers
extension ATTNSDK {
  convenience init(domain: String, mode: ATTNSDKMode, urlBuilder: ATTNCreativeUrlProviding) {
    self.init(domain: domain, mode: mode)
    self.urlBuilder = urlBuilder
  }

  convenience init(api: ATTNAPIProtocol, urlBuilder: ATTNCreativeUrlProviding? = nil) {
    self.init(domain: api.domain)
    self.api = api
    guard let urlBuilder = urlBuilder else { return }
    self.urlBuilder = urlBuilder
  }

  func getDomain() -> String {
    domain
  }
}
