//
//  MainView.swift
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
 
 ★ ボタンの四隅（実際はボタンを無い方するフレームView）を角丸にするには
 storyboardで対象となるViewの設定で「User Defined Runtime Attributes」に
 「layer.cornerRadius」値を「+」で追加して、Typeを「Number」ValueにRoundした数値を入れる
 
 */

class MainView: UIView {
    
    @IBOutlet weak var buttonFrame1: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var buttonFrame2: UIView!
    @IBOutlet weak var buttonFrame3: UIView!
    @IBOutlet weak var button4: UIButton!
    
    var buttons = Array<UIButton>()
    
    // ビューの初期設定
    func setup() {
        
        /*
         
         SVGデータは以下から入手できる
         https://www.flaticon.com
     
         ただし、そのままのSVGでは SVGKit でイメージ処理できないデータもあるので
         その場合は、以下のウェブツールで編集すれば利用可能
         https://vectr.com
         ↑
         編集したデータを取得するのは少し面倒、以下手順
         1, 編集した対象のSVGをbrowserに表示する
         2, browserのデバッガーで「要素」を表示させる
         3, デーバッグガーの「ソース」からXMLをコピーする
         4, xxx.svg として、XMLをペーストしたファイルを作成する
         
         */
        
        // ボタンを作成（これは動的にコードで作成している）
        let buttonFrames = [buttonFrame1, buttonFrame2, buttonFrame3]
        let buttonNames = ["corkscrew", "bottle", "glass-with-wine"]
        let buttonTitles = ["各入力オブジェクトのテスト", "テーブルビューのテスト", "WebAPIのテスト"]
        let buttonIconColors: [UInt32] = [0x0000ff, 0x00ff00, 0xff0000]
        for (index, name) in buttonNames.enumerated() {
            let button = UIButton(frame: buttonFrames[index]!.bounds.insetBy(dx: 4, dy: 4)) // 少しフレームの内側にする
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)  // タイトルの左に10の余白を付ける
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)                       // タイトルのフォントサイズを設定
            button.setTitle(buttonTitles[index], for: .normal)  // タイトル設定
            button.setTitleColor(UIColor.hex(rgb: 0x202020), for: .normal)                  // タイトルカラー
            button.contentHorizontalAlignment = .left   // 左寄せ
            let svgImage = SVGKImage(named: name)
            svgImage?.size = CGSize(width: button.bounds.size.height, height: bounds.size.height) // 高さで正方形のイメージ
            button.setImage(svgImage?.uiImage.tint(UIColor.hex(rgb: buttonIconColors[index])), for: .normal)  // SVGイメージをカラーを変えて設定
            button.tag = index + 1                  // ボタン番号を設定しておく
            buttons.append(button)                  // ボタンをarrayに登録
            buttonFrames[index]!.addSubview(button) // ボタンをframeに登録
        }
        
        // storyboardで設置したボタンの外観を変更する場合（コードに比べると若干デザインの自由度が下がる）
        let svgImage = SVGKImage(named: "shake")
        svgImage?.size = CGSize(width: button4.bounds.size.height, height: button4.bounds.size.height)
        button4.tintColor = UIColor.hex(rgb: 0xff6600)      // アイコンカラー
        button4.setImage(svgImage?.uiImage, for: .normal)   // タイトルカラー
        button4.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        button4.setTitleColor(UIColor.hex(rgb: 0x202020), for: .normal)
        button4.contentHorizontalAlignment = .left
        
        // その他の初期化
        resultLabel.text = ""
        
    }

}
