//
//  ViewController.swift
//  Tremor
//
//  Created by Edward Arenberg on 10/5/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var graphIV: UIImageView!
    @IBOutlet weak var alertView: UIView! {
        didSet {
            alertView.isHidden = true
        }
    }
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var shakeIV: UIImageView!
    @IBAction func shakeTapped(_ sender: UITapGestureRecognizer) {
        shakeIV.transform = .identity
        alertView.isHidden = true
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func quakeHit(_ sender: UIButton) {
        let a = ["Mild","Moderate","Heavy","Severe"]
        let aa = a.randomElement() ?? "Mild"
        let d = "\(arc4random_uniform(20) + 15)"
        NotificationCenter.default.post(name: Notification.Name("TremorAlert"), object: nil, userInfo: ["body":d,"title":aa])
    }
    
    var quakeTimer : Timer!
    var timeLeft = 25
    fileprivate var quakeSoundPlayer : AVAudioPlayer!
    fileprivate let quakeSound = Bundle.main.url(forResource: "alert", withExtension: "wav")!
    
    func updateTime() {
        let min = timeLeft / 60
        let sec = timeLeft - (min * 60)
        let tm = String(format: "%i:%02i", min,sec)
        DispatchQueue.main.async {
            self.timeLabel.text = tm
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.mixWithOthers,.defaultToSpeaker,.allowBluetooth])
        } catch {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        quakeSoundPlayer = try? AVAudioPlayer(contentsOf: quakeSound)
        quakeSoundPlayer.prepareToPlay()

        NotificationCenter.default.addObserver(forName: Notification.Name("TremorAlert"), object: nil, queue: .main, using: { notification in
            guard let info = notification.userInfo as? [String:String] else { return }
            guard let body = info["body"], let title = info["title"] else { return }

            var size : CGFloat = 1.5
            self.alertLabel.text = title
            switch title {
            case "Minor":
                self.alertLabel.textColor = .systemTeal
            case "Mild":
                self.alertLabel.textColor = .systemTeal
            case "Moderate":
                self.alertLabel.textColor = .systemOrange
                size = 2
            case "Heavy":
                self.alertLabel.textColor = .systemPink
                size = 3
            case "Severe":
                self.alertLabel.textColor = .systemRed
                size = 4
            default:
                self.alertLabel.textColor = .systemGray
            }
            
            self.timeLeft = Int(body) ?? 10
            
            
            self.quakeTimer = Timer(timeInterval: 1.0, repeats: true, block: { timer in
                self.timeLeft -= 1
                if self.timeLeft == 0 {
                    self.shakeIV.layer.removeAllAnimations()
                    self.shakeIV.transform = .identity
                    self.quakeTimer.invalidate()
                } else if self.timeLeft < 0 {
                    self.timeLeft = 0
                }
                self.updateTime()
            })
            RunLoop.current.add(self.quakeTimer, forMode: .common)

//            self.timeLeft = 15
            self.updateTime()
            
            self.quakeSoundPlayer.play()
            
            self.graphIV.shake(200, withDelta: 15.0, speed: 0.1, shakeDirection: .rotation)
            
            self.alertView.isHidden = false
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: [.autoreverse,.repeat,.curveEaseInOut,.allowUserInteraction],
                animations: {
                    self.shakeIV.transform = CGAffineTransform(scaleX: size, y: size)
            },
                completion: { finished in
                    
            })
            
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
