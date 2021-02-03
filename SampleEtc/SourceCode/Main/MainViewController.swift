//
//  MainViewController.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

/*
 
 ★ ViewControllerのリネーム
 既存の「ViewController」を「MainViewController」に変更（ファイル名とクラス名）
 その後で、storyboard の対象 ViewController の CustomClassを「MainViewController」に変更
 
 ★ NavigationControllerの追加方法
 1, storyboard へ NavigationController をドロップ
 2, ドロップして出来た Root View Controller を削除
 3, NavigationControllerをCtrl+Clickして、Root View Controller をMainViewControllerに接続
 
 */

class MainViewController: UIViewController {

    private let TAG = "メイン"
    private let disposeBag = DisposeBag()   // Rxのオブジェクト破棄の為に必要な定型処理
    private let presenter = MainViewPresenter()
    private var mainView: MainView!
    
    // 画面がローディングされるときに呼ばれる
    // この画面はRootViewControllerなので、一度ローディングされると破棄されることは無い、つまり１度しか呼ばれない
    override func viewDidLoad() {
        super.viewDidLoad()
        XLOG("\(TAG): ローディングされた")
        
        // 画面タイトル設定
        self.title = "しっかり勉強しろぉ〜！"
        
        // ControllerのViewにアクセスするため
        mainView = self.view as? MainView
        mainView.setup()
        
        // オブザーバー登録
        setupObservers()
        
    }
    
    // 画面が最前面になったときに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // この画面が前面になったときに必要な処理があればここに記述
        XLOG("\(TAG): 画面が前面になった")
    }
    
    // 画面が背面にまわったときに呼ばれる
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // この画面が背面にまわったときに必要な処理があればここに記述
        XLOG("\(TAG): 画面が背面にまわった")
    }
    
    // セグエ指定で次の画面が開く前に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /*
         各画面にパラメタを渡している（赤ワインとか、ほげほげとかね）
         argument は Any なので、複数のパラメタを渡したいときはClassを作成してわたせばOK（受け側では適切にキャストして利用）
         NavigationController を利用していない場合は少し方法が異なる（自分で調べてね！）
         
         */
        
        let destinationNavigationController = segue.destination
        switch segue.identifier {
        case "Sample1Segue":
            (destinationNavigationController as? Sample1ViewController)?.argument = "赤ワイン"
        case "Sample2Segue":
            (destinationNavigationController as? Sample2ViewController)?.argument = ""
        case "Sample3Segue":
            (destinationNavigationController as? Sample3ViewController)?.argument = nil
        case "Sample4Segue":
            (destinationNavigationController as? Sample4ViewController)?.argument = "ほげほげ"
        default:
            break
        }
    }
    
    // 遷移先画面から値を受取処理をする
    func updateContent(arg: Any?) {
        XLOG("\(TAG): 遷移先画面から値を受け取った: [\(arg ?? "")]")
        if let text = arg as? String {
            mainView.resultLabel.text = "戻り値:\(text)"
        }
    }
    
    // MARK: - 各種処理
    
    // オブザーバーの登録
    private func setupObservers() {
        
        // 各種ボタンタップ
        for button in mainView.buttons {
            button.rx.tap
                .subscribe(onNext: { [unowned self] in
                    XLOG("\(self.TAG): ボタン\(button.tag)タップ")
                    self.showNextScreen(segue: "Sample\(button.tag)Segue")
                })
                .disposed(by: disposeBag)
        }
        
        mainView.button4.rx.tap
            .subscribe(onNext: { [unowned self] in
                XLOG("\(self.TAG): storyboardで作成したボタンタップ")
                self.showNextScreen(segue: "Sample4Segue")
            })
            .disposed(by: disposeBag)
        
    }
    
    // 画面遷移
    private func showNextScreen(segue: String) {
        XLOG("\(TAG): セグエ [\(segue)]")
        performSegue(withIdentifier: segue, sender: nil)
    }
    
}

