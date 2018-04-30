Pod::Spec.new do |s|
  s.name         = "KyBoy"
  s.version      = "1.0"
  s.summary      = "Main application"
  s.homepage     = "https://github.com/redbug26/KyBoy"
  s.author       = { "Miguel Vanhove" => "github@kyuran.be" }
  s.source       = { :git => "https://github.com/redbug26/KyBoy.git", :tag => '1.0' }
  s.source_files = 'KyBoy/**/*.{h,m,mm,cpp}'
  s.resource     = 'KyBoy/**/*.{png,jpg}'
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }

  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target  = '9.0'

  s.user_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'KYBOY'
  }


end
