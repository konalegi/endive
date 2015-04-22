require 'reel'
require 'mustermann'
require 'jbuilder'

require 'endive/version'
require 'endive/core_ext'
require 'endive/dispatch'
require 'endive/routing'
require 'endive/support'

module Endive
  class << self
    @application = nil

    attr_writer :application
    attr_accessor :cache, :logger

    def application
      @application ||= Application.instance
    end

    delegate :initialize!, :initialized?, to: :application

    def configuration

    end

    def env
      @_env ||= Support::StringInquirer.new(ENV['ENDIVE_ENV'] || 'development')
    end

    def env=(environment)
      @_env = Support::StringInquirer.new(environment)
    end
  end
end