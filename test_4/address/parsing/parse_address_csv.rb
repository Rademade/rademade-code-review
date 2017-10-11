require 'csv'
require_relative 'get_street_type_by_ua_name'
require_relative 'district'
require_relative 'building'
require_relative 'street'

module Address
  module Parsing
    class  ParseAddressCsv

      def call(path:, rejected_path: "#{Rails.root}/rejected.csv")
        begin
          prev_street = nil

          CSV.foreach(path, headers: true, header_converters: :symbol) do |row|
            # row[0]. id
            # 1. Район
            # 2. Улица, номер дома, корпус, подьезд
            # 3. Количество этажей
            # 4. Количество подьездов
            # 5. Количество квартир

            next save_rejected(row) if Parsing::Street.reject_parsing?(row[2])
            
            begin
              current_street = extract_street(row)
              current_building = extract_building(row)
            rescue StandardError => e
              next save_rejected(row.push(e.message))
            end
            

            if prev_street && prev_street.same?(current_street)

              if duplicated_building = prev_street.find_same_building(current_building)
                duplicated_building.merge!(current_building)
              else
                prev_street.buildings.push(current_building)
              end

            else
              if prev_street
                prev_street.save 
              end
              current_street.buildings << current_building
              prev_street = current_street
            end
          end
        ensure
          rejected_csv_file.close
        end
      end
    
      private
      
      def save_rejected(row)
        rejected_csv_file << row
      end

      def rejected_csv_file
        @r_file ||= CSV.open("#{Rails.root}/rejected.csv", 'w')
      end

      def extract_building(row)
        building = Parsing::Building.parse(row[2])
        building.ext_id = row[0]
        building.floors = [row[3]]
        building.count_porches = row[4].to_i unless row[4].blank?
        building.count_flats = row[5].to_i unless row[5].blank?
        building
      end

      def extract_street(row)
        current_street = Parsing::Street.parse(row[2])
        current_street.district = Parsing::District.parse(row[1])
        current_street
      end
  end
end
end