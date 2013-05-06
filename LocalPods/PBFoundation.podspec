Pod::Spec.new do |s|
  s.name      = 'PBFoundation'
  s.version   = '0.0.1'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.summary   = 'PBFoundation is a collection of useful Mac and iOS utilities'
  s.homepage  = 'https://github.com/nickbolton/PBFoundation'
  s.requires_arc = true 
  s.author    = { 'nickbolton' => 'nick@deucent.com' }             
  s.source    = { :git => 'https://github.com/nickbolton/PBFoundation.git',
                  :commit => '451aff0011e7eda2f55879b4596bf15350fa1cbf'}
  s.osx.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'Mac', 'Mac/**/*.{h,m}'
  s.ios.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'iOS', 'iOS/**/*.{h,m}'
  s.prefix_header_contents = '#import "PBFoundation.h"'
  s.osx.frameworks    = 'Cocoa', 'QuartzCore', 'CoreData', 'Carbon', 'CoreServices', 'QuickLook'
  s.license   = {
    :type => 'MIT',
    :text => <<-LICENSE
              Copyright (C) 2011-2013, Pixelbleed LLC

              Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

              The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

              THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    LICENSE
  }
end
