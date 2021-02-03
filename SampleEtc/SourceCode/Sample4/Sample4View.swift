//
//  Sample4View.swift
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

class Sample4View: UIView {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var buttons = Array<UIButton>()
    
    // ダイアログタイプ指定
    enum DialogType: Int {
        case ok = 0
        case yesNo = 1
        case select = 2
        case entry = 3
    }
    
    // ビューの初期設定
    func setup() {

        // ボタンの参照作成
        buttons = [button1, button2, button3, button4]
        
    }

}
