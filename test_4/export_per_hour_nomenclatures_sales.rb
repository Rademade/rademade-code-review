module Schedules
  class ExportPerHourNomenclaturesSales < Worker
    def call(options = default_options)
      parsed_options = parse_options(options)
      store_nomenclatures_sales(parsed_options.fetch(:delivery_point_code)) if opened_operational_day_with_shifts_exist?
      check_or_create_folder(parsed_options.fetch(:folder))
      export_nomenclatures_sales_to_file(parsed_options)
    end

    private

    def store_nomenclatures_sales(delivery_point_code = 'all')
      Reports::StoreNomenclaturesSales.new(delivery_point_code: delivery_point_code).store
    end

    def export_nomenclatures_sales_to_file(delivery_point_code: 'all', folder: '/home/reports')
      report_records = today_reports.where('report_data @> ?', { dp_code: delivery_point_code }.to_json)
      file_name = "Article_sales_#{DateTime.now.strftime('%d%m_%H%M')}_#{delivery_point_code}"
      Reports::ExportNomenclaturesSalesReport.new(report_records: report_records)
                                             .save_to_file(
                                               folder: folder,
                                               file_name: file_name
                                             )
    end

    def today_reports
      @today_reports ||= SalesReport.where(
        'created_at > :start_day AND created_at < :end_day',
        start_day: DateTime.now.beginning_of_day,
        end_day: DateTime.now.end_of_day
      ).where(
        report_type: Enums::SalesReportTypes::NOMENCLATURES_SALES
      ).order(created_at: :asc)
    end

    def parse_options(options)
      result = JSON.parse(options, symbolize_names: true)
      if result[:folder].blank? || result[:delivery_point_code].blank?
        result = JSON.parse(default_params, symbolize_names: true)
      end
      result
    end

    def opened_operational_day_with_shifts_exist?
      opened_operational_day = OperationalDay.find_by(closed_at: nil)
      opened_operational_day.present? && opened_operational_day.shifts.any?
    end

    def default_params
      '{"delivery_point_code": "all", "folder": "/home/reports"}'
    end

    def check_or_create_folder(path)
      Dir.mkdir(path) unless File.exist?(path)
    end
  end
end
