import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate, FlutterPlugin {

    var windowController: NSWindowController!
    var window: NSWindow!
    var controllers: Dictionary<Int, (FlutterViewController, NSWindow)> = [:]
        
    @IBAction func newWindow(_ sender: Any) {
        createNewWindow(index: controllers.count)
    }
    
    @IBAction func closeLastWindow(_ sender: Any) {
        closeWindow(index: controllers.count - 1)
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        createNewWindow(index: 0, x: 0, y: 0, width: 1280, height: 720)
    }
    
    func createNewWindow(index: Int, x: Int = 700, y: Int = 200, width: Int = 500, height: Int = 500) {
         let flutterController = FlutterViewController.init()
         window = NSWindow()
         window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
         window.backingType = .buffered
         window.contentViewController = flutterController
         window.setFrame(NSRect(x: x, y: y, width: width, height: height), display: false)
         RegisterGeneratedPlugins(registry: flutterController)
     
         flutterController.registrar(forPlugin: "plugins.rive.app/window_controller")
         
         controllers[index] = (flutterController, window)
         windowController = NSWindowController()
         windowController.contentViewController = window.contentViewController
         windowController.window = window
         windowController.showWindow(self)
    }
     
    public static func register(with registrar: FlutterPluginRegistrar) {
       let channel = FlutterMethodChannel(
         name: "plugins.rive.app/window_controller",
         binaryMessenger: registrar.messenger
        )
       let instance = AppDelegate()
       registrar.addMethodCallDelegate(instance, channel: channel)
     }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          let args = call.arguments as? [String: Any]

          switch call.method {
          case "openWindow":
            let width: Int? = args?["width"] as? Int
            let height: Int? = args?["height"] as? Int
            let x: Int? = args?["x"] as? Int
            let y: Int? = args?["y"] as? Int
            let index: Int? = args?["index"] as? Int
            createNewWindow(
                index:index ?? controllers.count,
                x: x ?? 0,
                y: y ?? 0,
                width: width ?? 1280,
                height: height ?? 720
            )
            result(true)
          case "closeWindow":
             let index: Int? = args?["index"] as? Int
            closeWindow(index: index ?? controllers.count)
            result(true)
          default:
            result(FlutterMethodNotImplemented)
          }
    }
    
    func closeWindow(index: Int) {
        let controller = controllers[index]
        controller?.0.viewWillDisappear()
        controller?.1.close()
        controller?.0.viewDidDisappear()
    }
}
