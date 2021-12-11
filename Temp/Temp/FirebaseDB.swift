//
//  Firebase.swift
//  Temp
//
//  Created by Dustin Winkler on 11.12.21.
//

import UIKit
import Firebase

// die Klasse wird als Singleton eingebunden
class FirebaseDB: NSObject {

    // unsere private Instanz, damit wir nur eine erstellen können
    private static let instance = FirebaseDB()
    // der Standartpfad (URL) zum Firebase Ordner wird gespeichert
    private let uploadPathStandart = Storage.storage().reference()
    
    // diese Arraylist speichert alle ImageFolder
    private var imageFolderArrayList = Array<ImageFolder>()
    
    // privater Konstruktor
    private override init() {
    }
    
    // diese Methode gibt uns die Instanz zurück
    public static func getInstance() -> FirebaseDB {
        return instance
    }
    
    // diese Methode schaut, welche ImageFolder schon abgelaufen sind und löscht diese
    func deleteImageFolderByTime() {
        // muss beim ersten ausführen der App aufgerufen werden
    }
    
    // diese Funktion bekommt den Ordnernamen sowie ein Array von Bildern übergeben
    func uploadImages(ordnername: String, imagesArray: Array<UIImage>) {
        
        // diese Variable zählt die Bilder, damit wir sie bei der Benennung unterscheiden können
        var counter = 0
        
        // wir nehmen den Standartpfad und erweitern ihn mit dem Ordnernamen -> dadurch erstellen wir einen neuen Ordner
        let currentUploadPath = uploadPathStandart.child("\(ordnername)")
                
        var taskReference: StorageUploadTask?
                
        // wir gehen in einer for each Schleife das Array durch und nehmen in jedem Durchlauf ein Bild und laden es mit einem neuen Dateinamen zu Firebase hoch
        for image in imagesArray {
            taskReference = currentUploadPath.child("testFile\(counter).png").putData(image.pngData()!, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("Failed Uploading")
                    return
                }
            })
            counter += 1
        }
        
        currentUploadPath.child("testFile1.png").downloadURL { (url, error) in
            if let error = error {
                print("Funktioniert nicht \(error)")
                return
            }
            if let url = url {
                print("Funktioniert \(url.absoluteString)")
            }
        }
        
        // hiermit können wir uns den Fortschritt des Uploads anschauen.
        var observer : Double = 0.0 {
            didSet {
                // ViewController().testObserver(fortschritt: observer)
            }
        }
        
        taskReference?.observe(.progress) { (snapshot) in
            guard let pctThere = snapshot.progress?.fractionCompleted else {
                print("noch nicht fertig")
                return
            }
            observer = pctThere
            // print("you are \(pctThere) complete")
            // self?.progressView.progress = Float(pctThere)
        }
    }
    
}