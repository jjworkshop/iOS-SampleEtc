//
//  Extensions.swift
//  共通のUI拡張メソッド群
//
//  Created by Mitsuhiro Shirai on 2019/01/31.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

import UIKit

/*
    これらは、元からあるUIオブジェクトの機能を拡張している
    そのまま自分のprojectにファイル毎コピーすれば使える
 
 */


// UIImageを拡張
extension UIImage {

    // tintカラーを変更
    func tint(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
}

// UIColorを拡張
extension UIColor {
    
    // カラー指定をRGB+Alpha値で設定する（Alphaは省略可能）
    class func hex(rgb: UInt32, alpha: CGFloat = 1.0) -> UIColor{
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        return UIColor(red:r,green:g,blue:b,alpha:alpha)
    }
}

// UISearchBarを拡張
extension UISearchBar {
    
    // ブラーを無効にする
    func disableBlur() {
        backgroundImage = UIImage()
        isTranslucent = true
    }
    
    // テキストフィールドの取得
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "_searchField") as? UITextField
        }
    }
}


