//
//  NCTextView.swift
//  N Clipboard
//
//  Created by poor branson on 2020/5/9.
//  Copyright © 2020 poor-branson. All rights reserved.
//

import SwiftUI

struct NCTextView: View {
    var content: String = ""
    
    var body: some View {
        ScrollView {
            Text(content)
                .frame(minWidth: 120, maxWidth: 320, minHeight: 120, maxHeight: 380, alignment: .center)
        }
    }
}

struct NCTextView_Previews: PreviewProvider {
    static var previews: some View {
        NCTextView(content: "asdfaqipqweroyiafasdfjasdhjasdhfjadf asdfajlsa asdfjaksf asfjaksdfj asfjkasdf asdfjaksdfna asdfjkasf asdf asfkjasdf asf adfajskdfjnasfjkaksdf asdjfkasdf asdfjaksf asdkf asdfasd faksdfa sdfa kasfajsfppquoqertikhakfhkladf af asfkjnz,vnmxcbvm lashdfaidsfh ae awefiaowfhae afbjadf asduqwp3110583 13 891345134581359810213qwrhqwer qwroqwurhasdbnzbv,zjkhifuas9d8")
    }
}
