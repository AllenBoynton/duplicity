//
//  OptionsViewController.swift
//  duplicity
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit
import StoreKit
import SwiftyGif
import GoogleMobileAds

var difficulty = UInt()
var iPadDifficulty = UInt()
let defaults = UserDefaults.standard
var imageGroupArray: [UIImage] = []

class OptionsViewController: UIViewController, GKGameCenterControllerDelegate {
    
    // Class delegates
    let music = Music()
    let musicPlayer = AVAudioPlayer()
    let pokeMatchViewController: GameController! = nil
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var imagePicker: UIPickerView!
    @IBOutlet weak var musicOnView: UIView!
    @IBOutlet weak var musicOffView: UIView!
    @IBOutlet weak var offMusicImage: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    private var bannerView: GADBannerView!
    
    private var imageCategoryArray: [String] = ["Most Popular", "Generation 1", "Generation 2", "Generation 3", "Generation 4", "Generation 5", "Generation 6", "Generation 7"]
    
    override func viewWillAppear(_ animated: Bool) {
        versionLabel.text = version()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.dataSource = self
        self.imagePicker.delegate = self
        
        let pickerName = defaults.integer(forKey: "row")
        self.imagePicker.selectRow(pickerName, inComponent: 0, animated: true)
        
        handleMusicButtons()
        handleSegmentControl()
        handleAdRequest()
    }
    
    func handleMusicButtons() {
        if (bgMusic?.isPlaying)! {
            musicOnView.layer.borderWidth = 2.0
            musicOnView.layer.cornerRadius = 8.0
            musicOnView.layer.borderColor = UIColor.yellow.cgColor
            musicOffView.layer.borderWidth = 0
            musicOnView.alpha = 1.0
            musicOffView.alpha = 0.4
            musicIsOn = true
        } else {
            musicOnView.layer.borderWidth = 0
            musicOffView.layer.borderWidth = 2.0
            musicOffView.layer.cornerRadius = 8.0
            musicOffView.layer.borderColor = UIColor.yellow.cgColor
            musicOnView.alpha = 0.4
            musicOffView.alpha = 1.0
            musicIsOn = false
        }
    }
    
    func handleSegmentControl() {
        // Saves the current state of the segmented control
        let segmentName = defaults.integer(forKey: "difficulty")
        self.segmentedControl.selectedSegmentIndex = segmentName
        self.segmentedControl.layer.cornerRadius = 8.0
        self.segmentedControl.layer.borderWidth = 2.0
        self.segmentedControl.layer.masksToBounds = true
        self.segmentedControl.layer.borderColor = UIColor.yellow.cgColor
        
        if segmentName == 0 {
            difficulty = 6
            iPadDifficulty = 6
        } else if segmentName == 1 {
            difficulty = 8
            iPadDifficulty = 10
        } else if segmentName == 2 {
            difficulty = 10
            iPadDifficulty = 15
        }
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Marker Felt", size: 15) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.yellow
            ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Marker Felt", size: 15) as Any,
            NSAttributedString.Key.foregroundColor: UIColor.blue
            ], for: .selected)
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "PokéMatch Version \(version) Build \(build)"
    }
    
    @IBAction func difficultySelection(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            difficulty = 6
            iPadDifficulty = 6
            defaults.set(0, forKey: "difficulty")
        case 1:
            difficulty = 8
            iPadDifficulty = 10
            defaults.set(1, forKey: "difficulty")
        case 2:
            difficulty = 10
            iPadDifficulty = 15
            defaults.set(2, forKey: "difficulty")
        default:
            print("Default hit in Difficulty - Segmented Control")
        }
    }
    
    @IBAction func musicButtonOn(_ sender: Any) {
        music.handleMuteMusic(clip: bgMusic)
        handleMusicButtons()
    }
    
    @IBAction func musicButtonOff(_ sender: Any) {
        music.handleMuteMusic(clip: bgMusic)
        handleMusicButtons()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        // Return to game screen
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PokeMatchViewController")
        show(vc!, sender: self)
    }
    
    @IBAction func gcButtonTapped(_ sender: Any) {
        showLeaderboard()
    }
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://www.facebook.com/PokeMatchMobileApp/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        let appleID = "1444497236"
        guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id\(appleID)?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    // Retrieves the GC VC leaderboard
    func showLeaderboard() {
        let gameCenterViewController = GKGameCenterViewController()
        
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .default
        
        // Show leaderboard
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    // Adds the Done button to the GC view controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

extension OptionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK:  UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return imageCategoryArray.count
        }
        return imageCategoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    // MARK:  UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return imageCategoryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.set(row, forKey: "row")
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:80))
        
        let myImageView = UIImageView(frame: CGRect(x:60, y:15, width:50, height:50))
        myImageView.contentMode = .scaleAspectFit
        let myLabel = UILabel(frame: CGRect(x:pickerView.bounds.maxX - 190, y:10, width:pickerView.bounds.width - 90, height:60 ))
        myLabel.font = UIFont.boldSystemFont(ofSize: 18)
        var rowString = String()
        
        switch row {
        case 0:
            rowString = imageCategoryArray[0]
            myImageView.image = UIImage(named: "25")
            imageGroupArray = MemoryGame.topCardImages
        case 1:
            rowString = imageCategoryArray[1]
            myImageView.image = UIImage(named: "_6")
            imageGroupArray = MemoryGame.gen1Images
        case 2:
            rowString = imageCategoryArray[2]
            myImageView.image = UIImage(named: "249")
            imageGroupArray = MemoryGame.gen2Images
        case 3:
            rowString = imageCategoryArray[3]
            myImageView.image = UIImage(named: "384")
            imageGroupArray = MemoryGame.gen3Images
        case 4:
            rowString = imageCategoryArray[4]
            myImageView.image = UIImage(named: "448")
            imageGroupArray = MemoryGame.gen4Images
        case 5:
            rowString = imageCategoryArray[5]
            myImageView.image = UIImage(named: "635")
            imageGroupArray = MemoryGame.gen5Images
        case 6:
            rowString = imageCategoryArray[6]
            myImageView.image = UIImage(named: "658")
            imageGroupArray = MemoryGame.gen6Images
        case 7:
            rowString = imageCategoryArray[7]
            myImageView.image = UIImage(named: "745_2")
            imageGroupArray = MemoryGame.gen7Images
        case 8: break
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }

        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
}

extension OptionsViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide.bottomAnchor,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    // AdMob banner ad
    func handleAdRequest() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-2292175261120907/4964310398"
        bannerView.rootViewController = self
        bannerView.delegate = self
        
        bannerView.load(request)
    }
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}
