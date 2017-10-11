module Address
  module Parsing
    class District
      def self.parse(raw_csv_string)
        return nil if raw_csv_string.blank?
        Address::District.find_or_create_by(name: raw_csv_string.strip)
      end
    end
  end
end