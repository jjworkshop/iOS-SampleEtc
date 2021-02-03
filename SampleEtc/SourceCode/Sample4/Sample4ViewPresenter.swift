//
//  Sample4ViewPresenter.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

class Sample4ViewPresenter {
    
    // UserDefaults に保存するデータは Key/Value のペアとなる
    // Keyは一意となる文字列
    // Valueは文字列や数値やBoolean値等はデフォルトで保存するメソッドが用意されているが
    // クラス等のオブジェクトを保存する場合はシリアライズして保存する必要がある（Sample1ViewPresenter.swift で使ってる）
    private let ud = UserDefaults.standard
    private let ANY_DEFINE_KEY = "ANY_DATA"     // 保存するキー
    
    // データ読み出し
    func loadData() -> String? {
        if let text = ud.object(forKey: ANY_DEFINE_KEY) as? String {
            return text
        }
        return nil
    }
    
    // データ保存
    func saveData(text: String) {
        ud.set(text, forKey: self.ANY_DEFINE_KEY)
    }
    
    // データ削除
    func removeData() {
        ud.removeObject(forKey: self.ANY_DEFINE_KEY)
    }

}
