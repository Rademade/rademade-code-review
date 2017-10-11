module Reports
  class ExportNomenclaturesSalesReport
    def initialize(report_records:)
      @report_records = report_records.to_a
    end

    def save_to_file(folder:, file_name:)
      av = ActionView::Base.new(ActionController::Base.view_paths)
      content = av.render(
        template: 'reports/nomenclatures_sales_report.xlsx.axlsx',
        locals: {
          serialized_report: serialized_report
        }
      )
      File.open("#{folder}/#{file_name}.xlsx", 'w+b') { |f| f.puts content }
    end

    private

    def serialized_report
      result_rows = []
      result_rows << titles
      result_rows.concat(articles_records_rows)
    end

    def articles_records_rows
      result_rows = []
      @report_records.each_with_index do |report, report_index|
        report_data = report.report_data.deep_symbolize_keys
        report_data[:records].each do |saled_record|
          exists_row = result_rows.find do |row|
            row.first == saled_record[:article]
          end

          target_row = if exists_row
                         exists_row
                       else
                         result_rows.push(
                           [
                             saled_record[:article],
                             saled_record[:title],
                             saled_record[:price]
                           ].concat(
                             Array.new(report_index, 0)
                           )
                         )
                         result_rows.last
                       end

          target_row[default_counts_offset + report_index] = saled_record[:count]
          target_row.push(saled_record[:sales_sum].to_f.round(2)) if report == @report_records.last
        end
      end

      current_date = DateTime.now.strftime('%d.%m.%Y')

      result_rows.map { |row| row.unshift(current_date) }
      result_rows.sort_by(&:last).reverse
    end

    def titles
      [
        'Опер. день',
        'Артикул',
        'Название',
        'Цена'
      ].concat(
        @report_records.map { |record| record.created_at.strftime('%H:%M') }
      ).concat(
        ['Сумма']
      )
    end

    def default_counts_offset
      3
    end
  end
end
