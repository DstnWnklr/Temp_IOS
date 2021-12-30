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
    
    private var imageFolderTableCell = ImageFolderTableCell()
    
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
    
    func imageFolderNumer() -> Int {
        return imageFolderArrayList.count
    }
    
    // diese Funktion bekommt den Ordnernamen sowie ein Array von Bildern übergeben
    func uploadImages(ordnername: String, imagesArray: Array<UIImage>) {
        var counter = 0
        
        // wir nehmen den Standartpfad und erweitern ihn mit dem Ordnernamen -> dadurch erstellen wir einen neuen Ordner
        let currentUploadPath = uploadPathStandart.child("\(ordnername)")
                
        var taskReference: StorageUploadTask?
                    
        var downloadUrl : String = "Test"
        
        // die DispatchGroup nutzen wir, damit die Erstellung des ImageFolder Objektes warten muss, bis der Upload fertig ist
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            // wir gehen in einer for each Schleife das Array durch und nehmen in jedem Durchlauf ein Bild und laden es mit einem neuen Dateinamen zu Firebase hoch
            for image in imagesArray {
                taskReference = currentUploadPath.child("testFile\(counter).png").putData(image.pngData()!, metadata: nil, completion: {_, error in
                    guard error == nil else {
                        print("Failed Uploading")
                        return
                    }
                })
                // work around -> da wir nur ein Bild hochladen, können wir den Link vom Bild zwischespeichern -> wenn wir mehrere Bilder hochladen würden, dann würden wir hier den letzten URL Pfad zwischenspeichern
                currentUploadPath.child("testFile\(counter).png").downloadURL { (url, error) in
                    if let error = error {
                        print("Funktioniert nicht \(error)")
                        return
                    }
                    if let url = url {
                        print("Funktioniert \(url.absoluteString)")
                        downloadUrl = url.absoluteString
                        group.leave()
                    }
                }
                counter += 1
            }
            
            // hiermit können wir uns den Fortschritt des Uploads anschauen.
            var observer : Double = 0.0 {
                didSet {
                    // ViewController().testObserver(fortschritt: observer)
                    self.imageFolderTableCell.progressViewObserver(fortschritt: Float(observer))
                }
            }
            
            taskReference?.observe(.progress) { (snapshot) in
                guard let pctThere = snapshot.progress?.fractionCompleted else {
                    print("noch nicht fertig")
                    return
                }
                observer = pctThere
            }
        }
        
        // erst wenn der Befehl des group.leave kommt, wird der code in der notify-Methode ausgeführt
        group.notify(queue: .main) {
            // fügen der ArrayList ein neuen ImageFolder hinzu
            self.imageFolderArrayList.append(ImageFolder.init(name: ordnername, urlLink: downloadUrl))
            print("imageFolderArrayList URL: \(self.imageFolderArrayList[0].getUrlLink())")
        }
    }
}
