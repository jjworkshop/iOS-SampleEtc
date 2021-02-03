//
//  Sample3ViewController.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class Sample3ViewController: UIViewController,
    UITableViewDelegate     // テーブルビューのデリゲート（セルのタップを取得したいなら忘れずに！）
{
    
    private let TAG = "サンプル3"
    private let disposeBag = DisposeBag()   // Rxのオブジェクト破棄の為に必要な定型処理
    private let presenter = Sample3ViewPresenter()
    private var mainView: Sample3View!
    
    var argument: Any? = nil    // 受け渡されるデータ
    
    // 画面がローディングされるときに呼ばれる
    // この画面は遷移してきたときには毎回呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        XLOG("\(TAG): ローディングされた")
        
        // 画面タイトル設定
        self.title = "Sample3-[\(argument as? String ?? "")]"
        
        // ControllerのViewにアクセスするため
        mainView = self.view as? Sample3View
        mainView.setup()
        
        // セルタップ取得のためにUITableViewのデリゲートを登録
        // タップ取得が必要無いなら不要だけどね
        mainView.tableView.delegate = self
        
        // オブザーバー登録
        setupObservers()
        
        // for Debugging : テストでいちいち入力するのが面倒なので (^^;
        presenter.findText.value = "東武伊勢崎線"
        
    }
    
    // MARK: - 各種処理
    
    // オブザーバーの登録
    private func setupObservers() {
        
        // 検索ボタンタップ
        mainView.findButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                XLOG("\(self.TAG): 検索ボタンタップ - 検索文字列[\(self.presenter.findText.value)]")
                self.closeSoftKyeboard()
                self.updateContent(self.presenter.findText.value)
            })
            .disposed(by: disposeBag)

        // 検索文字列入力
        mainView.findTextField.rx.text
            .map { text in
                // 入力のチェック（最大入力桁数のみチェック）
                let maxLength = 64
                let validText: String = text ?? ""
                if (self.mainView.findTextField.markedTextRange == nil) {
                    return (validText.count > maxLength)
                        ? String(validText[validText.startIndex..<validText.index(validText.startIndex, offsetBy: maxLength)])
                        : validText
                }
                return validText
            }
            .bind(to: presenter.findText)
            .disposed(by: disposeBag)
        // 双方向バインド
        presenter.findText.asObservable().bind(to: mainView.findTextField.rx.text).disposed(by: disposeBag)
        
        // テーブルビューアイテムのバインド設定（subscribe）
        presenter.list.asObservable()
            .bind(to: mainView.tableView.rx.items(cellIdentifier: "Sample3Cell", cellType: UITableViewCell.self)) { row, item, cell in
                // データを設定（これはもともとUITableViewCellが持ってるレイアウトを利用している） ★ Sample2 との差異に注意！！
                cell.textLabel?.text = "\(item.name) [\(item.prefecture)]"
                cell.detailTextLabel?.text = "lat:\(String(format: "%.2f", item.lat)) lon:\(String(format: "%.2f", item.lon))"
            }
            .disposed(by: disposeBag)

    }
    
    // リストを更新（presenter.loadItemsはスレッド処理）
    private func updateContent(_ findText: String) {
        mainView.showIndicator()
        presenter.loadItems(findText: findText, callback: { () -> Void in
            // コールバック処理（メインスレッドで戻されるのでUI処理をしてもOK）
            let count = self.presenter.list.value.count
            XLOG("検索結果: \(count)件")
            self.mainView.hideIndicator()
            // テーブルを先頭に移動
            if (self.presenter.list.value.count > 0) {
                //self.mainView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        })
    }
    // ソフトキーボードを閉じる
    func closeSoftKyeboard() {
        if let responder = findFirstResponder(self.view) {
            responder.resignFirstResponder()
        }
    }
    
    // MARK: - UITableViewデリゲート
    
    // セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 折角緯度経度が取得できてるので、マップアプリと連携してみる
        // URLスキームを利用するのよ。　超簡単じゃろ？

        // まずはタップしたデータを取得
        let station = presenter.list.value[indexPath.row]
        XLOG("タップしたのは: \(station.name)")

        // そんで、URLスキームを使って、Appleの標準マップアプリにパラメタ（緯度経度）を渡して連携
        // URLスキームについては、グルグルで検索してごらん、他のアプリや自分の別のアプリと連携するのに使うんだよ
        let urlScheme = "http://maps.apple.com/?daddr=\(station.lat),\(station.lon)&dirflg=d"
        let encodedUrl = urlScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = NSURL(string: encodedUrl!)! as URL
        if #available(iOS 10.0, *) {
            // iOSが10以上のばやい
            UIApplication.shared.open(url, options: [:])
        }
        else {
            // iOSが10未満のばやい
            UIApplication.shared.openURL(url)
        }
        // ↑
        // ちょっと手抜きでエラー処理は書いてないけどね！
        
        
    }
}

