# -*- encoding: utf-8 -*-
require 'date'

Gem::Specification.new do |s|
  s.name          = 'appy'
  s.version       = ENV['APPY_VERSION'] || "1.master"
  s.date          = Date.today.to_s

  s.authors       = ['Magnus Holm']
  s.email         = ['judofyr@gmail.com']
  s.summary       = 'Library for structuring an application'
  s.homepage      = 'https://github.com/judofyr/appy'

  s.require_paths = %w(lib)
  s.files         = Dir["lib/**/*.rb"] + Dir["*.md"]
  s.license       = 'BlueOak-1.0.0'

  s.add_dependency 'cri', '~> 2.15.0'
end

