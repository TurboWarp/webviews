import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
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
//    TODO: somehow have to make file saving work...
//    but WKWebView is busted https://bugs.webkit.org/show_bug.cgi?id=216918
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
        openPanel.allowedFileTypes = ["txt", "csv", "tsv"]
        openPanel.allowsOtherFileTypes = true
        openPanel.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                if let url = openPanel.url {
                    completionHandler([url])
                    return
                }
            }
            completionHandler(nil)
        }
    }
}
