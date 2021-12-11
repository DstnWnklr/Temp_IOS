//
//  ViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

class ViewController: UIViewController, PHPickerViewControllerDelegate {

    // wenn wir unsere Card vergrößern oder verkleinern speichern wir hier den aktuellen Stand
    enum CardState {
        case expanded
        case collapsed
    }
        
    // die View für den Button, damit dieser immer über allen andern Views liegt
    @IBOutlet weak var addButtonView: UIView!
    
    // das Array, was alle Bilder speichert
    private var imagesArray = [UIImage]()
    
    // wir erstellen ein Objekt vom Typ Firebase
    let firebaseDB = FirebaseDB.getInstance()
    
    // Referenz zu unserem CardViewController
    var cardViewController : CardViewController!
    // für den späteren Unschärfeeffekt im Hintergrund | hier können wir auch die Intensität der Unschärfe festlegen und animieren
    var visualEffectView : UIVisualEffectView!
    
    // die Konstanten für die Höhen unserer Card
    let cardHeight : CGFloat = 850
    let heightStop : CGFloat = 100
    let cardHandleAreaHeight : CGFloat = 65
    
    // wenn die Card ausgefahren ist, wird es true, im eingefahrenen Zustand false
    var cardVisible = false
    var nextState : CardState {
        // hier können wir den nächsten State entsprechend unseres CardVisable boolean zurückgeben | wenn es sichtbar ist, müssen wir es Einfahren, sonst anders herum
        return cardVisible ? .collapsed : .expanded
    }
    
    // hier legen wir das Array an, welches alle Animationen abspeichert, welche wir verwenden (Größenveränderung der Card und Hintergrundunschärfe)
    var runningAnimations = [UIViewPropertyAnimator]()
    // da wir unsere Animationen unterbrechen wollen -> sie also intuitiv sind, speichern wir den Fortschritt unserer Animation in einer Variable
    var animationProgressWhenInterrupted : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
        
        self.view.bringSubviewToFront(addButtonView)
        
