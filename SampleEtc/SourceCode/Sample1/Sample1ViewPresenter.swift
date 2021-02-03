//
//  Sample1ViewPresenter.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import SVGKit

// 保存するデータクラス
class DataStocker: NSObject, NSCoding {
    var text:String!
    var memo:String!
    var check: Bool!
    var segment: Int!
    var slider: Float!
    init (text: String, memo: String, check: Bool, segment: Int, slider: Float) {
        self.text = text
        self.memo = memo
        self.check = check
        self.segment = segment
        self.slider = slider
    }
    // Deserialize
    required init(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.memo = aDecoder.decodeObject(forKey: "memo") as? String
        self.check = aDecoder.decodeObject(forKey: "check") as? Bool
        self.segment = aDecoder.decodeObject(forKey: "segment") as? Int
        self.slider = aDecoder.decodeObject(forKey: "slider") as? Float
    }
    // Serialize
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.memo, forKey: "memo")
        aCoder.encode(self.check, forKey: "check")
        aCoder.encode(self.segment, forKey: "segment")
        aCoder.encode(self.slider, forKey: "slider")
    }
}

class Sample1ViewPresenter {
    
    private let USER_DEFKEY_DATA = "DATA__VALUE"   // 保存キー名
    
    // 何か入力があった場合のObservable
    var dirty: Variable<Bool> = Variable(false)
    // 以下入力データObservable
    var text: Variable<String>  = Variable("")
    var memo: Variable<String>  = Variable("")
    var check: Variable<Bool>  = Variable(false)
    var segment: Variable<Int> = Variable(0)
    var slider: Variable<Float> = Variable(0.0)
    
    // データの読み出しと保存（SetterとGetterで実装）
    var data:DataStocker {
        /*
         ここでは「UserDefaults」をデータの保存場所として使っているが
         データベースやWebAPIにて取得したデータを設定する場合も多い
         */
        get{
            // データの読み出し
            let ud = UserDefaults.standard
            guard
                let archive = ud.object(forKey: USER_DEFKEY_DATA) as? NSData,
                let data = NSKeyedUnarchiver.unarchiveObject(with: archive as Data) as? DataStocker else {
                    // 保存データが無い場合は初期値
                    return DataStocker(text: "", memo: "", check: false, segment: 0, slider: 0.0)
            }
            return data
        }
        set(data){
            // データの書き出し
            let ud = UserDefaults.standard
            let archive = NSKeyedArchiver.archivedData(withRootObject: data)
            ud.set(archive, forKey: USER_DEFKEY_DATA)
        }
    }
    
    // データを設定
    func setData(_ data: DataStocker) {
        text.value = data.text
        memo.value = data.memo
        check.value = data.check
        segment.value = data.segment
        slider.value = data.slider
    }
    
    // データを保存
    func saveData() {
        // Setterにより保存される
        data = DataStocker(text: text.value,
                           memo: memo.value,
                           check: check.value,
                           segment: segment.value,
                           slider: slider.value)
        // dirty を落とす
        dirty.value = false
    }

}
