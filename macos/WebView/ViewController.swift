import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    @IBOutlet var webView: WKWebView!

    var windowTitle: String = "Window Title"

    override func loadView() {
        super.loadView()

        let configUrl = Bundle.main.url(forResource: "application_config", withExtension: "json")!
        let configContents = try! Data(contentsOf: configUrl);
        let configParsed = try! JSONSerialization.jsonObject(with: configContents, options: [])
        
        var width = 480
        var height = 360
        var background = NSColor.black.cgColor
        if let dict = configParsed as? [String: Any] {
            if let title = dict["title"] as? String {
                self.windowTitle = title
            }
            if let number = dict["width"] as? Int {
                width = number
            }
            if let number = dict["height"] as? Int {
                height = number
            }
            if let color = dict["background"] as? [Int] {
                background = NSColor(
                    red: CGFloat(color[0]) / 255.0,
                    green: CGFloat(color[1]) / 255.0,
                    blue: CGFloat(color[2]) / 255.0,
                    alpha: CGFloat(color[3])
                ).cgColor
            }
        }
        view.wantsLayer = true
        view.layer?.backgroundColor = background
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.userContentController.add(self, name: "download")
            webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        #if DEBUG
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        webView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = windowTitle
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
    }

    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.allowedFileTypes = ["txt", "csv", "tsv"]
        panel.allowsOtherFileTypes = true
        panel.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK, let url = panel.url {
                completionHandler([url])
            } else {
                completionHandler(nil)
            }
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "download",
           let body = message.body as? NSDictionary,
           let name = body["name"] as? NSString,
           let rawData = body["data"] as? [UInt8] {
            let panel = NSSavePanel()
            panel.allowsOtherFileTypes = true
            panel.nameFieldStringValue = name as String
            panel.allowedFileTypes = ["txt"]
            panel.begin { (result) -> Void in
                if result == NSApplication.ModalResponse.OK, let url = panel.url {
                    let data = Data(rawData)
                    try! data.write(to: url)
                }
            }
        }
    }
}
