# frozen_string_literal: true
SqlLogging.configuration.logger = SemanticLogger[SqlLogging]
SqlLogging.configuration.show_top_sql_queries = false
SqlLogging.configuration.show_sql_backtrace = false
SqlLogging.configuration.show_query_stats = false

SqlLogging.configuration.query_extensions << proc do |*_args|
  if SqlLogging.configuration.show_sql_backtrace && Thread.current[:last_graphql_backtrace_context]
    potential_context = Thread.current[:last_graphql_backtrace_context]
    if potential_context.is_a?(GraphQL::Query::Context) || potential_context.is_a?(GraphQL::Query::Context::FieldResolutionContext)
      SqlLogging.configuration.logger.debug "GraphQL backtrace:\n#{potential_context.backtrace}"
    end
  end
end
