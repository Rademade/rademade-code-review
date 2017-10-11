module Address
  module Parsing
    class Street
      class << self

        def parse(raw_csv_string)
          street_part, _ = raw_csv_string.split(',')
          new match_street(street_part)
        end

        def reject_parsing?(raw_csv_string)
          raw_csv_string =~ /\(\=\s?[А-Я].*\)/
        end

        def match_street(raw_csv_string)
          _, raw_street_name, street_type = raw_csv_string.match(/.*Будинок\:\s*(.*)[[:space:]]+(.*)$/).to_a
          _, street_name, old_name = match_street_old_name(raw_street_name)

          {
            name: street_name.strip,
            type: street_type.gsub('.', ''),
            old_name: old_name
          }
        end

        def match_street_old_name(str)
          if str =~ /\(.*\)/
            str.match(/(.*)\((.*)\)/).to_a
          else
            ['', str, '']
          end
        end
      end
      
      attr_reader :name, :type, :old_name
      attr_accessor :district, :buildings

      def initialize(name:, type:, old_name: nil)
        @name = name
        @type = Parsing::GetStreetTypeByUaName.new.call(type)
        @old_name = old_name
        @buildings = []
      end

      def find_same_building(building)
        @buildings.find {|bld| bld.same?(building) }
      end

      def same?(street)
        (street.name == name) && (street.type == type)
      end

      def save
        wrap_in_transaction do
          if street = Address::Street.find_by(name: name, street_type: type)
              Address::StreetsBuilding.create(
                generate_streets_buildings.each { |str_building| str_building[:street_id] =  street.id }
              )
          else
            Address::Street.create(to_hash)
          end
        end
      end

      private

      def wrap_in_transaction
        ActiveRecord::Base.transaction do
          yield
        end
      end

      def to_hash
        {
          name: name,
          street_type: type,
          old_name: old_name,
          district_id: district_id,
          streets_buildings_attributes: generate_streets_buildings
        }
      end

      def generate_streets_buildings
        buildings.map do |bld|  
          {
            building_numbers: bld.alt_numbers,
            building_attributes: bld.to_hash
          }
        end
      end

      def district_id
        return nil unless district
        district.id
      end
    end
  end
end