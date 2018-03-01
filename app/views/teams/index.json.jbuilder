json.array! @teams do |team|
  json.id team.id
  json.games team.number_of_games
  json.wins team.number_of_wins
  json.losses team.number_of_losses
  json.quota team.percentage
  json.score team.score
  json.name team.name
  json.url league_team_url(current_league, team)
  json.player1 do
    json.id team.player1.id
    json.name team.player1.name
    json.image team.player1.image
  end
  json.player2 do
    json.id team.player2.id
    json.name team.player2.name
    json.image team.player2.image
  end
end