        // aktueller workaround, damit wir die Ordner löschen, welche veraltet sind 
        firebaseDB.deleteImageFolderByTime()
    }
    
    // diese Funktion baut die Card auf
    func setupCard() {
        // initialisieren die visualEffectView
        visualEffectView = UIVisualEffectView()
        // damit hat der Effekt die selbe größe, wie unsere View im ViewController
        visualEffectView.frame = self.view.frame
        // dann nutzen wir unsere MainView und fügen den visuellen Effekt hinzu
        self.view.addSubview(visualEffectView)
        
        // wir initialisieren den cardViewController | der nibName ist der Name der .xib Datei
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        //cardViewController = CardViewController(coder: NSCoder)
        // fügen den cardViewController zur MainView hinzu
        self.addChild(cardViewController)
        // fügen die View des cardViewControllers zur MainView hinzu
        self.view.addSubview(cardViewController.view)
        
        
        // wir setzen den Rahmen der CardView
        // !!!!!!!!!!!!!!!! hier können wir dann die Ausrichtung ändern !!!!!!!!!!!!!!!!
        // cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardViewController.view.frame = CGRect(x: 0, y: heightStop, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        // erstellen die Objekte der Bewegungserkennung
        // da dies in Form des Target - Action Pattern passiert, müssen wir mit den #Selectoren arbeiten
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
        
        // können unserer CardView die entsprechenden Bewegungsabläufe übermitteln
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }

    // diese Funktion behandelt das Antippen der Card -> dann bewegt sie sich in die entsprechend andere Richtung
    // da wir in den Variablen den #selector Befehl auswählen, müssen wir variablen zur Laufzeit ausgeführt werden. Aus diesem Grund werden Sie mit @objc Markiert
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    // diese Funktion behandelt das Schieben der Card -> dann folgt sie der Fingerbewegung
    // da wir in den Variablen den #selector Befehl auswählen, müssen wir variablen zur Laufzeit ausgeführt werden. Aus diesem Grund werden Sie mit @objc Markiert
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        // ein PanGestureRecognizer hat mehrere Stadien
        // mit einem switch-case können wir abfragen, in welchem Stadium sich die PanGestureRecognizer gerade befindet
        switch recognizer.state {
        case .began:
            // wenn der aktuelle Status bei .began liegt, dann wollen wir die Animation starten
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // wenn der aktuelle Status bei .changed liegt, dann wollen wir die Animation updaten
            // hiermit überprüfen wir, ob die Animation sich gerade an der Position des Fingers befindet
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            // wenn unsere Card aktuell sichtbar ist, wollen wir nur die fractionComplete haben
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // wenn der aktuelle Status bei .ended liegt, dann wollen wir die Animation fortsetzern
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    
    // diese Funktion behandelt die eigentliche Animation
    // wird jedes mal aufgerufen, wenn wir eine Animation abfragen oder schauen, ob wir eine brauchen
    func animateTransitionIfNeeded (state : CardState, duration : TimeInterval) {
        // wenn wir keine Animationen haben, sollten wir die Bewegung animieren
        if runningAnimations.isEmpty {
            // wir erstellen ein Objekt der UIViewPropertyAnimator-Klasse um unsere Animation zu definieren
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                // innerhalb der Animation können wir zwei Dinge machen, entweder wir bewegen unsere Card nach oben oder nach unten, dafür nutzen wir unser Enum
                switch state {
                    case .expanded:
                        // wir müssen den y-Wert verändern
                        // bewegt es zum öffnen nach oben
                        // !!!!!!!!!!!!!!!! hier können wir die Bewegungsrichtung bei der Animation verändern (anders herum) !!!!!!!!!!!!!!!!
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                    case .collapsed:
                        // wir müssen den y-Wert verändern
                        // bewegt es zum schließen nach unten
                        // !!!!!!!!!!!!!!!! hier können wir die Bewegungsrichtung bei der Animation verändern (anders herum) !!!!!!!!!!!!!!!!
                        self.cardViewController.view.frame.origin.y = self.heightStop
                }
            }
            
            // wird ausgeführt, wenn die Animation fertig bzw. Abgeschlossen ist
            frameAnimator.addCompletion { _ in
                // Spiegelt den Zustand unseres CardVisible boolean
                self.cardVisible = !self.cardVisible
                // wenn die Animation beendet ist, können wir alle Animationen aus unserem Array entfernen
                self.runningAnimations.removeAll()
            }
            
            // hiermit starten wir die Animation
            frameAnimator.startAnimation()
            // fügen die Animation dem Array hinzu
            runningAnimations.append(frameAnimator)
            
            
            // kümmert sich darum, dass die Ecken am Ende der Animation rund sind
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                    case .expanded:
                        // wenn die Card ausgefahren ist, werden die Ecken rund
                        self.cardViewController.view.layer.cornerRadius = 12
                    case .collapsed:
                        // wenn die Card eingefahren ist, werden die Ecken eckig
                        self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            // startet die Animation
            cornerRadiusAnimator.startAnimation()
            // fügt die Animation dem Array hinzu
            runningAnimations.append(cornerRadiusAnimator)
            
            /*
            // kümmert sich darum, dass der Hintergrund unscharf wird
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                    case .expanded:
                        // wenn die Karte ausgefahren ist, wir der Hintergrund dunkel
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    case .collapsed:
                        // wenn die Karte eingefahren ist, verändert sich der Hintergrund nicht
                        self.visualEffectView.effect = nil
                }
            }
            
            // startet die Animation
            blurAnimator.startAnimation()
            // fügt die Animation dem Array hinzu
            runningAnimations.append(blurAnimator)
 */
            
        }
    }
    
    // diese Funktion kümmert sich um das Starten der Bewegungsanimation
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        // wir schauen, ob die Animation noch nicht läuft
        if runningAnimations.isEmpty {
            // da noch keine Animation läuft, können wir diese starten
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        // da wir evenutell mehrere Animation gleichzeitig haben (Bewegungsanimation und Unschärfe), benutzen wir eine Schleife durch alle laufenden Animationen
        for animator in runningAnimations {
            // um mit den Animationen interaggieren zu können, müssen wir sie als erstes pausieren | somit setzen wir die Geschwinidgkeit der Animation auf 0
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    // diese Funktion kümmert sich um das updaten der Bewegungsanimation
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        // da wir evenutell mehrere Animation gleichzeitig haben (Bewegungsanimation und Unschärfe), benutzen wir eine Schleife durch alle laufenden Animationen
        for animator in runningAnimations {
            // wenn wir unseren Finger nach oben oder unten bewegen, bedeutet dies, dass wir unsere fractionCompleted sich verändern wird
            animator.fractionComplete = -fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    // diese Funktion kümmert sich um das Fortsetzen der Bewegungsanimation
    func continueInteractiveTransition () {
        // da wir evenutell mehrere Animation gleichzeitig haben (Bewegungsanimation und Unschärfe), benutzen wir eine Schleife durch alle laufenden Animationen
        for animator in runningAnimations {
            // wir setzten die Animation einfach fort
            // dadruch, dass wir die duration auf 0 setzten, nutzt die Animation einfach die verbleibende Zeit in unserer Animation, welche wir oben auf 0.9 Sekunden gestellt haben
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    // diese Funktion gibt uns die ausgewählten Bilder und Fotos aus der PickerView zurück
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // hiermit beenden (schließen wir den Picker)
        picker.dismiss(animated: true, completion: nil)
        
        // ist eine Gruppe von Aufgaben, welche als eine Einheit überwachen werden
        let group = DispatchGroup()
        
        // alle ausgewählten Elemente befinden sich im result Array und mit der forEach-Schleife können wir diese nun herausnehmen und einzeln bearbeiten
        results.forEach { results in
            group.enter()
            // hiermit laden wir das Objekt aus dem Array
            results.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                defer {
                    group.leave()
                }
                // die image Variable bekommt nun innerhalb des Schleifendurchlaufes ein Bild aus dem Array zugewiesen
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                print("Bild \(image)")
                // im letzten Schritt innerhalb der Schleife weisen wir dem Array das neue Bild zu
                self?.imagesArray.append(image)
            }
        }
        
        // wenn die komplette Aufgabengruppe fertig ist, dann können wir das Array an die FirebaseDB Klasse weitergeben
        group.notify(queue: .main) {
            print(self.imagesArray.count)
            self.firebaseDB.uploadImages(ordnername: "Testordner", imagesArray: self.imagesArray)
        }
    }
    
    
    // diese Methode fügt Einträge hinzu und aktuallisiert die View
    @IBAction func addButton(_ sender: Any) {
        print("Button pressed")
        // hier konfigurieren wir den Picker | aktuell greifen wir nur auf die vom Benutzer geteilte Fotobibliothek zu
        var config = PHPickerConfiguration(photoLibrary: .shared())
        // hiermit beschränken wir die Anzahl der Auswahlen auf 3
        config.selectionLimit = 6
        // config.filter = .images
        config.filter = PHPickerFilter.any(of: [.images])
        
        // hiermit öffnen wir den Picker (wir weisen ihm dem ViewController zu)
        let viewController2 = PHPickerViewController(configuration: config)
        viewController2.delegate = self
        present(viewController2, animated: true)
    }
}
