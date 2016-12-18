#
# Be sure to run `pod lib lint TVAlert.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TVAlert"
  s.version          = "1.0.0"
  s.summary          = "tvOS style alerts."

  s.description      = <<-DESC
                       A UIAlertController style library that mimics tvOS alerts.
                        DESC

  s.homepage         = "https://github.com/adrum/tvalert"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Austin Drummond" => "adrummond7@gmail.com" }
  s.source           = { :git => "https://github.com/adrum/tvalert.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/adrummond7'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.swift'
#  s.resource_bundles = {
#    'TVAlert' => ['Pod/Assets/*.png']
#  }

end
