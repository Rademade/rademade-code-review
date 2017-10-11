module Address
  module Parsing
    class GetStreetTypeByUaName
      TYPES = {
        street: 'вулиця',
        boulevard: 'бульвар',
        avenue: 'проспект',
        alley: 'провулок',
        road: 'шосе',
        quay: 'набережна',
        ascent: 'узвіз',
        square: 'площа'
      }.freeze

      def call(name_partial)
        name = name_partial.delete('.')
        TYPES.find { |_key, value| value.include?(name) }[0]
      end
    end
  end
end
