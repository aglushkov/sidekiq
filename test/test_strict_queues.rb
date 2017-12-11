# frozen_string_literal: true
require_relative 'helper'
require 'sidekiq/api'
require 'sidekiq/strict_queues'

class TestStrictQueues < Sidekiq::Test
  describe Sidekiq::StrictQueues do
    def queues
      Sidekiq::StrictQueues.new(foo: 0, bar: 0, bazz: 0)
    end

    it 'returns all queues in the order they were provided' do
      assert_equal(queues.names, ['queue:foo', 'queue:bar', 'queue:bazz'])
    end
  end
end
