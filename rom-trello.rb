require 'rom'
require 'rom-http'

require 'json'
# require 'uri'
require 'faraday'

require_relative 'pretty'

# https://api.trello.com/1/boards/4eea4ffc91e31d1746000046?lists=open&list_fields=name&fields=name,desc&key=[application_key]&token=[optional_auth_token]


module ROM
  module TrelloAdapter
    class Gateway < ROM::HTTP::Gateway
      DEFAULTS = {
        uri: 'https://api.trello.com',
        headers: {Accept: "application/json"}
      }

      def initialize(config)
        super(DEFAULTS.merge(config))
      end
    end

    class Dataset < ROM::HTTP::Dataset
      default_request_handler ->(dataset) {
        faraday = Faraday.new(url: dataset.uri)

        path = "/1/#{dataset.path}"
        params = {
          token: dataset.config.fetch(:token),
          key: dataset.config.fetch(:key)
        }.merge(dataset.params)

        faraday.send(dataset.request_method, path, params) do |req|
          dataset.headers.each do |header, value|
            req[header.to_s] = value
          end
        end
      }

      default_response_handler ->(response, dataset) do
        [JSON.parse(response.body)]
      end
    end

    class Relation < ROM::HTTP::Relation
      adapter :trello
    end
  end
end

ROM.register_adapter(:trello, ROM::TrelloAdapter)


class Boards < ROM::Relation[:trello]
  dataset :boards

  def for_member(members)
    with_path("members/#{members.first["id"]}/boards")
  end
end

class Members < ROM::Relation[:trello]
  dataset :members

  def me
    with_path('members/me')
  end
end

begin
  HOME = Pathname(ENV['HOME'])
  load HOME.join('.trello-remote')
rescue => e
  puts %q{ ~/.trello-remote should look like
TRELLO_MEMBER_TOKEN='...'
TRELLO_DEVELOPER_PUBLIC_KEY='...'}
  exit 1
end


rom = ROM::Environment.new
rom.setup(:trello, {
  token: TRELLO_MEMBER_TOKEN,
  key: TRELLO_DEVELOPER_PUBLIC_KEY,
})

rom.register_relation(Boards)
rom.register_relation(Members)

container = rom.finalize.env

members = container.relation(:members)
boards  = container.relation(:boards)

puts(members.me >> boards.for_member)
