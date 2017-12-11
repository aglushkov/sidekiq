module Sidekiq
  class WeightedQueues
    def initialize(queues_options)
      @queues = init_queues(queues_options)
    end

    # Generates arguments for redis `brpop` method
    def names
      queues = @queues.dup

      Array.new(queues.size) do
        selected_index = roulette_wheel_selection(queues)
        queues.delete_at(selected_index).rname
      end
    end

    private

    def roulette_wheel_selection(queues)
      return 0 if queues.size == 1

      # Prepare a list of intervals from 0 to sum(weights)
      probs = probabilities(queues)

      # Generate a random number from 0 to sum(weights)
      random = rand * probs.last

      # Find the interval in which random number falls and return its index
      # Having probs sorted by weight allows us to:
      #  - find most probable queue faster
      #  - check only "less then" instead of checking `between`
      probs.index { |to| random < to }
    end

    def probabilities(queues)
      from = 0
      queues.map { |queue| from += queue.weight }
    end

    def init_queues(queues_options)
      queues = queues_options.map { |name, weight| Queue.new(name, weight) }
      queues.sort_by!(&:weight).reverse! # Sort by bigger weight
    end
  end
end
