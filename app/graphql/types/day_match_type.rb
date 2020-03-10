# frozen_string_literal: true

Types::DayMatchType = GraphQL::ObjectType.define do
  name 'DayMatch'
  field :id, !types.ID
  field :difference, !types.Int
  field :winner_team_id, !types.Int
  field :loser_team_id, !types.Int
  field :winner_team, !Types::TeamType
  field :loser_team, !Types::TeamType
  field :date, !types.String
  field :matches, types[Types::MatchType]
end
