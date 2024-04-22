import SwiftUI
import UIKit
import MobileCoreServices
import PDFKit

struct DocumentPicker: UIViewControllerRepresentable {
  var onPick: (URL) -> Void

  func makeUIViewController(context: Context) -> some UIViewController {
    let picker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .open)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    var parent: DocumentPicker

    init(_ parent: DocumentPicker) {
      self.parent = parent
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      guard let url = urls.first else {
        return
      }
      parent.onPick(url)
    }
  }
}
