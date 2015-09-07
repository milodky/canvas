require 'active_support/all'
require 'canvas/palette'
require 'canvas/crayon'
require 'canvas/pigment'
require 'canvas/version'
require 'yaml'
require 'andand'

module Canvas
  include Crayon
  include Palette
  extend self
end
