# frozen_string_literal: true

require 'media_types/scheme/errors'
require 'media_types/object'

module MediaTypes
  class Scheme
    class OutputEmptyGuard
      class << self
        def call(*args, **opts, &block)
          new(*args, **opts).call(&block)
        end
      end

      def initialize(output, options, rules:)
        self.output = output
        self.options = options
        self.rules = rules
      end

      def call
        return unless MediaTypes::Object.new(output).empty?
        throw(:end, true) if allow_empty?
        raise_empty!(backtrace: options.backtrace)
      end

      private

      attr_accessor :output, :options, :rules

      def allow_empty?
        rules.allow_empty? || rules.required.empty?
      end

      def raise_empty!(backtrace:)
        raise EmptyOutputError, format(
          'Expected output, got empty at %<backtrace>s. Required are: %<required>s.',
          backtrace: backtrace.join('->'),
          required: rules.required.keys
        )
      end
    end
  end
end
