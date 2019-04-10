//
//  HighScoreViewController.swift
//  twofold
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds

// Global GC identifiers
let easyID = "EasyLeaderboard" // Easy Time Leaderboard
let mediumID = "MediumLeaderboard" // Medium Time Leaderboard
let hardID = "HardLeaderboard" // Hard Time Leaderboard

class HighScoreViewController: UIViewController {
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var newGameTimeStackview: UIStackView!
    @IBOutlet weak var bestEasyTimeStackView: UIStackView!
    @IBOutlet weak var bestMedTimeStackView: UIStackView!
    @IBOutlet weak var bestHardTimeStackView: UIStackView!
    @IBOutlet weak var bestTimesStackView: UIStackView!
    
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var easyHighScoreLbl: UILabel!
    @IBOutlet weak var mediumHighScoreLbl: UILabel!
    @IBOutlet weak var hardHighScoreLbl: UILabel!
    @IBOutlet weak var newHighScoreLabel: UILabel!
    
    @IBOutlet weak var bestTimeStackLabel: UILabel!
    
    @IBOutlet weak var gcIconView: UIView!
    
    private var adBannerView: GADBannerView!
    private var interstitial: GADInterstitial!
    
    private var scoreReporter = GKScore()
    private var score = Int()
    private var easyHighScore = Int()
    private var mediumHighScore = Int()
    private var hardHighScore = Int()
    private var numOfGames = 0
    
    private var minutes = Int()
    private var seconds = Int()
    private var millis = Int()
    
    // Time passed from PokeMatchVC
    var timePassed: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateGCIcon()
        loadImage()
        newHighScoreLabel.startBlink()
        addScore()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interstitial = createAndLoadInterstitial()
        handleAdRequest()
        showItems()
        checkHighScoreForNil()
        numOfGames = defaults.integer(forKey: "Games")
        showTime()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        gifView.image = nil
    }
    
    private func setupLayout() {
        switch theme {
        case 0:
            self.view.backgroundColor = .white
            gifView.image = UIImage(named: "8")
        case 1:
            self.view.backgroundColor = UIColor.rgb(red: 247, green: 207, blue: 104)
            gifView.image = UIImage(named: "30")
        case 2:
            self.view.backgroundColor = UIColor.rgb(red: 70, green: 215, blue: 215)
            gifView.image = UIImage(named: "51")
        default:
            self.view.backgroundColor = .white
        }
    }
    
    private func showTime() {
        if timePassed != nil {
            let numTime = convertStringToNumbers(time: timePassed!)!
            saveHighScore(numTime)
            if numTime <= 3000 {
                numOfGames += 1
                defaults.set(numOfGames, forKey: "Games")
//                handleGameAchievements()
            }
        } 
    }
    
    // Shows items depending on best score screen or final score screen
    private func showItems() {
        bestTimeStackLabel.isHidden = false
    }
    
    private func loadImage() {
        gifView.contentMode = .scaleAspectFit
        
    }
    
    /*************************** High Score Logic *********************/
    
    // Verifies score/time is not nil
    func checkHighScoreForNil() {
        if defaults.value(forKey: "EasyHighScore") != nil {
            easyHighScore = score
            easyHighScore = defaults.value(forKey: "EasyHighScore") as! NSInteger
            easyHighScoreLbl.text = "\(intToScoreString(score: easyHighScore))"
        }
        if defaults.value(forKey: "MediumHighScore") != nil {
            mediumHighScore = score
            mediumHighScore = defaults.value(forKey: "MediumHighScore") as! NSInteger
            mediumHighScoreLbl.text = "\(intToScoreString(score: mediumHighScore))"
        }
        if defaults.value(forKey: "HardHighScore") != nil {
            hardHighScore = score
            hardHighScore = defaults.value(forKey: "HardHighScore") as! NSInteger
            hardHighScoreLbl.text = "\(intToScoreString(score: hardHighScore))"
        }
    }
    
    // Score format for time
    func intToScoreString(score: Int) -> String {
        minutes = score / 10000
        seconds = (score / 100) % 100
        millis = score % 100
        
        let scoreString = NSString(format: "%02i:%02i.%02i", minutes, seconds, millis) as String
        return scoreString
    }
    
    // Adds time from game to high scores. Compares against others for order
    func addScore() {
        if timePassed != nil {
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "play again", style: .done, target: self, action: #selector(playAgainButtonPressed))
            navigationItem.title = "YOU WON!"
            score = Int(convertStringToNumbers(time: timePassed!)!)
            scoreLabel.text = "\(intToScoreString(score: score))"
            
            if defaults.integer(forKey: "difficulty") == 0 {
                if (score < easyHighScore) || (easyHighScore == 0) {
                    newHighScoreLabel.isHidden = false
                    bestEasyTimeStackView.startBlink()
                    easyHighScore = score
                    defaults.set(easyHighScore, forKey: "EasyHighScore")
                    easyHighScoreLbl.text = "\(intToScoreString(score: Int(easyHighScore)))"
                }
            }
            
            if defaults.integer(forKey: "difficulty") == 1 {
                if (score < mediumHighScore) || (mediumHighScore == 0) { // Change value for testing purposes
                    newHighScoreLabel.isHidden = false
                    bestMedTimeStackView.startBlink()
                    mediumHighScore = score
                    defaults.set(mediumHighScore, forKey: "MediumHighScore")
                    mediumHighScoreLbl.text = "\(intToScoreString(score: Int(mediumHighScore)))"
                }
            }
            
            if defaults.integer(forKey: "difficulty") == 2 {
                if (score < hardHighScore) || (hardHighScore == 0) { // Change value for testing purposes
                    newHighScoreLabel.isHidden = false
                    bestHardTimeStackView.startBlink()
                    hardHighScore = score
                    defaults.set(hardHighScore, forKey: "HardHighScore")
                    hardHighScoreLbl.text = "\(intToScoreString(score: Int(hardHighScore)))"
                }
            }
        } else {
            self.title = "best times"
            bestTimeStackLabel.isHidden = true
            newGameTimeStackview.isHidden = true
            scoreLabel.isHidden = true
        }
    }
    
    // Seperate string out to numbers
    func convertStringToNumbers(time: String) -> Int? {
        let strToInt = time.westernArabicNumeralsOnly
        return Int(strToInt)!
    }
    
    /*************************** GC Animation **********************/
    
    // Animate GC image
    private func animateGCIcon() {
        UIView.animate(withDuration: 1.5, animations: {
            self.gcIconView.transform = CGAffineTransform(scaleX: 20, y: 20)
            self.gcIconView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }) { (finished) in
            UIView.animate(withDuration: 0.8, animations: {
                self.gcIconView.transform = CGAffineTransform.identity
            })
        }
    }
    
    /**************************** IBActions ************************/
    
    // Play again game button to main menu
    @objc func playAgainButtonPressed(_ sender: Any) {
        // Return to game screen
        // Interstitial Ad setup
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameController")
        show(vc!, sender: self)
    }
    
    @IBAction func showGameCenter(_ sender: UIButton) {
        showLeaderboard()
        gifView.image = nil
    }
}
    
