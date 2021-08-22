import Cocoa
import WebKit

class ViewController: NSViewController {
    @IBOutlet var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
