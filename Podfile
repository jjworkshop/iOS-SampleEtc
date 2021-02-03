# よく使うライブラリ
#
# RxSwift/RxCocoa/RxGesture はリアクティブプログラミングのライブラリ
# SCLAlertView は 簡単にカッコイイAlertを表示するライブラリ
# SVGKit はSVGのアイコンを作画するライブラリ
# Alamofire は通信（WebAPIを処理）ライブラリ
#
# 変更した場合はターミナルから: pod update
#

platform :ios, "11.0"
inhibit_all_warnings!
use_frameworks!

target 'SampleEtc' do
  pod 'RxSwift',    '~> 4.x'
  pod 'RxCocoa',    '~> 4.x'
	pod 'RxGesture'
	pod 'SCLAlertView',:git => 'https://github.com/vikmeup/SCLAlertView-Swift.git'
	pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
	pod 'Alamofire'
end

post_install do |installer|
  swift4_pods = ["SCLAlertView"]
  installer.pods_project.targets.each do |target|
    if swift4_pods.include?(target.name)
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
