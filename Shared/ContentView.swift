//
//  ContentView.swift
//  Shared
//
//  Created by Teague Cole on 2/27/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWord = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    @State private var errorTitle: String = ""
    @State private var errrorMessage: String = ""
    @State private var showingError: Bool = false
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section(usedWord.count == 1 ? "\(usedWord.count) word found" : "\(usedWord.count) words found") {
                    ForEach(usedWord, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Text("You have \(score) points")
            }
            .listStyle(.grouped)
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(errrorMessage)
            }
            .toolbar {
                Button("New Game", action: startGame)
            }
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWord.contains(word)
    }
    
    func isPossible(word :String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func lessThanThreeLetters(word: String) -> Bool {
        !(word.count < 3)
    }
    
    func isNotRootWord(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errrorMessage = message
        showingError = true
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "shouldntHappen"
                usedWord.removeAll()
                score = 0
                return
            }
        }
        fatalError("Could not load start.txt from Bundle")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You made up that word!")
            return
        }
        
        guard lessThanThreeLetters(word: answer) else {
            wordError(title: "Word is less than 3 letters", message: "Cant use words with less than 3 characters!")
            return
        }
        
        guard isNotRootWord(word: answer) else {
            wordError(title: "Word is root word", message: "You cant use \(rootWord)!")
            return
        }
        
        withAnimation {
            usedWord.insert(answer, at: 0)
            score += answer.count
        }
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
