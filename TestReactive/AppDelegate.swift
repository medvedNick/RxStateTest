//
//  AppDelegate.swift
//  TestReactive
//
//  Created by Nikita Medvedev on 4/11/17.
//  Copyright © 2017 Nikita Medvedev. All rights reserved.
//

import UIKit
import RxSwift
import RxAppState

// тебе нужно создать поле Statistics, которое является "собранным", если:
// 1) получил не менее 10 событий
// 2) собрал события так, что appBecomeActive не меньше appBecomeInactive
// 3) не собрал ни одного AppRecieveMemoryWarning
// 4) не собрал ни одного terminate

class Statistics {
    var becomeActive = 0
    var becomeInactive = 0
    var terminates = 0
	
	let totalEventsToComplete = 3
    
    var total: Int {
        get {
            return becomeActive + becomeInactive + terminates
        }
    }
    
    var isComplete: Bool {
        get {
            return total > totalEventsToComplete && becomeActive >= becomeInactive && terminates == 0
        }
    }
    
    func transformFor(event: AppState) -> Statistics {
        switch event {
        case .active:
            becomeActive += 1
        case .inactive:
            becomeInactive += 1
        case .terminated:
            terminates += 1
        default:
            break
        }
		
		return self
    }
	
	func description() -> String {
		return "Statistics: active - \(becomeActive), inactive - \(becomeInactive), terminates - \(terminates)"
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

	let disposeBag = DisposeBag()
	var subscription: Disposable? = nil
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		application.rx.appState
			.scan(Statistics(), accumulator: { statistics, state in
				return statistics.transformFor(event: state)
			})
			.filter { $0.isComplete }
			.subscribe { stats in
				print(stats.element?.description() ?? "") // here goes only completed statistics
			}
			.disposed(by: disposeBag)
		
        return true
    }

}

