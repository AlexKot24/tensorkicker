class KpiCalculator
  def initialize(number_of_weeks)
    @number_of_weeks = number_of_weeks
  end

  # The outcome of this methos is used for drawing a graph, first value is the calendar week, the second the number of active leagues is that week.
  # The .reverse is used to have the oldest week at the first position
  def active_league_count(match_threshold)
    possible_leagues = League.where.not(name: 'Railslove').where('matches_count >= ?', match_threshold)
    league_count = []
    (1..@number_of_weeks).to_a.reverse.each do |i|
      date = i.weeks.ago
      leagues = possible_leagues.where('created_at < ?', date).select{|l| l.matches.first.date > (date - 14.days)}.count
      league_count << [date.to_date.cweek, leagues]
    end
    league_count
  end
end
