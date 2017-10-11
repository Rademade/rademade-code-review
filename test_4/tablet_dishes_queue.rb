module QueueManagment
  class TabletDishesQueue
    class Sorter
      def sort(tablet_dishes)
        return [] if tablet_dishes.blank?
        tablet_dishes.sort_by do |order_dish|
          [
            - order_dish[:state],
            order_dish[:created_at]
          ]
        end
      end
    end

    class OrderDishSerializer < ActiveModel::Serializer
      attributes :id, :state, :created_at

      def self.serialize(order_dish)
        new(order_dish).serializable_hash
      end

      def state
        object.state_before_type_cast
      end
    end

    include Redis::Objects

    list :dishes, marshal: true
    attr_reader :tablet_id, :sorter, :serializer

    def initialize(tablet_id, order_dishes = [], sorter = Sorter.new, serializer = OrderDishSerializer)
      @tablet_id = tablet_id
      @sorter = sorter
      @serializer = serializer
      init_queue(order_dishes.to_a.map { |od| serializer.serialize(od) }) if order_dishes.present?
    end

    def delete(order_dish)
      new_dishes_array = queue.delete_if { |td| td[:id] == order_dish.id }
      init_queue(new_dishes_array)
    end

    def update(order_dish)
      serialized_order_dish = serializer.serialize(order_dish)
      new_dishes_array = queue.map do |tablet_dish|
        next tablet_dish unless tablet_dish[:id] == serialized_order_dish[:id]
        serialized_order_dish
      end
      init_queue(new_dishes_array)
    end

    # TODO: Refactor
    def add(order_dish)
      dishes.push serializer.serialize(order_dish)
      init_queue(queue)
    end

    def clear
      dishes.clear
    end

    def queue
      dishes.value || []
    end

    def id
      tablet_id
    end

    private

    def init_queue(tablet_dishes)
      dishes.clear
      sorted_tablet_dishes = sorter.sort(tablet_dishes)
      sorted_tablet_dishes.each { |tablet_dish| dishes << tablet_dish }
    end
  end
end
