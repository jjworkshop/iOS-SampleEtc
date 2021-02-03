//
//  Sample1ViewController.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SCLAlertView

class Sample1ViewController: UIViewController {

    private let TAG = "サンプル1"
    private let disposeBag = DisposeBag()   // Rxのオブジェクト破棄の為に必要な定型処理
    private let presenter = Sample1ViewPresenter()
    private var mainView: Sample1View!
    
    var argument: Any? = nil    // 受け渡されるデータ
    
    // 画面がローディングされるときに呼ばれる
    // この画面は遷移してきたときには毎回呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        XLOG("\(TAG): ローディングされた")
        
        // 画面タイトル設定
        self.title = "Sample1-[\(argument as? String ?? "")]"
        
        // ControllerのViewにアクセスするため
        mainView = self.view as? Sample1View
        mainView.setup()
        
        // ナビゲーションのボタン設定
        self.navigationItem.setRightBarButtonItems([mainView.saveButton], animated: true)
        self.navigationItem.setLeftBarButtonItems([mainView.backButton], animated: true)

        // オブザーバー登録
        setupObservers()
        
        // データの初期値を設定
        setValueToScreen()
    }
    
    // 画面が閉じる前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
         呼出元の画面に何か情報を戻す（例として：TextFieldの値を戻している）
         NavigationController を利用していない場合は少し方法が異なる（自分で調べてね！）
         デリゲート手法を使わなくてもこのように戻せるけど、いずれにせよ戻り処理のメソッドは元のViewControllerで準備しなくてはダメ
         他にも色々値を戻す方法はある（共有エリアの UserDefaults.standard を使う等）
         */
        let mainViewController = self.navigationController?.topViewController as! MainViewController
        mainViewController.updateContent(arg: self.presenter.text.value)
    }
    
    // MARK: - 各種処理
    
    // データの初期値を設定
    private func setValueToScreen() {
        // データを読み出し
        let data = presenter.data
        // データを設定
        // Observable にデータを設定することで、双方向バインドしているUIオブジェクトに値が設定される
        presenter.setData(data)
    }
    
    // オブザーバーの登録
    private func setupObservers() {
        
        /*
         このコードはほぼ定型なので、テンプレートとして利用できる
         画面とデータを双方向に設定するときには、このような記述になるけど、UIオブジェクトによってRXの使い方が微妙に違う
         ちょっと長いロジックだけど
         .subscribe でデータが流れてくるので、そこで必要なロジックを書くだけね
         あとは .map（データ変換）や .filter（流れるデータの制限）を使いこなせれば◎
         */
        
        // saveButton（Navigationの保存ボタン）入力
        mainView.saveButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                XLOG("\(self.TAG): データを保存")
                self.presenter.saveData()
            })
            .disposed(by: disposeBag)
        
        // returnButton（Navigationの戻るボタン）入力
        mainView.backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                // 終了をチェック
                // Navigationの戻るをハンドリングしたい場合は、このように独自にボタンが制御できるようにする必要がある
                self.conformDismissal()
            })
            .disposed(by: disposeBag)
        
        // TextField入力
        mainView.textField.rx.text
            .map { text in
                // 入力の最大文字数の制限と入力禁止文字列を制限する場合
                // 例として5文字までの数値のみ入力可能
                let maxLength = 5
                let validText = self.removeInvalidText(text, isNumber: true)    // 数値以外は取り除く
                if (self.mainView.textField.markedTextRange == nil) {
                    return (validText.count > maxLength)
                        ? String(validText[validText.startIndex..<validText.index(validText.startIndex, offsetBy: maxLength)])
                        : validText
                }
                return validText
            }
            .bind(to: presenter.text)
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.text.asObservable().bind(to: mainView.textField.rx.text).disposed(by: disposeBag)
        // フィールドの入力完了を通知
        mainView.textField.rx.controlEvent(UIControl.Event.editingChanged)
            .subscribe( onNext: { [weak self] in
                if (self?.mainView.textField.markedTextRange == nil) {
                    // 入力が確定した
                    XLOG("\(self!.TAG): text - [\(self?.presenter.text.value ?? "")]")
                    self?.presenter.dirty.value = true
                }
            })
            .disposed(by: disposeBag)
        
        // TextView（メモ）入力
        mainView.memoView.rx.text
            .map { text in
                // 入力の最大文字数の制限と入力禁止文字列を制限する場合
                // 例として20文字までの入力禁止文字以外入力可能
                let maxLength = 20
                let validText = self.removeInvalidText(text, isNumber: false)   // 入力禁止文字は取り除く
                if (self.mainView.memoView.markedTextRange == nil) {
                    return (validText.count > maxLength)
                        ? String(validText[validText.startIndex..<validText.index(validText.startIndex, offsetBy: maxLength)])
                        : validText
                }
                return validText
            }
            .bind(to: presenter.memo)
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.memo.asObservable().bind(to: mainView.memoView.rx.text).disposed(by: disposeBag)
        // フィールドの入力完了を通知
        mainView.memoView.rx.didChange
            .subscribe( onNext: { [weak self] in
                if (self?.mainView.memoView.markedTextRange == nil) {
                    // 入力が確定した
                    XLOG("\(self!.TAG): text - [\(self?.presenter.memo.value ?? "")]")
                    self?.presenter.dirty.value = true
                }
            })
            .disposed(by: disposeBag)
        
        // Switch入力
        mainView.checkMark.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Bool in self.mainView.checkMark.isOn })
            .subscribe(onNext: { on in
                self.presenter.check.value = on
                XLOG("\(self.TAG): switch - [\(on)]")
                self.presenter.dirty.value = true
            })
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.check.asObservable().bind(to: mainView.checkMark.rx.isOn).disposed(by: disposeBag)
        
        // Segment入力
        mainView.segment.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Int in self.mainView.segment.selectedSegmentIndex })
            .subscribe(onNext: { idx in
                XLOG("\(self.TAG): segment - [\(idx)]")
                self.presenter.segment.value = idx
                self.presenter.dirty.value = true
            })
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.segment.asObservable().bind(to: mainView.segment.rx.selectedSegmentIndex).disposed(by: disposeBag)
        
        // Slider入力
        mainView.slider.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Float in self.mainView.slider.value })
            .subscribe(onNext: { value in
                XLOG("\(self.TAG): slider - [\(value)]")
                self.presenter.slider.value = value
                self.presenter.dirty.value = true
            })
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.slider.asObservable().bind(to: mainView.slider.rx.value).disposed(by: disposeBag)
        // Sliderの変更通知
        presenter.slider.asObservable()
            .subscribe(onNext: { rate in
                // %に変換した表示（少数点第二位をを四捨五入）
                let percent = (rate * 1000).rounded() / 10
                self.mainView.sliderValue.text = "\(percent)%"
            })
            .disposed(by: disposeBag)
        
        // 何か入力の変更があった場合の通知
        // 上記のデータストリームにデータが流れたときに「presenter.dirty.value = true」としている部分をトリガーにして
        // このasObservableに通知される（まぁこれもほぼ定型処理ね）
        presenter.dirty.asObservable()
            .subscribe(onNext: { dirty in
                if (dirty) {
                    XLOG("\(self.TAG): 入力の変更があった - [\(dirty)]")
                }
                self.mainView.saveButton.isEnabled = dirty
            })
            .disposed(by: disposeBag)
        
    }
    
    // テキストの入力不可の文字を取り除く
    private func removeInvalidText(_ text: String?, isNumber: Bool) -> String {
        if let str = text {
            if (isNumber) {
                // 数値以外は取り除く
                let splitNumbers = str.components(separatedBy: NSCharacterSet.decimalDigits.inverted)
                return splitNumbers.joined()
            }
            else {
                // 文字列の禁止文字を取り除く
                // 例として、「"」と「'」を取り除いている
                let excludes = CharacterSet(charactersIn: "\"'")    // <- 必要に応じて修正
                return str.components(separatedBy: excludes).joined()
            }
        }
        return ""
    }
    
    // 終了をチェック
    func conformDismissal() {
        if (presenter.dirty.value) {
            // 破棄or保存をダイアログで確認
            let alertView = SCLAlertView()
            alertView.addButton("はい") {
                // 前の画面に戻る
                self.navigationController?.popViewController(animated: true)
            }
            alertView.showInfo("確認", subTitle: "入力データを破棄しますか？", closeButtonTitle: "いいえ")
        }
        else {
            // 前の画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
    }
}

