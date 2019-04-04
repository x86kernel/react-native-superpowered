
Pod::Spec.new do |s|
  s.name         = "RNSuperpowered"
  s.version      = "1.0.0"
  s.summary      = "RNSuperpowered"
  s.description  = <<-DESC
                  RNSuperpowered
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "x86kernel@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/x86kernel/react-native-superpowered.git", :tag => "master" }
  s.source_files  = "RNSuperpowered/**/*.{h,m}"
  s.requires_arc = true
  s.frameworks = 'MediaPlayer'


  s.dependency "React"

end

  
