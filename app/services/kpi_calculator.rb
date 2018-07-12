class KpiCalculator
  attr_accessor :number_of_weeks, :league_count
  def initialize(number_of_weeks)
    @number_of_weeks = number_of_weeks
  end

  def active_league_count
    possible_leagues = League.where.not(name: 'Railslove').where('matches_count > 10')
    league_count = []
    (1..@number_of_weeks).to_a.reverse.each do |i|
      date = i.weeks.ago
      leagues = possible_leagues.where('created_at < ?', date).select{|l| l.matches.first.date > (date - 14.days)}.count
      league_count << [date.to_date.cweek, leagues]
    end
    league_count
  end
end
