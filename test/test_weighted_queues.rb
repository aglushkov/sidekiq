# frozen_string_literal: true
require_relative 'helper'
require 'sidekiq/api'
require 'sidekiq/weighted_queues'

class TestWeightedQueues < Sidekiq::Test
  describe Sidekiq::WeightedQueues do
    def sort_queues
      @queues ||= Sidekiq::WeightedQueues.new(urgent: 50, default: 30, low: 20)
    end

    def percent_of_first(queue_name, results_batch)
      count = results_batch.select { |result| result.first == queue_name }.count
      count.to_f / results_batch.count * 100
    end

    def be_approximatly(percent, value)
      error = 5 # +/- 5%
      (value > percent - error) && (value < percent + error)
    end

    it 'returns all queues' do
      assert_equal(sort_queues.names.sort, ['queue:default', 'queue:low', 'queue:urgent'])
    end

    it 'sorts queues by probabilities' do
      results_batch ||= 1000.times.map { sort_queues.names }
      assert(be_approximatly(50, percent_of_first('queue:urgent', results_batch)))
      assert(be_approximatly(30, percent_of_first('queue:default', results_batch)))
      assert(be_approximatly(20, percent_of_first('queue:low', results_batch)))
    end
  end
end
