//
//  Sample1View.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import SVGKit

/*
 
 このクラスを作ったら、storyboard の対象 View（ViewController直下の[View]のCustomClassをに設定するのを忘れずに
 その後で、storyboard から各オブジェクトをリンクする
 
 */

class Sample1View: UIView {
        
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var memoView: UITextView!
    @IBOutlet weak var checkMark: UISwitch!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValue: UILabel!
    
    // 独自のなNavigationボタン
    let saveButton: UIBarButtonItem = UIBarButtonItem(title: "保存", style: .plain , target: nil, action: nil)
    let backButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    
    // ビューの初期設定
    func setup() {
        
        // テキストビュー（メモ）に枠を作成
        memoView.layer.borderWidth = 1.0    // 枠のサイズ
        memoView.layer.borderColor = UIColor.hex(rgb: 0xe0e0e0).cgColor // 枠の色
        memoView.layer.cornerRadius = 6.0   // コーナーのラウンド（角丸サイズ）
        // 戻るボタンをイメージ（SVG）を設定
        let backButtonImage = SVGKImage(named: "return-arrow")
        backButtonImage?.size = CGSize(width: 20, height: 20)
        backButton.image = backButtonImage?.uiImage
        backButton.tintColor = UIColor.hex(rgb: 0x0060ff)
        // 保存をディセーブルにしておく
        saveButton.isEnabled = false
    }

}
