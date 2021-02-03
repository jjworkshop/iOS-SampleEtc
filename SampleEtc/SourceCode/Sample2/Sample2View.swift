//
//  Sample2View.swift
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

class Sample2View: UIView {
        
    @IBOutlet weak var headerFrame: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // 処理中のインジケータ
    let indicator = UIActivityIndicatorView(style: .whiteLarge)
    private var indicatorCounter = 0
    
    // ビューの初期設定
    func setup() {

        // インジケータ設定
        indicator.color = UIColor.hex(rgb: 0x19cfc6)
        indicator.center = CGPoint(x: self.center.x, y: self.bounds.size.height / 2)
        self.addSubview(indicator)
        
        // サーチバーの外観を調整
        searchBar.disableBlur() // サーチバーの背景を消している
        searchBar.backgroundColor = UIColor.hex(rgb: 0x404040)
        headerFrame.backgroundColor = UIColor.hex(rgb: 0x404040)

        // テーブルビューにカスタムセルを登録
        // 注意: このforCellReuseIdentifierの項目は、作成した「Sample2TableViewCell.xib」の
        //      右のプロパティーリスト「Identifier」にも必ず設定 ★重要
        //      TableViewCellを一意に認識するための指標になる
        tableView.register(UINib(nibName: "Sample2TableViewCell", bundle: nil), forCellReuseIdentifier: "Sample2Cell")
        
        // テーブルビューのセパレータを消す
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.cellLayoutMarginsFollowReadableWidth = false

    }

    // インジケータの表示／非表示
    /*
     カウンター（indicatorCounter）を使っているのは、この画面で複数処理中依頼があった場合に
     全ての処理がおわってインジケータを消すため
     何故複数処理がリクエストされるのかというと、データ読み込みはワーカースレッドで処理するため
     処理をリクエストするとすぐにUIスレッドに復帰するため、前の処理が未完でも再度リクエストできる
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
