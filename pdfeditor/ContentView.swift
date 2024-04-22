import SwiftUI
import UIKit
import MobileCoreServices
import PDFKit

struct FileItem {
  var fileName: String
  var fileText: String
  var fileURL: URL?
}

struct ContentView: View {
  @State private var fileItems: [FileItem] = []
  @State private var isPickerPresented = false
  @State private var showingPDFPreview = false
  @State private var mergedPDFDocument = PDFDocument()

  private let fileNameWidth: CGFloat = 200
  private let textFieldWidth: CGFloat = 50
  private let buttonWidth: CGFloat = 30

  var body: some View {
    List {
      ForEach(0..<fileItems.count, id: \.self) { index in
        HStack {
          Text(fileItems[index].fileName).frame(width: fileNameWidth, alignment: .leading)
          TextField("Enter pages", text: $fileItems[index].fileText)
            .frame(width: textFieldWidth)
          Spacer()
          Button(action: {
            fileItems.remove(at: index)
          }) {
            Image(systemName: "minus.circle")
          }
          .frame(width: buttonWidth)
        }
      }.onMove(perform: move)
      HStack {
        Spacer()
        Button(action: { isPickerPresented = true }) {
          Image(systemName: "plus")
        }
        Spacer()
      }
      Button("Generate PDF") {
        mergePDFs()
        showingPDFPreview = true
      }
    }
    .navigationBarItems(trailing: EditButton())
    .sheet(isPresented: $isPickerPresented) {
      DocumentPicker { url in
        var pageNum = 0
        let fileName = url.lastPathComponent

        let canAccess = url.startAccessingSecurityScopedResource()
        defer {
          url.stopAccessingSecurityScopedResource()
        }

        if let pdfDocument = PDFDocument(url: url) {
          pageNum = pdfDocument.pageCount
        }

        if !canAccess {
          // 无法访问文件，需要处理错误
          // TODO
        }

        fileItems.append(FileItem(fileName: fileName, fileText: "1-" + String(pageNum), fileURL: url))
      }
    }
    .sheet(isPresented: $showingPDFPreview) {
      PDFPreviewView(pdfDocument: mergedPDFDocument)
    }
  }

  func move(from source: IndexSet, to destination: Int) {
    fileItems.move(fromOffsets: source, toOffset: destination)
  }

  func mergePDFs() {
    // Implement your PDF merging logic here
    // After merging:
    // mergedPDFDocument = PDFDocument()
    if mergedPDFDocument.pageCount > 0 {
      mergedPDFDocument = PDFDocument()
    }
    for fileItem in fileItems {
      if let fileURL = fileItem.fileURL {
        let canAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
          fileURL.stopAccessingSecurityScopedResource()
        }

        // 在这里处理文件内容
        if let pdfDocument = PDFDocument(url: fileURL) {
          let pages = parseNumberString(input: fileItem.fileText)
          for page in pages {
            mergedPDFDocument.insert(pdfDocument.page(at: page - 1)!, at: mergedPDFDocument.pageCount)
          }
          // TODO
        }

        if !canAccess {
          // 无法访问文件，需要处理错误
          // TODO
        }
      }

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

func parseNumberString(input: String) -> [Int] {
    let ranges = input.split(separator: ",")
    var numbers = Set<Int>()

    for range in ranges {
        let bounds = range.split(separator: "-").map { Int($0)! }
        if bounds.count == 1 {
            numbers.insert(bounds.first!)
        } else {
            numbers.formUnion((bounds.first!...bounds.last!))
        }
    }

    return Array(numbers).sorted()
}
