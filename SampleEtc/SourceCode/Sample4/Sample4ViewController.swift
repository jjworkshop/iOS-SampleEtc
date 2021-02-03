//
//  Sample4ViewController.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SCLAlertView
import SVGKit

class Sample4ViewController: UIViewController {

    private let TAG = "サンプル4"
    private let disposeBag = DisposeBag()   // Rxのオブジェクト破棄の為に必要な定型処理
    private let presenter = Sample4ViewPresenter()
    private var mainView: Sample4View!
    
    var argument: Any? = nil    // 受け渡されるデータ
    
    // 画面がローディングされるときに呼ばれる
    // この画面は遷移してきたときには毎回呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        XLOG("\(TAG): ローディングされた")
        
        // 画面タイトル設定
        self.title = "Sample4-[\(argument as? String ?? "")]"
        
        // ControllerのViewにアクセスするため
        mainView = self.view as? Sample4View
        mainView.setup()
        
        // オブザーバー登録
        setupObservers()
        
    }
    
    // MARK: - 各種処理
    
    // オブザーバーの登録
    private func setupObservers() {
        
        // 各種ボタンタップ
        for (index, button) in mainView.buttons.enumerated() {
            button.tag = index  // タップ時の指標となる
            button.rx.tap
                .subscribe(onNext: { [unowned self] in
                    XLOG("\(self.TAG): ボタン\(button.tag)タップ")
                    self.buttonTaped(type: Sample4View.DialogType(rawValue: button.tag)!)
                })
                .disposed(by: disposeBag)
        }
    }
    
    // ボタンタップ時の処理
    private func buttonTaped(type: Sample4View.DialogType) {
        switch type {
        case .ok:
            showDialogWithOk()
        case .yesNo:
            showDialogWithYesNo()
        case .select:
            showDialogWithMenu()
        case .entry:
            showDialogWithField()
        }
    }

    // 確認ダイアログ(OKボタンのみ）
    private func showDialogWithOk(_ text: String? = nil) {
        let alertView = SCLAlertView()
        let comment = text == nil ? "ほげほげぴっつぴ！" : text
        alertView.showWarning("たいとる", subTitle: comment, closeButtonTitle: "OK")
        //         ↑
        //       ここを showError / showWarning などに替えるとアイコンが変化するよ
        //       シュチュエーションに合わせて変更ね！
        //       詳しくは
        //       ↓
        //       https://github.com/vikmeup/SCLAlertView-Swift
    }
    
    // 確認ダイアログ(YES/NO）
    private func showDialogWithYesNo() {
        let alertView = SCLAlertView()
        alertView.addButton("YES") {
            // OKボタンダイアログを表示
            self.showDialogWithOk("するんですね！\nうふふ (^.^)")
        }
        alertView.showInfo("確認", subTitle: "今夜はどちらの枕？", closeButtonTitle: "NO")
    }
    
    // メニュー選択ダイアログ
    private func showDialogWithMenu() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false  // デフォルトボタン非表示
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("I like style of from back") {
            self.showDialogWithOk("わんこスタイルですね")
        }
        alertView.addButton("I'd like to do face to face") {
            self.showDialogWithOk("ボノボは猿だけど前からできます")
        }
        alertView.addButton("Any style is good, as you like♡") {
            self.showDialogWithOk("いやん♪")
        }
        alertView.showSuccess("Choice it", subTitle: "Which style do you like?")
    }
    
    // 入力フィールドのあるダイアログ
    // UserDefaultsを使ったデータ保存（Sample2でも使ってるけどね）
    private func showDialogWithField() {
        let appearance = SCLAlertView.SCLAppearance(
            // デフォルトボタンは利用しない＆アイコンはSVGデータを利用
            showCloseButton: false, showCircularIcon: true
        )
        let svgImage = SVGKImage(named: "pencil-edit-button")
        svgImage?.size = CGSize(width: 36, height: 36)
        let alertIcon = svgImage?.uiImage.tint(UIColor.white)
        let alert = SCLAlertView(appearance: appearance)
        let textField = alert.addTextField("Enter here!")   // テキストフィールドのプレスフォルダ
        if let text = presenter.loadData() {
            // 保存データがあればフィールドに設定
            textField.text = text
        }
        alert.addButton("登録") {
            if let text = textField.text {
                if (text.isEmpty) {
                    self.presenter.removeData()
                    self.showDialogWithOk("削除しますた！！")
                }
                else {
                    self.presenter.saveData(text: text)
                    
                    // エラーチェック処理をいれるならこの位置に！！
                    
                    self.showDialogWithOk("登録しますた！！")
                }
            }
        }
        alert.addButton("キャンセル") {
            // キャンセル時になにああればここに記述
        }
        alert.showEdit("入力テスト",
                       subTitle: "なんか入力してね！",
                       closeButtonTitle: nil, colorStyle: UInt(0x6a70e0), circleIconImage: alertIcon)
        //                                                      ↑
        //                                                      これはダイアログのカラーを変更している
    }
}

