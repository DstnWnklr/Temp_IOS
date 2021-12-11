//
//  ImageFolder.swift
//  Temp
//
//  Created by Dustin Winkler on 11.12.21.
//

import UIKit

// diese Klasse dient nur zum Speichern von Informationen
class ImageFolder: NSObject {
    
    private var urlLink : String
    private var name : String
    private var timeRemaining : DateInterval
    private var uploadeTime : Date
    
    public init(name: String, urlLink: String) {
        self.name = name
        self.urlLink = urlLink
        self.uploadeTime = Date.init()
        self.timeRemaining = DateInterval.init(start: uploadeTime, duration: 86400)
    }
    
    func getUrlLink() -> String {
        return self.urlLink
    }
    
    func getUploadTime() -> Date {
        return self.uploadeTime
    }
    
    // gibt die verbleibende Zeit in Sekunden als Double zurück
    func getTimeRemainingInMinutes() -> Double {
        let timeRemainingDuration : Double = timeRemaining.duration
        return timeRemainingDuration
    }
    
    func getTimeRemaining() -> DateInterval {
        return self.timeRemaining
    }
    
    
}
