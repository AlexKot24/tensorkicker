class User < ActiveRecord::Base

  belongs_to :league

  scope :ranked, lambda { order("quote DESC") }

  validates :name, presence: true

  def number_of_games
    number_of_wins + number_of_looses
  end

  def teams
    Team.for_user(self.id)
  end

  def matches
    self.teams.map{|team| team.matches}.flatten.sort{|x,y| y.date <=> x.date}
  end

  def active?
    self.matches.any? && self.matches.first.date > 2.weeks.ago
  end

  def win_percentage
    QuoteCalculator.win_loose_quote(self.number_of_wins, self.number_of_looses)
  end

  def short_name
    return '' unless self.name.present?
    s = self.name.split(' ')
    if s.length > 1
      s.map{|name| name[0]}.join()
    else
      s.first[0..1]
    end
  end

  def set_elo_quote(match)
    win = match.win_for?(self) ? 1 : 0
    team_quote = win == 1 ? match.winner_team.elo_quote : match.looser_team.elo_quote
    opponent_quote = win == 1 ? match.looser_team.elo_quote : match.winner_team.elo_quote
    quote_change = QuoteCalculator.elo_quote(team_quote, opponent_quote , win )
    if match.crawling == true
      quote_change = win ? quote_change + 5 : quote_change - 5
      if win == 1
        self.number_of_crawls += 1
      else
        self.number_of_crawlings += 1
      end
    end

    self.quote = self.quote + quote_change

    if win == 1
      self.number_of_wins += 1
      self.winning_streak += 1
    else
      self.number_of_looses += 1
      self.winning_streak = 0
    end

    match.update_attributes(difference: quote_change.abs) unless match.difference > 0
    self.save
  end

  def self.create_with_omniauth(auth, league = nil)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.league_id = league.id
      user.email = auth["info"]["email"]
      user.image = auth['info']['image']
    end
  end
end
