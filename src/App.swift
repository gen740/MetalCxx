import AppKit
import SwiftUI

class WindowController: NSWindowController {
  override func windowDidLoad() {
    super.windowDidLoad()
    window?.styleMask = [.borderless]  // すべてのウィンドウ装飾を削除
    window?.isMovableByWindowBackground = true  // ウィンドウを背景で移動可能に
  }
}

// 以下を追加する
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApp.setActivationPolicy(.regular)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // アプリケーション終了時の処理
  }
}

struct ContentView: View {
  var body: some View {
    VStack {
      Text("Triangle").bold()
      MetalView()
    }
    .padding(10)
  }
}

struct CxxApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var body: some Scene {
    WindowGroup {
      ContentView()
    }.windowStyle(HiddenTitleBarWindowStyle())
  }
}

public func run() {
  print("Start")
  CxxApp.main()
}
