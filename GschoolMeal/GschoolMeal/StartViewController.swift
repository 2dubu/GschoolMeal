//
//  StartViewController.swift
//  GschoolMeal
//
//  Created by 이건우 on 2022/03/14.
//

import Foundation
import UIKit

class StartViewController: UIViewController {
    
    final class FirstLaunch {
        let wasLaunchedBefore: Bool
        var isFirstLaunch: Bool { return !wasLaunchedBefore }
        init(getWasLaunchedBefore: () -> Bool,
             setWasLaunchedBefore: (Bool) -> ()) {
            let wasLaunchedBefore = getWasLaunchedBefore()
            self.wasLaunchedBefore = wasLaunchedBefore
            if !wasLaunchedBefore { setWasLaunchedBefore(true) }
        }
        convenience init(userDefaults: UserDefaults, key: String) {
            self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) }, setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
        }
    }

    // 첫 실행인지 확인
    let fistLaunch = FirstLaunch(userDefaults: .standard, key: "com.any-suggestion.FirstLaunch.WasLaunchedBefore")
    
    // 항상 첫 실행으로 (테스트용)
    let alwaysFirstLaunch = FirstLaunch(getWasLaunchedBefore: { return false }, setWasLaunchedBefore: { _ in })
    
    //MARK: - LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        checkDeviceNetworkStatus()
    }
    
    //MARK: - function
    func checkDeviceNetworkStatus() {
            if(DeviceManager.shared.networkStatus) {
                // 네트워크 연결 O
                getMenuData {
                    let mainNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNC")
                    mainNav.modalPresentationStyle = .fullScreen
                    mainNav.modalTransitionStyle = .crossDissolve
                    self.present(mainNav, animated: true, completion: nil)
                    UIView.transition(with: self.view, duration: 1.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            } else {
                // 네트워크 연결 X
                let alert : UIAlertController = UIAlertController(title: "서버에 연결할 수 없습니다",
                    message: """
                    네트워크가 연결되지 않았습니다.
                    Wi-Fi 또는 데이터를 활성화 해주세요.
                    """,
                    preferredStyle: .alert)
                let action: UIAlertAction = UIAlertAction(title: "다시 시도", style: .default, handler: { (ACTION) in
                    self.checkDeviceNetworkStatus()
                })
                action.setValue(UIColor.black, forKey: "titleTextColor")
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
    }
}
