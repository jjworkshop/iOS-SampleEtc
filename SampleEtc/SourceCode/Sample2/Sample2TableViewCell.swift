//
//  Sample2TableViewCell.swift
//  SampleEtc
//
//  Created by Mitsuhiro Shirai on 2019/02/21.
//  Copyright © 2019年 Mitsuhiro Shirai. All rights reserved.
//

/*
 
 ★ クラスファイルを作成するとき
 「Also create XIB file」にチェックを入れて作成する
 そうすることで、「Sample2TableViewCell.swift」に加えて、「Sample2TableViewCell.xib」も自動で作成される
 「Sample2TableViewCell.xib」にテーブルのセルのレイアウトを定義する
 
 このクラスは、基本的には XIB からUIオブジェクトをリンクする以外に編集することはほぼ無い
 UIパーツのフォルダとして使うのみ
 
 */


import UIKit

class Sample2TableViewCell: UITableViewCell {
    
    /*
     Main.storyboard のときと同じようにD&Dする
    */
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
