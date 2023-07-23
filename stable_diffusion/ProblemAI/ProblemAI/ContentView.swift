//  ContentView.swift
//  ProblemAI
//
//  Created by Nikhil Krishnaswamy on 7/21/23.
//
import SwiftUI
import NVActivityIndicatorView
import PDFKit

struct LogoView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 75)
            .padding(.top)
    }
}

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var topic: String = ""
    @State private var difficultyValue: Double = 3
    @State private var limitations: String = ""
    @State private var numberOfProblems: Int = 5
    @State private var outputText: String = ""
    @State private var outputanswers: String = ""
    @State private var prompt: String = ""
    @ObservedObject private var viewModel = ViewModel()
    @State private var allQuestionsGenerated = false

    
    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                HStack(spacing: 20) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 20) {
                        LogoView()
                        
                        GroupBox() {
                            HStack {
                                Text("Topic")
                                    .font(.title2)
                                    .padding(10)
                                Spacer()
                            }
                        
                            
                            TextField("Ex: Multiplication, Calculus, Physics, Biology", text: $topic)
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                            HStack {
                                Text("Prompt")
                                    .font(.title2)
                                    .padding(10)
                                Spacer()
                            }
                            TextField("Enter a prompt", text: $prompt)
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                            
                            VStack {
                                HStack{
                                    Text("Difficulty: \(Int(difficultyValue))/5")
                                        .font(.title2)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                    Spacer()
                                }
                                
                                // Display the current value of the slider
                                Slider(value: $difficultyValue, in: 1...5, step: 1)
                                    .padding(10)
                                    .foregroundColor(.white)
                                    .font(.system(size : 10))
                                    
                            }
                            
                            HStack {
                                Text("Limitations")
                                    .font(.title2)
                                    .padding(10)
                                Spacer()
                            }
                            
                            TextField("Ex: Avoid division with remainders, No trig limits", text: $limitations)
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                            Stepper("Number of Problems: \(numberOfProblems)", value: $numberOfProblems, in: 1...10)
                                .padding(10)
                                .foregroundColor(.white)
                                .font(.title2)
                            
                            Button(action: processPrompt) {
                                Image(systemName: "pencil.and.outline")
                                    .padding(10)
                                    .cornerRadius(20)
                                    
                            }
                            .background(Color.blue.opacity(0.2))
                            .padding(.top)
                            .padding(.bottom)
                            
                        }
                        .background(Color.black.opacity(0.2))
                        .padding()
                        
                        Spacer()
                    }
                    .frame(width: 500)
                    .foregroundColor(.white)
                    .background(Color.black)
                    
                    Spacer()

                    Divider()
                    
                    VStack(spacing: 20){
                        Spacer()
                        ScrollView {
                            Spacer()
                            ForEach(outputText.split(separator: "\n"), id: \.self) { line in
                                if let label = line.first {
                                    let text = line.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                                    if label == "Q" {
                                        Text(text)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                            .multilineTextAlignment(.leading)
                                    } else if label == "A" {
                                        Text(text)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.blue.opacity(0.4))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Button(action: {
                                createPDF(questions: outputText.split(separator: "\n").map { String($0) })
                            }) {
                                Text("Create PDF")
                                    .padding(10)
                                    .cornerRadius(20)
                                    .background(Color.green.opacity(0.6))
                                    .cornerRadius(10)
                                    .opacity(allQuestionsGenerated ? 1.0 : 0.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.black)
                            .padding(20)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(minWidth: 1000, minHeight: 800)
            
        }
    private func processPrompt() {
        
        let inputString = """
            Prompt: \(prompt)
            Topic: \(topic)
            Difficulty: \(Int(difficultyValue))
            Limitations: \(limitations)
            Number of Problems: \(numberOfProblems)
        """
        
        viewModel.getOpenAIResponse(input: inputString) { output in
            
            outputText = output
            allQuestionsGenerated = true
            
        }
        
        
    }
    
    private func createPDF(questions: [String], fontSize: CGFloat = 12) {
        let pdfDocument = PDFDocument()
        
        for question in questions {
            let pdfPage = PDFPage()

            let textAnnotation = PDFAnnotation(bounds: CGRect(x: 50, y: 620, width: 400, height: 100), forType: .freeText, withProperties: nil)
            textAnnotation.contents = question
            textAnnotation.font = NSFont.systemFont(ofSize: fontSize)
            textAnnotation.backgroundColor = NSColor.white
            textAnnotation.color = NSColor.white
            pdfPage.addAnnotation(textAnnotation)

            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]

        savePanel.begin { result in
            if result == NSApplication.ModalResponse.OK {
                guard let fileURL = savePanel.url else {
                    print("Error: Unable to get file URL.")
                    return
                }

                pdfDocument.write(to: fileURL)
            }
        }
    }

}


struct HowToUseView: View {
    var body: some View {
        VStack{
            LogoView()
            Text("""
    At its core, problem.ai is an AI-powered platform designed to streamline the studying experience for both students and teachers. The user interface design was methodically crafted to provide an intuitive and seamless experience for users. It incorporates a series of input fields that solicit prompt information from the user, enabling them to specify their preferences and requirements. This prompt information is then efficiently processed and fed into a sophisticated and fine-tuned model, which employs advanced algorithms to generate a diverse range of problems tailored precisely to the user's desires. These generated problems are elegantly presented on the user interface, providing a visually engaging and informative display. Moreover, to enhance usability and flexibility, the app allows users  to export the generated problems as editable PDF files. This feature enables users to customize the problems according to their preferences, should they wish to make any adjustments or additions. By seamlessly combining intuitive input mechanisms, cutting-edge algorithms, and an export functionality, the app ensures an enriching and user-centric problem generation experience.
""")
        }
        .multilineTextAlignment(.leading)
        
            .foregroundColor(.white)
            .padding(.all)
            
    }
}

struct AboutUsView: View {
    var body: some View {
        Text("""
We intend to add features like image generation, problem-to-problem generation, a view for replacing a singluar question if the user doesnt like it, a button to show answers, and implement a more versatile pdf editor.
""")
            .foregroundColor(.white)
            .padding()
    }
}
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack{
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                                .foregroundColor(selectedTab == 0 ? .yellow : .gray)
                            Text("Home")
                        }.multilineTextAlignment(.leading)
                            .onTapGesture {
                                selectedTab = 0
                            }
                        HStack{
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(selectedTab == 1 ? .orange : .gray)
                            Text("How to Use")
                        }.multilineTextAlignment(.leading)
                            .onTapGesture {
                                selectedTab = 1
                            }
                        HStack{
                            Image(systemName: "wand.and.stars.inverse")
                                .font(.system(size: 18))
                                .foregroundColor(selectedTab == 2 ? .red : .gray)
                            Text("Beta")
                        }.multilineTextAlignment(.leading)
                        
                            .onTapGesture {
                                selectedTab = 2
                            }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.black)

                    Divider()

                    Group {
                        if selectedTab == 0 {
                            MainView()
                        } else if selectedTab == 1 {
                            HowToUseView()
                        } else if selectedTab == 2 {
                            AboutUsView()
                        } else {
                            MainView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
