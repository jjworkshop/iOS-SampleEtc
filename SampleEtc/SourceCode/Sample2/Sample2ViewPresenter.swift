//
//  Sample2ViewPresenter.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift


// テーブルに表示するデータクラス
/*
 これはシリアライズしていない
 このSampleでは何処かに保存してないのでシリアライズの必要が無い
 ただし、こDB等にこのオブジェクトをそのまま保存する場合はシリアライズするコードが必要になる
 */
class ListDataItem {
    var id:Int
    var imageName:String!
    var title:String!
    var comment: String!
    init (id: Int, imageName: String, title: String, comment: String) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.comment = comment
    }
}

class Sample2ViewPresenter {

    // 検索パラメータークラス（クラス内のインナークラス）
    open class FindParameter {
        var findText: String? = nil // 検索文字列
        var isAsc: Bool = true      // データの並び
        init () { }
        init (findText: String?, onlyTitle: Bool, isAsc: Bool) {
            self.findText = findText
            self.isAsc = isAsc
        }
        func copy() -> FindParameter {
            let instance = FindParameter()
            instance.findText  = self.findText
            instance.isAsc  = self.isAsc
            return instance
        }
    }
    
    // テーブルデータ
    var data = Array<ListDataItem>()
    
    // UIに対応する Observable
    let list: Variable<[Int]> = Variable([])    // データの「id」を保管する
    let findParameter: Variable<FindParameter> = Variable(FindParameter())
    let selectedList: Variable<Int> = Variable(-1)
    
    // 各種処理
    
    // テーブルデータをIDで取得
    func getItem(id: Int) -> ListDataItem? {
        
        /*
         この filter は配列を処理するときに非常に便利な関数なので覚えておくと◎よ
         他にも、配列を処理する関数として mapやsorted ってのがあり、これは型を変換したりソートしたりできるので便利（loadItemsの中で使ってるよ）
         
         もし filter を使って書かない場合は以下のようになる（データが大量だとforで回すと処理はあまり効率が良くない）
         ↓
         for item in data {
         if (item.id == id) {
         return item
         }
         }
         return nil
         
         */
        
        let result = data.filter{ $0.id == id }
        return result.count != 0 ? result[0] : nil
    }
    
    // テーブルのアイテム取得
    // ここは通常はDBにデータを問い合わせるとか、WebAPIに処理を問い合わせるかするのでスレッド処理にしている
    // 何故かというと、処理に時間がかかるとUIの反応が悪くなるので、普通はバックグラウンド（ワーカースレッド）で処理する
    // これはSampleなので、スレッドにしなくてもいいんだけどね
    func loadItems(findParameter: FindParameter, callback: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // このBlockがスレッド（UIが処理されるメインスレッドとは別のワーカースレッド）になる
            
            /* ★コメント
             これはSampleなので、呼び出す都度初期データを設定した後にデータ抽出しているけど
             普通は、DBやWebAPIに直接問合せするので以下「loadAllData_for_debugging」のような処理をすることは無い
            */
            self.loadAllData_for_debugging()
            
            // 処理パラメタをスレッド用にコピー
            let param = findParameter.copy()
            XLOG("検索開始(in Thread) text: \(param.findText ?? "--") Asc:\(param.isAsc)")
            
            // 以下パラメタによる抽出とソート処理
            /*　★重要ポイント
             これはサンプルコードなので、クラス変数の「data」を直接処理しているが、通常データの実態はDBとかネット上にある
             なので、実際の抽出とソート処理は、アプリ内部のDBが対象なら、ここにSQL等で抽出とソートするし
             ネット上にデータがあるなら、APIでリクエストしてデータを受け取る（その場合、その対象APIの中で抽出とソート処理が行われる）
             */
            let newData = {() -> Array<ListDataItem> in
                // 抽出
                if let findText = param.findText?.lowercased() {
                    if (!findText.isEmpty) {
                        // title もしくは comment に検索文字が存在するデータを抽出（大文字小文字を無視）
                        return self.data.filter { $0.title.lowercased().contains(findText) || $0.comment.lowercased().contains(findText)}
                    }
                }
                // 対象は全て（swiftでの配列の代入は参照ではなく実体コピー）
                return self.data
            }().sorted(by: { p1, p2 in
                // ソート
                return param.isAsc ? p1.title < p2.title : p1.title > p2.title
            })
            
            // 抽出とソート処理結果を通知（結果はidだけ保存）
            self.list.value = newData.map{ $0.id }
            
            // 処理中動作の確認のための1秒スリープ（これはリリース時には必要ない）
            #if DEBUG
                sleep(1)
            #endif
            
            // 処理が完了したらコールバックする
            DispatchQueue.main.async {
                // 完了コールバックはメインスレッドで処理
                callback()
            }
            
        }
    }
    
    // テスト用のデータを設定している
    // これはサンプルのための仮のデータ処理で、通常このような処理は必要ない（上記★コメントを参照のこと）
    private func loadAllData_for_debugging() {
        data.removeAll()
        let titles =   ["1,おふらんすワイン","2,いたーーりあんワイン","3,チリワイン","4,山梨ワイン","5,やまぐちワイン","6,ほげほげ","7,ふがふが","8,ふにゃふにゃ"]
        let comments = ["コメントその１\n２行目はこのような感じ","コメント２-A","コメント３-AB","コメント４","コメント５-ABC","コメント６-ABCD","コメント７-ABCDE","コメント８-ABCDEF"]
        for i in 0..<8 {
            // id は 100〜採番している（特に意味はないけど、デバッグで row と区別するためね）
            data.append(ListDataItem(id: i+100, imageName: "sample2_\(String(format: "%02d", i+1))", title: titles[i], comment: comments[i]))
        }
    }
    
}
