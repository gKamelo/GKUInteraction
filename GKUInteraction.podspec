Pod::Spec.new do |s|
  s.name         = "GKUInteraction"
  s.version      = "0.1.0"
  s.summary      = "Helper classes to decouple interaction between instances for Objective-C"
  s.homepage     = "https://github.com/gKamelo/GKUInteraction"
  s.license      = "MIT"
  s.author       = { "Kamil Grzegorzewicz" => "grzegorzewicz.k@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/gKamelo/GKUInteraction.git", :tag => s.version.to_s }
  s.source_files = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc = true
end