// MARK:  Game Center
extension HighScoreViewController: GKGameCenterControllerDelegate {
    
    /**************************** Game Center ***********************/
    
    private func saveHighScore(_ score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            // Save game time to GC
            if defaults.integer(forKey: "difficulty") == 0 {
                handleScoreReporter(id: easyID)
            }
            
            if defaults.integer(forKey: "difficulty") == 1 {
                handleScoreReporter(id: mediumID)
            }
            
            if defaults.integer(forKey: "difficulty") == 2 {
                handleScoreReporter(id: hardID)
            }
        }
    }
    
    private func handleScoreReporter(id: String) {
        scoreReporter = GKScore(leaderboardIdentifier: id)
        scoreReporter.value = Int64(score)
        let gkScoreArray: [GKScore] = [scoreReporter]
        GKScore.report(gkScoreArray, withCompletionHandler: { error in
            guard error == nil else { return }
        })
    }
    
    // Retrieves the GC VC leaderboard
    private func showLeaderboard() {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        
        // Show leaderboard
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    
//    private func handleGameAchievements() {
//        if GKLocalPlayer.local.isAuthenticated {
//            let games = defaults.integer(forKey: "Games")
//            switch games {
//            case 10:
//                reportAchievement(identifier: gamesAchievementID10, percentCompleted: Double(games / 10) * 100)
//            case 20:
//                reportAchievement(identifier: gamesAchievementID20, percentCompleted: Double(games / 20) * 100)
//            case 30:
//                reportAchievement(identifier: gamesAchievementID30, percentCompleted: Double(games / 30) * 100)
//            case 40:
//                reportAchievement(identifier: gamesAchievementID40, percentCompleted: Double(games / 40) * 100)
//            case 50:
//                reportAchievement(identifier: gamesAchievementID50, percentCompleted: Double(games / 50) * 100)
//            case 75:
//                reportAchievement(identifier: gamesAchievementID50, percentCompleted: Double(games / 75) * 100)
//            case 100:
//                reportAchievement(identifier: gamesAchievementID100, percentCompleted: Double(games / 100) * 100)
//            case 150:
//                reportAchievement(identifier: gamesAchievementID150, percentCompleted: Double(games / 150) * 100)
//            case 200:
//                reportAchievement(identifier: gamesAchievementID200, percentCompleted: Double(games / 200) * 100)
//            case 250:
//                reportAchievement(identifier: gamesAchievementID250, percentCompleted: Double(games / 250) * 100)
//            case 300:
//                reportAchievement(identifier: gamesAchievementID300, percentCompleted: Double(games / 300) * 100)
//            case 350:
//                reportAchievement(identifier: gamesAchievementID350, percentCompleted: Double(games / 350) * 100)
//            case 400:
//                reportAchievement(identifier: gamesAchievementID400, percentCompleted: Double(games / 400) * 100)
//            case 450:
//                reportAchievement(identifier: gamesAchievementID450, percentCompleted: Double(games / 450) * 100)
//            case 500:
//                reportAchievement(identifier: gamesAchievementID500, percentCompleted: Double(games / 500) * 100)
//            default:
//                break
//            }
//        }
//
//        GKAchievement.loadAchievements() { achievements, error in
//            guard let achievements = achievements else { return }
//            print(achievements)
//        }
//    }
    
    private func reportAchievement(identifier: String, percentCompleted: Double) {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentCompleted
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement], withCompletionHandler: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK:  AdMob
extension HighScoreViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    /*************************** AdMob Requests ***********************/
    
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
    
    // Ad request
    func handleAdRequest() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(adBannerView)
        
        // Ad setup
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//ca-app-pub-2292175261120907/9576260829"
        adBannerView.rootViewController = self
        adBannerView.delegate = self
        adBannerView.load(request)
    }
    
    // Create and load an Interstitial Ad
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")//ca-app-pub-2292175261120907/1071084845")
        interstitial.delegate = self
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        if musicIsOn {
            bgMusic?.pause()
            musicIsOn = true
        } else {
            musicIsOn = false
        }
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if musicIsOn {
            bgMusic?.play()
        } else {
            bgMusic?.pause()
            musicIsOn = false
        }
    }
}
