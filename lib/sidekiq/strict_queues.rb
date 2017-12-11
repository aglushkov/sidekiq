module Sidekiq
  class StrictQueues
    attr_reader :names

    def initialize(queues_options)
      @names = parse(queues_options)
    end

    private

    def parse(queues_options)
      queues = queues_options.map { |name, _weight| Queue.new(name) }
      queues.map!(&:rname)
    end
  end
end
