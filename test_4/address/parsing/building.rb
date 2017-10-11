module Address
  module Parsing
    class Building
     class << self
        def parse(raw_csv_string)
          _, building_part = raw_csv_string.split(',')
          new match_building(building_part)
        end

        private

        def match_building(raw_csv_string)
          _, number, letter = raw_csv_string.match(/\s*([\d\/]*)\s?([А-Я])?/).to_a
          _, housing = raw_csv_string.match(/.*к\.(\d)/).to_a
          _, porches = raw_csv_string.match(/.*\(п\.([\d\-]*)\)/).to_a
          _, alt_number, alt_number2 = raw_csv_string.match(/.*\(\=\s*([\d\/[А-Я]]*)\,?\s?([\d\/[А-Я]]*)?\)/).to_a

          {
            number: number.gsub("\s", '') + letter.to_s,
            count_porches: count_porches(porches),
            housings: [housing].compact,
            alt_numbers: [alt_number, alt_number2].delete_if(&:blank?)
          }

        end

        def count_porches(porches_str)
          return nil unless porches_str
          from, to = porches_str.split('-')
          return (to.to_i - from.to_i + 1) if to
          1
        end
     end


     attr_reader :number,:alt_numbers
     attr_accessor :housings, :count_porches

     attr_accessor :count_flats, :floors, :ext_id


     def initialize(number:, count_porches: nil, housings: [], alt_numbers: [])
       @number = number
       @alt_numbers = alt_numbers.unshift(number)
       @count_porches = count_porches
       @housings = housings
     end

     # Ensure streets are the same
     def same?(building)
      building.number == number 
     end

     def merge!(building)
      @alt_numbers = (alt_numbers + building.alt_numbers).uniq
      @housings += building.housings
      @count_porches += building.count_porches if count_porches && building.count_porches
      @count_flats = (count_flats + building.count_flats) if count_flats && building.count_flats
      @floors = floors + building.floors if floors && building.floors
     end

     def to_hash
       {
        ext_id: ext_id.to_i,
        housings: housings,
        count_porches: count_porches,
        floors: floors.compact,
        count_flats: count_flats
       }
     end
    end
  end
end