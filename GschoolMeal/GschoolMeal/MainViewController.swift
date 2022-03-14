//
//  MainViewController.swift
//  GschoolMeal
//
//  Created by 이건우 on 2022/03/14.
//

import UIKit
import FirebaseFirestore
import FSCalendar
import AVFoundation

class MainViewController: UIViewController, FSCalendarDataSource {
    
    // MARK: - variables
    var date: String = "" {
        didSet {
            updateViews()
            UIView.transition(with: infoShadow, duration: 0.2, options: .transitionCrossDissolve, animations: {
            }, completion: nil)
        }
    }
    
    let myUserDefaults = UserDefaults.standard
    let menuData = MenuData.shared
    var currentMonth: String = ""
    let userNotificationCenter = UNUserNotificationCenter.current()
    var audioPlayer: AVAudioPlayer?
    let url = Bundle.main.url(forResource: "BGM", withExtension: "mp3")
    var bgmIsOn = Bool()
    
    // MARK: - IBOutlets
    @IBOutlet weak var bgmButton: UIButton!
    
    // calendar
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarShadow: UIView!
    
    // menu info
    @IBOutlet weak var lunch: UILabel!
    @IBOutlet weak var lunchMenu: UILabel!
    @IBOutlet weak var lunchMenuBG: UIView!
    
    @IBOutlet weak var dinner: UILabel!
    @IBOutlet weak var dinnerMenu: UILabel!
    @IBOutlet weak var dinnerMenuBG: UIView!
    
    @IBOutlet weak var infoShadow: UIView!
    
    // if data is empty show this view
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataTitle: UILabel!
    @IBOutlet weak var noDataDescription: UILabel!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todayDateformatter = DateFormatter()
        todayDateformatter.dateFormat = "yyMMdd"
        let currentMonthformatter = DateFormatter()
        currentMonthformatter.dateFormat = "MM"
        
        self.date = todayDateformatter.string(from: Date())
        self.currentMonth = currentMonthformatter.string(from: Date())
        
        self.noDataView.isHidden = true
        
        calendar.dataSource = self
        calendar.delegate = self
        
        if #available(iOS 10.0, *) {
            requestNotificationAuthorization()
            sendLunchNotification()
            sendDinnerNotification()
        } else {
            
        }
        
        // userDefault에 따라 브금 재생
        if let bgm = myUserDefaults.value(forKey: "bgmIsOn") {
            bgmIsOn = bgm as! Bool
        } else {
            bgmIsOn = true
        }
        
        // set
        setCalendar()
        setMenuSection()
        setNoDataView()
        setShadowView()
        setAudioPlayer()
        updateViews()
    }
    
    // MARK: - IBAction
    @IBAction func bgmButtonTapped(_ sender: Any) {
        if audioPlayer?.isPlaying == true {
            myUserDefaults.set(false, forKey: "bgmIsOn")
            bgmButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
            audioPlayer?.stop()
        } else {
            myUserDefaults.set(true, forKey: "bgmIsOn")
            bgmButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            audioPlayer?.play()
        }
    }
    
    // MARK: - Functions
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: authOptions) { didAllow, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            if didAllow {
                // Push Notification 권한 허용
            } else {
                // alert로 Push Notification 권한 유도
            }
        }
    }
    
    func sendLunchNotification() {
        let notiContent = UNMutableNotificationContent()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 30
        
        notiContent.title = "점심시간!"
        notiContent.body = "오늘의 점심 메뉴를 확인해보세요."
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "LocalLunchNoti", content: notiContent, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func sendDinnerNotification() {
        let notiContent = UNMutableNotificationContent()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 17
        
        notiContent.title = "저녁시간!"
        notiContent.body = "오늘의 저녁 메뉴를 확인해보세요."
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "LocalDinnerNoti", content: notiContent, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func setCalendar() {
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        
        // 달력의 토, 일 날짜 색깔
        calendar.appearance.titleWeekendColor = .red
        
        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .black
        
        // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .black
        
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY년 M월"

        // 달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR")
                
        // 달력의 요일 글자 바꾸는 방법 2
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
    }
    
    func setMenuSection() {
        lunch.text = "오늘의 점심 😋"
        lunch.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        lunchMenu.text = menuData.lunchMenuData[self.date]
        lunchMenu.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        dinner.text = "오늘의 저녁 😉"
        dinner.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        dinnerMenu.text = menuData.dinnerMenuData[self.date]
        dinnerMenu.font = UIFont.systemFont(ofSize: 16, weight: .light)
    }
    
    func setNoDataView() {
        noDataTitle.text = "메뉴가 없어요!"
        noDataTitle.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        noDataDescription.text = "오늘은 주말 혹은 쉬는날이에요 ☺️"
        noDataDescription.font = UIFont.systemFont(ofSize: 18, weight: .light)
    }
    
    func setShadowView() {
        calendarShadow.layer.cornerRadius = 20
        calendarShadow.layer.shadowOpacity = 0.2
        calendarShadow.layer.shadowColor = UIColor.black.cgColor
        calendarShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        calendarShadow.layer.shadowRadius = 10
        calendarShadow.layer.masksToBounds = false
        
        infoShadow.layer.cornerRadius = 20
        infoShadow.layer.shadowOpacity = 0.2
        infoShadow.layer.shadowColor = UIColor.black.cgColor
        infoShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        infoShadow.layer.shadowRadius = 10
        infoShadow.layer.masksToBounds = false
        
        lunchMenuBG.layer.cornerRadius = 8
        lunchMenuBG.backgroundColor = UIColor(red: 250/255, green: 236/255, blue: 236/255, alpha: 1)
        
        dinnerMenuBG.layer.cornerRadius = 8
        dinnerMenuBG.backgroundColor = UIColor(red: 250/255, green: 236/255, blue: 236/255, alpha: 1)
    }
    
    func updateViews() {
        lunchMenu.text = menuData.lunchMenuData[self.date]
        dinnerMenu.text = menuData.dinnerMenuData[self.date]
        
        if menuData.lunchMenuData[self.date] == nil && menuData.dinnerMenuData[self.date] == nil {
            self.noDataView.isHidden = false
            UIView.transition(with: noDataView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            }, completion: nil)
        } else {
            UIView.transition(with: noDataView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.noDataView.isHidden = true
            }, completion: nil)
        }
        
        var someDate = self.date
        someDate.removeLast(2)
        
        if someDate.suffix(2) != currentMonth {
            noDataDescription.text = "이달의 급식 정보만 제공해요 ☺️"
        } else {
            noDataDescription.text = "오늘은 주말 혹은 쉬는날이에요 ☺️"
        }
    }
    
    func setAudioPlayer() {
        if let url = url {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.prepareToPlay()
            } catch {
                print(error)
            }
        }
        
        if bgmIsOn == false {
            bgmButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        } else {
            bgmButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            audioPlayer?.play()
        }
    }
}

// MARK: - FSCalendarDelegate
extension MainViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        
        self.date = dateFormatter.string(from: date)
    }
}
