Pod::Spec.new do |s|
  s.name         = "YLDragView"
  s.version      = "0.0.1"
  s.summary      = "YLDragView."
  s.description  = <<-DESC
                    拖拽视图、可移动视图、悬浮可拖动视图
                   DESC

  s.homepage     = "https://github.com/jianghat/YLDragView"
  s.license      = "MIT"
  s.author       = { "jiang" => "549488710@qq.com" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/jianghat/YLDragView.git", :tag => "#{s.version}" }
  s.source_files  = 'YLDragView.{swift}'
  s.framework  = 'UIKit'
  s.requires_arc = true

end
