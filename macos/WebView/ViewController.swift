import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {
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
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
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
}
