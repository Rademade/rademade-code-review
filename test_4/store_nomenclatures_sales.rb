module Reports
  class StoreNomenclaturesSales
    def initialize(delivery_point_code:)
      @dp_code = delivery_point_code
    end

    def store
      result = []
      report_data.each do |data_item|
        title, article, price, count = data_item
        record = {
          title: title,
          article: article,
          price: price,
          count: count,
          sales_sum: price * count
        }
        result << record
      end
      SalesReport.create(
        report_type: Enums::SalesReportTypes::NOMENCLATURES_SALES,
        report_data: {
          dp_code: @dp_code,
          records: result
        }
      )
    end

    private

    def report_data
      @report_data ||= report_items
                       .group(
                         :article,
                         :title,
                         :price
                       ).pluck(
                         :title,
                         :article,
                         :price,
                         'sum(count)'
                       )
    end

    def report_items
      @report_items ||= OrderItem
                        .joins(order: [:shift, :delivery_point])
                        .where(
                          status: Enums::OrderItemStatuses::ACTIVE,
                          orders: {
                            shift: today_shifts,
                            closed_operational_day_id: nil,
                            state: Enums::Order::States::CLOSED,
                            is_archived: false,
                            delivery_point: delivery_points_for_report
                          },
                          main_dish_id: nil
                        )
    end

    def today_shifts
      @today_shifts ||= OperationalDay.find_by(closed_at: nil).shifts
    end

    def delivery_points_for_report
      if @dp_code == 'all'
        DeliveryPoint.all
      else
        DeliveryPoint.where(code: @dp_code)
      end
    end
  end
end
