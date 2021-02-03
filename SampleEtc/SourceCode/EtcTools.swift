//
//  EtcTools.swift
//  共通メソッド群
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

/*
    頻繁につかう処理などをここに記述してある
    そのまま自分のprojectにファイル毎コピーすれば使える
 
 */


// デバッグプリント
// 使用例：XLOG(String(format: "abc - %d", 10))
func XLOG(_ obj: Any?,
          file: String = #file,
          function: String = #function,
          line: Int = #line) {
    #if DEBUG
    // デバッグモードのみ出力
    let pathItem = String(file).components(separatedBy: "/")
    let fname = pathItem[pathItem.count-1].components(separatedBy: ".")[0]
    if let obj = obj {
        print("D:[\(fname):\(function) #\(line)] : \(obj)")
    } else {
        print("D:[\(fname):\(function) #\(line)]")
    }
    #endif
}

// スレッドチェック
// UIの更新はメインスレッドでしか許されない
// RXや通信ライブラリのコールバック処理で、どのスレッドで処理されているか解らない時はこれでチェック
func checkThread() {
    if (Thread.isMainThread) {
        XLOG("ここはメインスレッド内")
    }
    else {
        XLOG("ここはワーカースレッド内")
    }
}

// ファーストレスポンダーを探す
// 入力フィールド等で現在フォーカスのあるオブジェクトね
func findFirstResponder(_ view: UIView!) -> UIView? {
    if (view.isFirstResponder) {
        return view
    }
    for subView in view.subviews {
        if (subView.isFirstResponder) {
            return subView
        }
        let responder = findFirstResponder(subView)
        if (responder != nil) {
            return responder;
        }
    }
    return nil;
}
