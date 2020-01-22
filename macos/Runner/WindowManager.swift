//
//  WindowManager.swift
//  Runner
//
//  Created by Rody Davis on 1/22/20.
//  Copyright © 2020 The Flutter Authors. All rights reserved.
//

import Foundation
import FlutterMacOS
import WebKit

class WindowManagerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channelName = "window_controller"
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger)
        let instance = WindowManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "openWebView":
            let args = call.arguments as? [String: Any]
            let width: Int? = args?["width"] as? Int
            let height: Int? = args?["height"] as? Int
            let x: Double? = args?["x"] as? Double
            let y: Double? = args?["y"] as? Double
            let key: String = args?["key"] as! String
            let url: String = args?["url"] as! String
            let jsHandler: String = args?["jsMessage"] as! String
            createWebWindow(
                key: key,
                url: url,
                jsMessage: jsHandler,
                x: x,
                y: y,
                width: width,
                height: height,
                result: result
            )
            break
        case "createWindow":
            let args = call.arguments as? [String: Any]
            let width: Int? = args?["width"] as? Int
            let height: Int? = args?["height"] as? Int
            let x: Double? = args?["x"] as? Double
            let y: Double? = args?["y"] as? Double
            let key: String = args?["key"] as! String
            createNewWindow(
                key: key,
                x: x,
                y: y,
                width: width,
                height: height
            )
            result(true)
            break
        case "closeWebView":
            let args = call.arguments as? [String: Any]
            let key: String! = args?["key"] as? String
            result(closeWindow(_key: key))
            break
        case "closeWindow":
            let args = call.arguments as? [String: Any]
            let key: String! = args?["key"] as? String
            result(closeWindow(_key: key))
            break
        case "windowCount":
            result(NSApp.windows.count)
            break
        case "keyIndex":
            let args = call.arguments as? [String: Any]
            let _key: String? = args?["key"] as? String
            let index = NSApp.windows.firstIndex(where: { $0.title == _key })
            result(index ?? 0)
            break
        case "getWindowStats":
            let args = call.arguments as? [String: Any]
            let _key: String? = args?["key"] as? String
            let window = NSApp.windows.first(where: { $0.title == _key })
            let screen = window?.frame
            let origin = screen?.origin
            let size = screen?.size
            var _args: [String: Any?] = [:]
            _args["offsetX"] = Double(origin!.x)
            _args["offsetY"] = Double(origin!.y)
            _args["width"] = Double(size!.width)
            _args["height"] = Double(size!.height)
            result(_args)
        case "moveWindow":
            let args = call.arguments as? [String: Any]
            let _key: String? = args?["key"] as? String
            let x: Double = args?["x"] as! Double
            let y: Double = args?["y"] as! Double
            let window = NSApp.windows.first(where: { $0.title == _key })
            window?.setFrameOrigin(NSPoint(x: x, y: y))
            result(true)
        case "resizeWindow":
            let args = call.arguments as? [String: Any]
            let _key: String? = args?["key"] as? String
            let width: Double = args?["width"] as! Double
            let height: Double = args?["height"] as! Double
            let window = NSApp.windows.first(where: { $0.title == _key })
            window?.setContentSize(NSSize(width: width, height: height))
            result(true)
        case "lastWindowKey":
            let window = NSApp.windows.last
            let _instanceKey = window?.title;
            result(_instanceKey)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func createNewWindow(key: String, x: Double? = nil, y: Double? = nil, width: Int? = nil, height: Int? = nil) {
        let flutterController = FlutterViewController.init()
        let window = NSWindow()
        window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
        window.backingType = .buffered
        RegisterGeneratedPlugins(registry: flutterController)
        WindowManagerPlugin.register(with: flutterController.registrar(forPlugin: "WindowManagerPlugin"))
        window.contentViewController = flutterController
        if let screen = window.screen {
            let screenRect = screen.visibleFrame
            let newWidth = width ?? Int(screenRect.maxX / 2)
            let newHeight = height ?? Int(screenRect.maxY / 2)
            var newOriginX: CGFloat = (screenRect.maxX / 2) - CGFloat(Double(newWidth) / 2)
            var newOriginY: CGFloat = (screenRect.maxY / 2) - CGFloat(Double(newHeight) / 2)
            if (x != nil) { newOriginX = CGFloat(x!) }
            if (y != nil) { newOriginY = CGFloat(y!) }
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
            window.setContentSize(NSSize(width: newWidth, height: newHeight))
        }
        window.title = key;
        window.titleVisibility = .hidden
        let windowController = NSWindowController()
        windowController.contentViewController = window.contentViewController
        windowController.shouldCascadeWindows = true
        windowController.window = window
        windowController.showWindow(self)
    }

    func createWebWindow(key: String, url: String, jsMessage: String, x: Double? = nil, y: Double? = nil, width: Int? = nil, height: Int? = nil, result: @escaping FlutterResult) {
        let window = NSWindow()
        window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
        window.backingType = .buffered
        let _auth = FullScreenWebView()
        _auth.url = url
        _auth.jsHandler = jsMessage
        if (jsMessage != "") {
            _auth.jsResponse = { (message: Any) -> Void in
                result(message)
            }
        } else {
            result("\(key) created")
        }
        window.contentViewController = _auth
        if let screen = window.screen {
            let screenRect = screen.visibleFrame
            let newWidth = width ?? Int(screenRect.maxX / 2)
            let newHeight = height ?? Int(screenRect.maxY / 2)
            var newOriginX: CGFloat = (screenRect.maxX / 2) - CGFloat(Double(newWidth) / 2)
            var newOriginY: CGFloat = (screenRect.maxY / 2) - CGFloat(Double(newHeight) / 2)
            if (x != nil) { newOriginX = CGFloat(x!) }
            if (y != nil) { newOriginY = CGFloat(y!) }
            window.setFrameOrigin(NSPoint(x: newOriginX, y: newOriginY))
            window.setContentSize(NSSize(width: newWidth, height: newHeight))
        }
        window.title = key;
        window.titleVisibility = .hidden
        let windowController = NSWindowController()
        windowController.contentViewController = window.contentViewController
        windowController.shouldCascadeWindows = true
        windowController.window = window
        windowController.showWindow(self)
    }

    func closeWindow(_key: String) -> Bool {
        let window = NSApp.windows.first(where: { $0.title == _key })
        window?.close()
        return true
    }
}

class FullScreenWebView: NSViewController, WKUIDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var url = "https://www.apple.com"
    var jsHandler: String = ""
    var jsResponse: (Any?) -> Void? = { (message: Any) -> Void in
        print(message)
    }

    override func loadView() {
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.uiDelegate = self
        if (jsHandler != "") {
            webView.configuration.userContentController.add(self, name: jsHandler)
        }
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == jsHandler {
            let val = message.body
            jsResponse(val)
        }
    }
}
