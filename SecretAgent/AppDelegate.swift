import Cocoa
import SecretKit
import OSLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let store = SecureEnclave.Store()
    let notifier = Notifier()
    lazy var agent: Agent = {
        Agent(store: store, notifier: notifier)
    }()
    lazy var socketController: SocketController = {
        let path = (NSHomeDirectory() as NSString).appendingPathComponent("socket.ssh") as String
        return SocketController(path: path)
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        os_log(.debug, "SecretAgent finished launching")
        DispatchQueue.main.async {
            self.socketController.handler = self.agent.handle(fileHandle:)
        }
        notifier.prompt()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}
