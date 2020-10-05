Pod::Spec.new do |s|
  s.name             = "SZMentionsSwift"
  s.version          = "2.1.3"
  s.summary          = "Highly customizable mentions library"
  s.description      = "Mentions library used to help manage mentions in a UITextView"
  s.homepage         = "http://www.stevenzweier.com"
  s.license          = 'MIT'
  s.author           = { "Steven Zweier" => "steve.zweier+mentions@me.com" }
  s.source           = { :git => "https://github.com/szweier/SZMentionsSwift.git", :tag => s.version.to_s }
  s.platform     = :ios, '10.1'
  s.requires_arc = true
  s.source_files = 'Classes/**/*'
end
