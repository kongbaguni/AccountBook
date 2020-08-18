//
//  MakeTagView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

var editTags:String = ""

extension Notification.Name {
    static let makeTagsNotification = Notification.Name(rawValue: "makeTagsNotification_observer")
}

struct MakeTagView: View {
    init(tags:String) {
        addTags = tags.components(separatedBy: ",")
    }
    
    @State var addTags:[String] = []
    @State var newTags:[String] = []
    @State var newTag:String = ""
     
    func loadTags() {
        var setA = Set<String>()
        var setB = Set<String>()
       
        if editTags.isEmpty  == false {
            addTags = editTags.components(separatedBy: ",")
        }
        
        for tag in addTags {
            let t = tag.trimmingValue
            if t.isEmpty == false {
                setA.insert(tag)
            }
        }
        
        let list = try! Realm().objects(TagModel.self)
        for t in list {
            let tt = t.title.trimmingValue
            if tt.isEmpty == false {
                setB.insert(tt)
            }
        }
        
        setB.subtract(setA)
        addTags = setA.sorted()
        newTags = setB.sorted()
    }
    
    
    func insertTag(tag:String) {
        let newTag = tag.trimmingValue
        if newTag.isEmpty {
            return
        }
        addTags.append(newTag)
        addTags.sort()
        
        if let idx = newTags.firstIndex(of: newTag) {
            newTags.remove(at: idx)
        }
    }
    
    func removeTag(tag:String) {
        if let idx = addTags.firstIndex(of: tag) {
            addTags.remove(at: idx)
            newTags.append(tag)
            
            addTags.sort()
            newTags.sort()
        }
    }
    
    func toggleTag(tag:String) {
        if addTags.firstIndex(of: tag) != nil {
            removeTag(tag: tag)
        } else {
            insertTag(tag: tag)
        }
    }
    
    var body: some View {
        List {
            Section(header:Text("")) {
                HStack {
                    Text("new tag").padding(10)
                    RoundedTextField(title: "tags", text: $newTag, keyboardType: .default, onEditingChanged: {tag in
                        print(tag)
                    }, onCommit: {
                        self.insertTag(tag: self.newTag)
                        self.newTag = ""
                    })
                }
            }

            Section(header: Text(addTags.count == 0 ? "" : "included tags")) {
                ForEach(addTags, id:\.self) { tag in
                    Button(action: {
                        self.toggleTag(tag: tag)
                    }) {
                        Text(tag)
                    }.padding(10)
                }
            }
            Section(header:Text(newTag.count == 0 ? "" : "not included tags")) {
                ForEach(newTags, id:\.self) { tag in
                    Button(action: {
                        self.toggleTag(tag: tag)
                    }) {
                        Text(tag)
                    }.padding(10)
                }
            }
        }
        .onAppear {
            self.loadTags()
        }.onDisappear {
            NotificationCenter.default.post(name: .makeTagsNotification, object: self.addTags)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("edit tag"))
    }
}

struct MakeTagView_Previews: PreviewProvider {
    static var previews: some View {
        MakeTagView(tags: "aaa,bbb")
    }
}
