import AppKit
import SwiftUI

class WindowController: NSWindowController {
  override func windowDidLoad() {
    super.windowDidLoad()
    window?.styleMask = [.borderless]
    window?.isMovableByWindowBackground = true
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApp.setActivationPolicy(.regular)
    NSApp.activate(ignoringOtherApps: true)
    NSApp.abortModal()
    let win = NSApp.windows.first
    win?.styleMask = [.borderless]
    win?.setContentSize(NSSize(width: 600, height: 600))
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
}

struct ContentView: View {
  var body: some View {
    VStack {
      Text("Triangle").bold()
      MetalView().frame(width: 500, height: 500)
      Button("Quit") {
        NSApplication.shared.terminate(self)
      }
      .keyboardShortcut("q")
    }
    .padding(10)
  }
}

struct MetalicImpl: App {

  init() {}

  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }.windowStyle(HiddenTitleBarWindowStyle())
  }
}

public class MetalicApp {
  required public init() {}

  public func run() {
    MetalicImpl.main()
  }

  public static func getInstance() -> Self {
    return Self()
  }

}
