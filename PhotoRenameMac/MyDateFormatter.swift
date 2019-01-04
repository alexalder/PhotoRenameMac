//
//  PettaDateFormatter.swift
//  PhotoRenameMac
//
//  Created by Alexalder on 30/12/2018.
//  Copyright © 2018 Alexalder. All rights reserved.
//

import Foundation

class MyDateFormatter: DateFormatter {
    var pettaDateFormat = "yyyy-MM-dd_HH'h'-mm'm'-ss's'"
    let pettaLocale = Locale(identifier: "en_US_POSIX")
    
    override init() {
        super.init()
        initializeFormatter()
    }
    
    init(optionalDateFormat: String){
        super.init()
        pettaDateFormat = optionalDateFormat
        initializeFormatter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeFormatter()
    }
    
    func initializeFormatter(){
        locale = pettaLocale
        dateFormat = pettaDateFormat
    }
}
