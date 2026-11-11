import SwiftUI
import WebKit
import UniformTypeIdentifiers

@main
struct AteneoApp: App {
    var body: some Scene { WindowGroup { DiaryView().ignoresSafeArea(.container, edges: .bottom) } }
}

struct DiaryView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DiaryController { DiaryController() }
    func updateUIViewController(_ controller: DiaryController, context: Context) {}
}

final class DiaryController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private var web: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.userContentController.add(self, name: "download")
        let bridge = """
        document.addEventListener('click', async function(e) {
          const a=e.target.closest('a[download]');
          if(!a || !a.href.startsWith('blob:')) return;
          e.preventDefault();
          try {
            const blob=await (await fetch(a.href)).blob();
            const reader=new FileReader();
            reader.onload=()=>window.webkit.messageHandlers.download.postMessage({name:a.download||'file',data:reader.result});
            reader.readAsDataURL(blob);
          } catch(e) { alert('Impossibile esportare il file.'); }
        },true);
        """
        config.userContentController.addUserScript(WKUserScript(source: bridge, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        web = WKWebView(frame: .zero, configuration: config)
        web.uiDelegate = self
        web.navigationDelegate = self
        web.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)
        view.addSubview(web)
        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "download", let body = message.body as? [String: String],
              let value = body["data"], let comma = value.firstIndex(of: ","),
              let data = Data(base64Encoded: String(value[value.index(after: comma)...])) else { return }
        let name = URL(fileURLWithPath: body["name"] ?? "file").lastPathComponent
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let file = folder.appendingPathComponent(name.isEmpty ? "file" : name)
            try data.write(to: file)
            let share = UIActivityViewController(activityItems: [file], applicationActivities: nil)
            share.popoverPresentationController?.sourceView = view
            share.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
            share.completionWithItemsHandler = { _, _, _, _ in try? FileManager.default.removeItem(at: folder) }
            present(share, animated: true)
        } catch { showError("Non è stato possibile esportare il file.") }
    }
    private func showError(_ text: String) {
        let alert = UIAlertController(title: "Ateneo", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: "Ateneo", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let a = UIAlertController(title: "Ateneo", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Annulla", style: .cancel) { _ in completionHandler(false) })
        a.addAction(UIAlertAction(title: "Conferma", style: .default) { _ in completionHandler(true) })
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, ["https", "http"].contains(url.scheme ?? "") { UIApplication.shared.open(url) }
        return nil
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, ["https", "http"].contains(url.scheme ?? ""), navigationAction.navigationType == .linkActivated {
            UIApplication.shared.open(url); decisionHandler(.cancel)
        } else { decisionHandler(.allow) }
    }
}
