Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '13.6'
s.name = "KumpeHelpers"
s.summary = "Swift Helper Files used in KumpeApps."
#s.requires_arc = true

# 2
s.version = "1.0.4"

# 3
s.license = { :type => "MIT", :file => "LICENSE"}

# 4 - Replace with your name and e-mail address
s.author = { "Justin Kumpe" => "helpdesk@kumpeapps.com" }
# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/kumpeapps/KumpeHelpers.git"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => 'https://github.com/kumpeapps/KumpeHelpers.git', :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'ReachabilitySwift'
s.dependency 'SwiftMessages'
s.dependency 'Alamofire-SwiftyJSON'
s.dependency 'Sync'

# 8
s.source_files = "KumpeHelpers/**/*.{swift,storyboard,xib,png}"

# 9
#s.resources = "KumpeHelpers/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5"

end
