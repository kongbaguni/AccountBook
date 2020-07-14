//
//  TagListView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

fileprivate var tags:Results<TagModel> {
    return try! Realm().objects(TagModel.self)
}

struct TagListView: View {
    var body: some View {
        List(tags, id:\.title) { tag in
            Text(tag.title)
        }
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en", "kr"], id: \.self) { id in
            TagListView()
                .environment(\.locale, .init(identifier: id))
        }
    }
}
