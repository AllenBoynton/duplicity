//
//  OptionsViewController.swift
//  twofold
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit
import StoreKit
import GoogleMobileAds

var difficulty = UInt()
var iPadDifficulty = UInt()
var theme = UInt()
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
    
    @IBOutlet var dividerViews: [UIView]!
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet var buttonLabels: [UIButton]!
    @IBOutlet var arrowImages: [UIImageView]!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private var rowString = String()
    private var myImageView = UIImageView()
    private var myLabel = UILabel()
    
    private var adBannerView: GADBannerView!
    
    private var imageCategoryArray: [String] = ["Stickmen", "Butterflies", "Beaches", "Jungle", "Sea Critters"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.title = "Options"
        self.navigationItem.setHidesBackButton(true, animated: animated)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func handleMusicButtons() {
        if (bgMusic?.isPlaying)! {
            musicOnView.layer.borderWidth = 2.0
            musicOnView.layer.borderColor = UIColor.yellow.cgColor
            musicOffView.layer.borderWidth = 0
            musicOnView.alpha = 1.0
            musicOffView.alpha = 0.4
            musicIsOn = true
        } else {
            musicOnView.layer.borderWidth = 0
            musicOffView.layer.borderWidth = 2.0
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
        self.segmentedControl.layer.cornerRadius = 5.0
        self.segmentedControl.layer.borderWidth = 2.0
        self.segmentedControl.layer.masksToBounds = true
        
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
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "TwoFold Version \(version) Build \(build)"
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
    
    @objc func doneButtonTapped() {
        // Return to game screen
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameController")
        show(vc!, sender: self)
    }
    
    @IBAction func gcButtonTapped(_ sender: Any) {
        showLeaderboard()
    }
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://www.alsmobileapps.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        let appleID = "1455567974"
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
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x:0, y:0, width:pickerView.bounds.width - 30, height:80))
        
        myImageView = UIImageView(frame: CGRect(x:60, y:15, width:50, height:50))
        myImageView.contentMode = .scaleAspectFit
        myLabel = UILabel(frame: CGRect(x:pickerView.bounds.maxX - 190, y:10, width:pickerView.bounds.width - 90, height:60 ))
        myLabel.font = UIFont(name: Theme.mainFontTheme, size: 15)
        
        switch row {
        case 0:
            handleThemeChange(themeNum: 0, imageNum: "\(Int.random(in: 1..<21))", themeName: MemoryGame.stickmen,
                bg: StickmanTheme.stickmanBGColor,
                navBarColor: .white,
                segBorderColor: StickmanTheme.stickmanBorderColor,
                segTintColor: StickmanTheme.stickmanTintColor,
                segFont: StickmanTheme.mainFontTheme,
                segForeColorNorm: StickmanTheme.stickmanSegForegroundColorNormal,
                segForeColorSelect: StickmanTheme.stickmanSegForegroundColorSelected,
                musicBtnColor: StickmanTheme.stickmanTintColor)
            handleTextTheme(color: .black)
        case 1:
            handleThemeChange(themeNum: 1, imageNum: "\(Int.random(in: 21..<38))", themeName: MemoryGame.butterflies, bg: ButterflyTheme.butterflyBGColor,
                navBarColor: ButterflyTheme.butterflyTintColor,
                segBorderColor: ButterflyTheme.butterflyBorderColor,
                segTintColor: ButterflyTheme.butterflyTintColor,
                segFont: ButterflyTheme.mainFontTheme,
                segForeColorNorm: ButterflyTheme.butterflySegForegroundColorNormal,
                segForeColorSelect: ButterflyTheme.butterflySegForegroundColorSelected,
                musicBtnColor: ButterflyTheme.butterflyTintColor)
            handleTextTheme(color: .black)
        case 2:
            handleThemeChange(themeNum: 2, imageNum: "\(Int.random(in: 41..<58))", themeName: MemoryGame.beach,
                bg: BeachTheme.beachBGColor,
                navBarColor: BeachTheme.beachTintColor,
                segBorderColor: BeachTheme.beachBorderColor,
                segTintColor: BeachTheme.beachTintColor,
                segFont: BeachTheme.mainFontTheme,
                segForeColorNorm: BeachTheme.beachSegForegroundColorNormal,
                segForeColorSelect: BeachTheme.beachSegForegroundColorSelected,
                musicBtnColor: BeachTheme.beachTintColor)
            handleTextTheme(color: .white)
        case 3:
            handleThemeChange(themeNum: 3, imageNum: "\(Int.random(in: 75..<79))", themeName: MemoryGame.jungle,
                bg: JungleTheme.jungleBGColor,
                navBarColor: JungleTheme.jungleTintColor,
                segBorderColor: JungleTheme.jungleBorderColor.cgColor,
                segTintColor: JungleTheme.jungleTintColor,
                segFont: JungleTheme.mainFontTheme,
                segForeColorNorm: JungleTheme.jungleTextColor,
                segForeColorSelect: JungleTheme.jungleSegForegroundColorSelected,
                musicBtnColor: JungleTheme.jungleTextColor)
            handleTextTheme(color: JungleTheme.jungleTextColor)
        case 4:
            handleThemeChange(themeNum: 4, imageNum: "\(Int.random(in: 80..<97))", themeName: MemoryGame.seaCreatures,
                bg: SeaTheme.seaBGColor,
                navBarColor: SeaTheme.seaBorderColor,
                segBorderColor: UIColor.systemTeal.cgColor,
                segTintColor: BeachTheme.beachTintColor,
                segFont: BeachTheme.mainFontTheme,
                segForeColorNorm: UIColor.systemTeal,
                segForeColorSelect: UIColor.blue,
                musicBtnColor: UIColor.systemTeal)
            handleTextTheme(color: .white)
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
    
    private func handleThemeChange(themeNum: Int, imageNum: String, themeName: [UIImage], bg: UIColor, navBarColor: UIColor, segBorderColor: CGColor, segTintColor: UIColor, segFont: String, segForeColorNorm: UIColor, segForeColorSelect: UIColor, musicBtnColor: UIColor) {
        theme = UInt(themeNum)
        defaults.set(themeNum, forKey: "theme")
        rowString = imageCategoryArray[themeNum]
        myImageView.image = UIImage(named: imageNum)
        imageGroupArray = themeName
        view?.backgroundColor = bg
        navigationController?.navigationBar.barTintColor = navBarColor
        segmentedControl.layer.borderColor = segBorderColor
        segmentedControl.tintColor = segTintColor
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: segFont, size: 15) as Any,
            NSAttributedString.Key.foregroundColor: segForeColorNorm
            ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: segFont, size: 15) as Any,
            NSAttributedString.Key.foregroundColor: segForeColorSelect
            ], for: .selected)
        musicOnView.backgroundColor = musicBtnColor
        musicOffView.backgroundColor = musicBtnColor
    }
    
    private func handleTextTheme(color: UIColor) {
        for div in dividerViews {
            div.backgroundColor = color
        }
        
        for label in labels {
            label.textColor = color
        }
        
        for label in buttonLabels {
            label.setTitleColor(color, for: .normal)
        }
        
        for images in arrowImages {
            let origImage = UIImage(named: "right")
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            images.image = tintedImage
            images.tintColor = color
        }

        myLabel.textColor = color
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
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(adBannerView)
        
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-2292175261120907/9987324360"
        adBannerView.rootViewController = self
        adBannerView.delegate = self
        
        adBannerView.load(request)
    }
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
}
