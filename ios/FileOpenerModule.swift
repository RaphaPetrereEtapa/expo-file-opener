import ExpoModulesCore

private final class OpenInDelegate: NSObject, UIDocumentInteractionControllerDelegate {
  weak var owner: FileOpenerModule?

  init(owner: FileOpenerModule) {
    self.owner = owner
  }

  func documentInteractionControllerViewControllerForPreview(
    _ controller: UIDocumentInteractionController
  ) -> UIViewController {
    owner?.appContext?.utilities?.currentViewController() ?? UIViewController()
  }

  func documentInteractionControllerDidDismissOpenInMenu(
    _ controller: UIDocumentInteractionController
  ) {
    owner?.releaseController()
  }
}

public final class FileOpenerModule: Module {
  var interactionController: UIDocumentInteractionController?
  private var openInDelegate: OpenInDelegate?

  public func definition() -> ModuleDefinition {
    Name("FileOpener")

    AsyncFunction("openAsync") { (uri: URL, _: String, uti: String, promise: Promise) in
      guard FileSystemUtilities.isReadableFile(self.appContext, uri) else {
        promise.reject("ERR_FILE_OPENER", "Não foi possível abrir este arquivo")
        return
      }

      guard let view = self.appContext?.utilities?.currentViewController()?.view else {
        promise.reject("ERR_FILE_OPENER", "Não foi possível abrir este arquivo")
        return
      }

      let controller = UIDocumentInteractionController(url: uri)
      if !uti.isEmpty {
        controller.uti = uti
      }
      let delegate = OpenInDelegate(owner: self)
      controller.delegate = delegate
      self.openInDelegate = delegate
      self.interactionController = controller

      let bounds = view.bounds
      let source = CGRect(x: bounds.midX, y: bounds.maxY - 1, width: 1, height: 1)
      let presented = controller.presentOpenInMenu(from: source, in: view, animated: true)
      if !presented {
        self.releaseController()
        promise.reject("ERR_FILE_OPENER", "Nenhum aplicativo pode abrir este arquivo")
        return
      }
      promise.resolve(nil)
    }
    .runOnQueue(.main)
  }

  func releaseController() {
    interactionController = nil
    openInDelegate = nil
  }
}
