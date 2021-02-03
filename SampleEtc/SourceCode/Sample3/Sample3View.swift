//
//  Sample3View.swift
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

class Sample3View: UIView {
        
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // 処理中のインジケータ
    let indicator = UIActivityIndicatorView(style: .whiteLarge)
    private var indicatorCounter = 0

    // ビューの初期設定
    func setup() {

        // ★ Sample2 との差異に注意！！
        // カスタムビューセルを使わない場合は、テーブルビューセル登録は storyboard で追加する
        // なので、「tableView.register(xxx ...」は記述しなくてもよい。セルのスタイルや cellIdentifier の指定は storyboard の方で行っている
        
        // インジケータ設定
        indicator.color = UIColor.hex(rgb: 0x19cfc6)
        indicator.center = CGPoint(x: self.center.x, y: self.bounds.size.height / 2)
        self.addSubview(indicator)
        
        // テーブルビューの外観変更
        tableView.layer.cornerRadius = 10.0                     // 角丸にする
        tableView.layer.borderWidth = 1.0                       // 枠のサイズ
        tableView.layer.borderColor = UIColor.orange.cgColor    // 枠の色
        tableView.separatorInset = .zero                        // セパレーター左の余白を無くす
        tableView.tableFooterView = UIView(frame: .zero)        // データの無い部分のセパレータを消す
        
    }

    // インジケータの表示／非表示
    /*
     これは Sample2View.swift と同じ処理
     本来、このような場合は、UIView に１つサブクラスを挟んで（例えば CommonView）共通で利用できるクラスを作るのがベター
     サンプルではなるべくシンプルにしてるので、サブクラス化は利用していない
     */
    func showIndicator() {
        if (indicatorCounter == 0) {
            indicator.startAnimating()
        }
        indicatorCounter += 1
    }
    func hideIndicator() {
        indicatorCounter -= 1
        if (indicatorCounter <= 0) {
            indicatorCounter = 0
            indicator.stopAnimating()
        }
    }
}
