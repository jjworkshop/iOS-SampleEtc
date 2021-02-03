//
//  AppDelegate.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let TAG = "APPデリゲート"
    var window: UIWindow?

    /*
        これはアプリのデリゲート処理なので、どのタイミングでどのメソッドが呼ばれるかシュミレーターで確認するといいよ
        ログを入れておいたので、それで確認してごらん！
     
     */
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // アプリが起動したときに必要なコードはここに記述する
        XLOG("\(TAG): AppDelegate")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // アプリが非アクティブ（アプリがバックグラウンド）になる直前に呼ばれる
        // オンメモリで保存すべき情報がある場合はこのタイミングで保存する
        // でも、最近では、アプリの状態遷移に頼ることなく、適宜保存することが推奨されているよ
        XLOG("\(TAG): バックグラウンドになるよ")
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // アプリが非アクティブになった直後に呼ばれる
        XLOG("\(TAG): バックグラウンドになった")
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // アプリがアクティブになる直前に呼ばれる
        XLOG("\(TAG): フォアグランドになるよ")
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // アプリがアクティブになった直後によばれる
        // バックグラウンドから復帰したときに以前の状態に復元したい処理はここに記述
        XLOG("\(TAG): フォアグランドになった")
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // アプリが終了（バックグラウンドのアプリが終了）する直前に呼ばれる（タスクから削除されるときも）
        // 例えば、終了後になにか保存しておきたい情報等あればここに記述する
        XLOG("\(TAG): わし、はー死ぬるけー！")
        
    }


}

