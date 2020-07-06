source 'https://cdn.cocoapods.org/'
platform :ios, '13.0'
use_frameworks!

def common_ntge
  pod 'NtgeCore', :path => '../ntge', :testspecs => ['Tests']
end

target 'CoreDataStack' do

  # Pods for CoreDataStack

  target 'CoreDataStackTests' do
    # Pods for testing
    common_ntge
  end

end

target 'Mailway' do

  # Pods for Mailway
  common_ntge

  # ui
  pod 'Floaty', '~> 4.2.0'
  pod 'GrowingTextView', '~> 0.7.2'
  pod 'UITextView+Placeholder', '~> 1.4.0'
  
  # misc
  pod 'SwiftGen', '~> 6.2.0'

  target 'MailwayTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MailwayUITests' do
    # Pods for testing
  end

end
