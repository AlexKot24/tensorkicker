Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :leagues, !types[Types::LeagueType] do
    argument :limit, types.Int, default_value: 20, prepare: -> (limit, ctx) { [limit, 100].min }
    argument :league_slug, types.String, prepare: -> (league_slug, ctx) { league_slug }
    resolve -> (obj, args, ctx) {
      leagues = League.limit(args[:limit]).order(matches_count: :desc)
      leagues = leagues.where(slug: args[:league_slug]) if args[:league_slug].present?
      leagues
    }
  end

end
