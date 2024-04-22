import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFKitView: UIViewRepresentable {
  @State var pdfDocument: PDFDocument

  @State private var isSaveDialogPresented = false

  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.document = pdfDocument
    pdfView.autoScales = true
    return pdfView
  }

  func updateUIView(_ uiView: PDFView, context: Context) {
    // 更新视图时不需要额外操作
  }
}

struct PDFPreviewView: View {
  @State var pdfDocument: PDFDocument
  @State private var isShareSheetPresented = false

  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    NavigationView {
      PDFKitView(pdfDocument: pdfDocument)
        .navigationBarTitle("PDF Preview", displayMode: .inline)
        .navigationBarItems(
          leading: Button("Back") {
            // 执行返回操作
            presentationMode.wrappedValue.dismiss()
          },
          trailing: Button(action: {
            isShareSheetPresented = true
          }) {
            Image(systemName: "square.and.arrow.up")
          }
        )
        .sheet(isPresented: $isShareSheetPresented) {
                ActivityViewController(isPresented: $isShareSheetPresented, activityItems: [pdfDocument.dataRepresentation() ?? Data()])
            }
    }
  }
}

struct Document: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var activityItems: [Any]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { (_, _, _, _) in
            isPresented = false
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
