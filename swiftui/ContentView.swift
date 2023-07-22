//
//  ContentView.swift
//  ProblemAI
//
//  Created by Nikhil Krishnaswamy on 7/21/23.
//

import SwiftUI
import CoreData

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
    @State private var numberOfProblems: Int = 5 // Default number of problems is set to 1
    @State private var outputText: String = ""
    @State private var prompt: String = ""

    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Set the main background color to black
                
                HStack(spacing: 20) {
                    Spacer() // Push the input section to the center
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
                                Text("Prompt") // Display "Prompt" label
                                    .font(.title2)
                                    .padding(10)
                                Spacer()
                            }
                            TextField("Enter a prompt", text: $prompt)
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                            // Replace the TextField with a Slider for difficulty
                            VStack {
                                HStack{
                                    Text("Difficulty: \(Int(difficultyValue))/5")
                                        .font(.title2)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                    Spacer()
                                }
                                
                                // Display the current value of the slider
                                Slider(value: $difficultyValue, in: 1...5, step: 1) // Use a range of 1 to 10 for the difficulty
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
                            
                            Button(action: processPrompt) {
                                Image(systemName: "pencil.and.outline")
                                    .padding(10)
                                    .cornerRadius(20)
                            }
                            .background(Color.blue.opacity(0.2))
                            .padding(.top)
                            .padding(.bottom)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .frame(width: 500) // Set a fixed width for the input section
                    .foregroundColor(.white)
                    .background(Color.black) // Set the input section background to black
                    
                    Spacer() // Push the input section to the center

                    Divider()

                    ScrollView {
                        VStack(alignment: .center) { // Align the output text to the center
                            Spacer()

                            // Add a spacer to push the output text lower
                            Text(outputText)
                                .padding()
                                .foregroundColor(.white) // Set text color to orange
                        }
                    }
                    .frame(minWidth: 400) // Set a fixed width for the output section
                    .foregroundColor(.yellow) // Set text color to yellow
                    .background(Color.black) // Set the output section background to black
                }
            }
            .frame(minWidth: 1000, minHeight: 800) // Set the default size for the desktop app
        }


    private func processPrompt() {
        // Concatenate all parameters into a single input string, including the difficultyValue and prompt.
        let inputString = """
            Prompt: \(prompt)
            Topic: \(topic)
            Difficulty: \(Int(difficultyValue))
            Limitations: \(limitations)
            Number of Problems: \(numberOfProblems)
        """

        // Placeholder implementation for OpenAI API call...
        // For demonstration purposes, we'll set a dummy output.
        outputText = "Sample output printed with the concatenated input string:\n\(inputString)"
    }
}

struct HowToUseView: View {
    var body: some View {
        VStack{
            LogoView()
            Text("""
    Fill in the input fields based on user preferences.
    After output is generated, choose to lock the individual problem.
    After all preferred problems are locked, click the dice or reroll button to generate the other problems.
    Once all preferred problems have been achieved click the check button to finish.
    The pdf file will be ready to view and download or export.
""")
        }
        
            .foregroundColor(.white)
            .padding()
    }
}

struct AboutUsView: View {
    var body: some View {
        Text("This is the About Us page")
            .foregroundColor(.white)
            .padding()
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
         // Wrap the content in a NavigationView
            VStack {
                HStack {
                    VStack(spacing: 20) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18))
                            
                            .foregroundColor(selectedTab == 0 ? .yellow : .gray)
                            .onTapGesture {
                                selectedTab = 0
                            }
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 18))
                            
                            .foregroundColor(selectedTab == 1 ? .orange : .gray)
                            .onTapGesture {
                                selectedTab = 1
                            }
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            
                            .foregroundColor(selectedTab == 2 ? .red : .gray)
                            .onTapGesture {
                                selectedTab = 2
                            }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.black)

                    Divider()

                    // Use a Group to show the selected view with a background color
                    Group {
                        if selectedTab == 0 {
                            MainView()
                        } else if selectedTab == 1 {
                            HowToUseView()
                        } else if selectedTab == 2 {
                            AboutUsView()
                        } else {
                            MainView() // Default selection
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                }
                Spacer()
            }
             // Set the navigation bar display mode to inline
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
