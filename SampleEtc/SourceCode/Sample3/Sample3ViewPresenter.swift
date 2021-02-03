//
//  Sample3ViewPresenter.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

// テーブルに表示するデータクラス
class StationDataItem {
    var name:String
    var prefecture:String
    var lat:Double
    var lon:Double
    init (id: Int, name: String, prefecture: String, lat: Double, lon: Double) {
        self.name = name
        self.prefecture = prefecture
        self.lat = lat
        self.lon = lon
    }
    func toString() -> String {
        // for Debugging
        return "name:\(name) [\(prefecture)] lat:\(lat) lon:\(lon)"
    }
}

class Sample3ViewPresenter {

    // 検索入力データObservable
    var findText: Variable<String>  = Variable("")
    
    // UIに対応する Observable
    var list: Variable<[StationDataItem]> = Variable([])    // データそのものを保管する
    
    // 例えば都道府県データなら
    var region: Variable<[String: String]> = Variable([:])
    func loadRegion() {
        region.value = [
            "01": "北海道",
            "02": "青森県",
            "03": "岩手県",
        ]
    }
    /*
     ↑
     これで、ViewControllerの以下の部分に
     ↓
     // テーブルビューアイテムのバインド設定（subscribe）
     presenter.list.asObservable()
     .bind(to: mainView.tableView.rx.items(cellIdentifier: "SampleXXCell", cellType: UITableViewCell.self)) { row, item, cell in
                                                                 ↑                                                 ↑
                                                            ここは変更しないとダメ                                  ここに region がバインドされる

    */
    
 
    // テーブルのアイテム取得（APIを利用している）
    func loadItems(findText: String, callback: @escaping () -> Void) {
        
        // 検索文字は漢字が含まれるのでURLエンコードする
        let findTextEncoded = findText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
        
        // リクエストURL組み立て
        let urlStr = "https://express.heartrails.com/api/json?method=getStations&line=\(findTextEncoded)"
        // ↑
        // 「HeartRails Express」のパブリックAPIを利用している（色々な電車情報を取得できるWebAPIを無償で提供している）
        // 詳しくは以下のURLを参照（無償だけど、公開するアプリに利用する場合はCopyrightを書かないとダメポ）
        // ↓
        // http://express.heartrails.com/api.html
        
        // 非同期スレッドでニュースJSON取得
        /*
         Alamofire ライブラリ（pod でインストールしてるやつ）を利用して簡潔に書ける
         これは非同期処理となり、レスポンス（responseJSON）で受けたBlockはメインスレッドとなる
         */
        AF.request(urlStr)
            .responseJSON{ response in
                // このBlockはメインスレッド
                var isValid = false
                switch(response.result) {
                    case .success(let json):
                        let resule = (json as! Dictionary<String, Dictionary<String, Any>>)["response"]
                        if let jsonStations: Array<Any> = ((resule!)["station"] as? Array<Any>) {
                            isValid = true
                            var dataItems: Array<StationDataItem> = Array()
                            for (index, jsonDic) in jsonStations.enumerated() {
                                if let jsonStation = jsonDic as? Dictionary<String, Any> {
                                    XLOG("jsonStation:\(jsonStation)")
                                    // JSONオブジェクトタイプからのデータ取り出しは、「.」ピリオド打ってコード補完で確認すればなんとなく解るよ（Let's try and error!!)
                                    dataItems.append(StationDataItem(
                                        id: index,
                                        name: jsonStation["name"] as? String ?? "",
                                        prefecture: jsonStation["prefecture"] as? String ?? "",
                                        lat: jsonStation["y"] as? Double ?? 0,
                                        lon: jsonStation["x"] as? Double ?? 0)
                                    )
                                    XLOG("stations:\(dataItems[index].toString())")
                                }
                            }
                            // 取得データを設定
                            self.list.value = dataItems
                        }
                        break
                    case .failure(_):
                        XLOG("ERROR: \(response.result)")
                        break
                }
                if (!isValid) {
                    // 取得できなかった
                    self.list.value = []
                }
                // 完了コールバック
                callback()
            }
    }
    
}
