class User::Meetings

  def self.plan(params)
    query_for_planned = Queries::PlannedMeetings::Days.new(params)
    query_for_realized = Queries::BookedMeetings::Days.new(params)

    planned = ComplexQueries::execute_query(query_for_planned.query).to_a
    realized = ComplexQueries::execute_query(query_for_realized.query).to_a

    Dto::User.plan(params[:start_date], params[:end_date], planned, realized)
  end

  def self.chart(params)
    if params[:period] == 'day'
      query_for_planned = Queries::PlannedMeetings::Days.new(params)
      query_for_realized = Queries::BookedMeetings::Days.new(params)
    else
      query_for_planned = Queries::PlannedMeetings::Months.new(params)
      query_for_realized = Queries::BookedMeetings::Months.new(params)
    end

    planned = ComplexQueries::execute_query(query_for_planned.query).to_a
    realized = ComplexQueries::execute_query(query_for_realized.query).to_a

    Dto::User.plan(params[:start_date], params[:end_date], planned, realized)
  end

  def self.save(params)
    date = Date.new(params[:date][:year], params[:date][:month], params[:date][:date])
    @user = User.find(params[:user_id])

    user_plan = @user.user_project_plans.by_project_for_day(params[:project_id], date)

    if user_plan.present?
      user_plan[0].update_attributes(planned: params[:planned], date: date)
    else
      @user.user_project_plans.create(project_id: params[:project_id], planned: params[:planned], date: date)
    end

    true
  end

end
