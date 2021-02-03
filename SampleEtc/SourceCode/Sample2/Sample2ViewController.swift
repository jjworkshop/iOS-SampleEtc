//
//  Sample2ViewController.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SCLAlertView

class Sample2ViewController: UIViewController,
    UITableViewDelegate,    // テーブルビューのデリゲート（忘れずに！）
    UISearchBarDelegate     // サーチバーのデリゲート（忘れずに！）
{

    private let TAG = "サンプル2"
    private let disposeBag = DisposeBag()   // Rxのオブジェクト破棄の為に必要な定型処理
    private let presenter = Sample2ViewPresenter()
    private var mainView: Sample2View!
    
    var argument: Any? = nil    // 受け渡されるデータ
    
    // 画面がローディングされるときに呼ばれる
    // この画面は遷移してきたときには毎回呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        XLOG("\(TAG): ローディングされた")
        
        // 画面タイトル設定
        self.title = "Sample2-[\(argument as? String ?? "")]"
        
        // ControllerのViewにアクセスするため
        mainView = self.view as? Sample2View
        mainView.setup()
        
        // 各種デリゲートを登録
        mainView.searchBar.delegate = self
        mainView.tableView.delegate = self
        
        // オブザーバー登録
        setupObservers()
        
        // 初期データを表示
        /*
         コメントアウトしているのが通常の初期データ表示処理となるが
         サンプルなので、初期表示時に lookUpID（id=7:"ふにゃふにゃ"） を指定してテーブルを移動している
         */
        // updateContent(presenter.findParameter.value) // ← 本来はこちら
        self.updateContent(self.presenter.findParameter.value, lookUpID: 7)
        
    }
    
    // MARK: - 各種処理
    
    // オブザーバーの登録
    private func setupObservers() {
        
        // 検索バーのオブザーバー登録（インクリメンタルサーチ用）
        setupSearchBar()
        
        // ソート条件セグメントタップ
        mainView.sortSegment.rx.controlEvent(.valueChanged).asObservable()
            .map({ () -> Int in self.mainView.sortSegment.selectedSegmentIndex })
            .subscribe(onNext: { idx in
                let newParam = self.presenter.findParameter.value.copy()
                newParam.isAsc = (idx == 0)
                self.presenter.findParameter.value = newParam   // 新しい検索条件を通知
            })
            .disposed(by: disposeBag)
        
        // 検索条件の変更を監視
        // ソートセグメント or 検索文字列 を変更するとここに通知がくる
        presenter.findParameter.asObservable()
            .skip(1)    // 初回はスキップ
            .subscribe(onNext: { param in
                self.updateContent(param)
            })
            .disposed(by: disposeBag)
        
        // テーブルビューアイテムのバインド設定（subscribe）
        presenter.list.asObservable()
            .bind(to: mainView.tableView.rx.items(cellIdentifier: "Sample2Cell")) { (row, id, cell) in
                // テーブルのセル情報を取得
                let cell = cell as! Sample2TableViewCell
                let item = self.presenter.getItem(id: id)
                // 左端のイメージを設定
                if let image = item?.imageName {
                    // イメージ有り
                    cell.cellImage.image = UIImage(named: image)
                    /*
                     以下の２つのPropertyは、画像のアスペクト比を保ったまま、画像をクリップさせている
                     UIImageView の contentMode の指定は幾つかあるから Googleで検索して調べてごらん
                     */
                    cell.cellImage.clipsToBounds = true
                    cell.cellImage.contentMode = .scaleAspectFill
                }
                else {
                    // イメージ無し
                    cell.cellImage.image = nil
                }
                // テキスト情報を設定
                cell.titleLabel.text = item?.title ?? "non title"
                cell.commentLabel.text = item?.comment
                // テーブルのセパレータを消す
                cell.layoutMargins = .zero
                cell.preservesSuperviewLayoutMargins = false
            }
            .disposed(by: disposeBag)
        
        // テーブルの選択変更を監視
        presenter.selectedList.asObservable()
            .filter({ $0 >= 0})
            .subscribe(onNext: { row in
                // テーブルが選択された
                let id = self.presenter.list.value[row]
                if let item = self.presenter.getItem(id: id) {
                    // とりあえずダイアログで内容を表示している
                    let alertView = SCLAlertView()
                    alertView.showInfo("確認", subTitle: "\(item.title ?? "non title")\nが選択されたよん！", closeButtonTitle: "OK")
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 検索バーのオブザーバー登録
    private func setupSearchBar() {
        
        /*
         少しややこしいけど、インクリメンタルサーチを利用する場合、ほぼこのまま利用できるので今の所はあまり考えなくてよし
         変更があるとしたら、検索条件のパラメタ（現在は検索文字とデータの並び順の２つ）が変わるくらい
         */
        
        mainView.searchBar.textField?.enablesReturnKeyAutomatically = false // リターンキーを常に有効に
        // インクリメンタルサーチのテキストを取得するためのObservable
        let incrementalSearchTextObservable = rx
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)))
            .debounce(0.3, scheduler: MainScheduler.instance)  // Wait a few msec
            .flatMap { [unowned self] _ in
                // 確定したsearchBar.textを取得
                Observable.just(self.mainView.searchBar.text ?? "")
        }
        // UISearchBarのクリア（×）ボタンや確定ボタンタップにテキストを取得するためのObservable
        let textObservable = mainView.searchBar.rx.text.orEmpty.asObservable()
        // 上記2つのObservableをマージ
        let searchTextObservable = Observable.merge(incrementalSearchTextObservable, textObservable)
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)  // Wait a few msec
            .distinctUntilChanged() // 変化があるまで文字列が流れないようにす（連続して同じテキストで検索しないように）
        // subscribeして流れてくるテキストを使用して検索
        searchTextObservable.subscribe(onNext: { [unowned self] text in
            let newParam = self.presenter.findParameter.value.copy()
            newParam.findText = text
            self.presenter.findParameter.value = newParam   // 新しい検索条件を通知
        }).disposed(by: disposeBag)
    }
    
    // リストを更新（presenter.loadItemsはスレッド処理）
    private func updateContent(_ param: Sample2ViewPresenter.FindParameter, lookUpID: Int? = nil) {
        mainView.showIndicator()
        presenter.loadItems(findParameter: param, callback: { () -> Void in
            // コールバック処理（メインスレッドで戻されるのでUI処理をしてもOK）
            let count = self.presenter.list.value.count
            XLOG("検索結果: \(count)件")
            self.mainView.hideIndicator()
            // lookUpIDを指定している場合は指定IDが見えるようにテーブルを移動
            var indexPath = IndexPath(row: 0, section: 0)
            if let id = lookUpID {
                if let idx = self.presenter.list.value.firstIndex(of: id) {
                    indexPath.row = idx
                    self.mainView.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    // スクロールバーを点滅（スクロールしたことがユーザーに解るようにするため）
                    self.mainView.tableView.flashScrollIndicators()
                    return
                }
            }
            // テーブルを先頭に移動
            if (self.presenter.list.value.count > 0) {
                self.mainView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        })
    }
    
    // ソフトキーボードを閉じる
    func closeSoftKyeboard() {
        if let responder = findFirstResponder(self.view) {
            responder.resignFirstResponder()
        }
    }

    // MARK: - UISearchBarDelegateデリゲート
    
    // 入力内容の確定前処理
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    // Enterキーが押された
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeSoftKyeboard()
    }
    
    // MARK: - UITableViewデリゲート
    
    // セルバックカラー変更
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.hex(rgb: 0xeeffe1)   // 偶数行
        }
        else {
            cell.backgroundColor = UIColor.hex(rgb: 0xfefff1)   // 奇数行
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.default
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.hex(rgb: 0xffb363)   // 選択行
        cell.selectedBackgroundView =  selectedView
    }
    
    // セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)    // 選択解除
        closeSoftKyeboard()
        // 選択を通知
        presenter.selectedList.value = indexPath.row
    }
    
}

