class Team < ActiveRecord::Base
  belongs_to :player1, class_name: "User"
  belongs_to :player2, class_name: "User"

  scope :for_user, lambda { |user1_id| where("(player1_id = #{user1_id} OR player2_id = #{user1_id})")}
  scope :for_single_user, lambda { |user1_id| where("(player1_id = #{user1_id} AND player2_id IS NULL)")}
  scope :for_users, lambda { |user1_id, user2_id| where("(player1_id = #{user1_id} OR player2_id = #{user1_id}) AND (player1_id = #{user2_id} OR player2_id = #{user2_id})")}

  def matches
    Match.for_team(self.id)
  end

  def self.shuffle(user_ids)
    return [] unless user_ids.size == 4
    users = User.where(id: user_ids).order("quote desc")
    best_user = users.first
    users_to_select = []
    users[1..3].each_with_index do |user, index|
      (index + 1).times do
        users_to_select << user
      end
    end
    partner = users_to_select.sample
    opponents = users - [best_user, partner]
    [Team.find_or_create([best_user.id, partner.id]), Team.find_or_create([opponents.first.id, opponents.last.id])]
  end

  def self.find_or_create(user_ids)
    users = User.where(id: user_ids)
    team = nil
    if users.size > 1
      team = Team.for_users(user_ids.first, user_ids.last).first
    else
      team = Team.for_single_user(user_ids.first).first
    end
    if team.nil? && users.size == 2
      team = Team.new
      team.player1_id = user_ids.first
      team.player2_id = user_ids.last
      team.save
    elsif team.nil? && users.size == 1
      team = Team.new
      team.player1_id = user_ids.first
      team.save
    end
    team
  end

  def elo_quote
    (self.users.sum(&:quote).to_f / self.users.size).round
  end

  def users
    [player1, player2].compact
  end

  def double?
    self.users.size > 1
  end

  def name
    self.users.map(&:name).join(" & ")
  end

  private


end
