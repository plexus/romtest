require 'pp'

require 'rom'
require 'rom-sql'
require 'rom-mapper'

require_relative './pretty'

require 'virtus'

class User
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :email, String
end

ROM.setup(:memory)
ROM.use(:auto_registration)

class Users < ROM::Relation[:memory]
  def by_name(name)
    where(name: name)
  end
end

class CreateUser < ROM::Commands::Create[:memory]
  relation :users
  register_as :create
  result :one
end

class UserAsEntity < ROM::Mapper
  register_as :entity # the registered name of the mapper
  relation :users     # the name of the relation the mapper is applicable to
  model User          # the domain model to map tuples to
end

rom_env = show 'ROM.finalize'
container = show 'rom_env.container'
hr
create_user = show 'container.command(:users).create'

new_users = [
  { name: 'Jane' },
  { name: 'Joe' }
]

hr
show 'create_user.call(new_users)' # returns created users
show 'container.relation(:users).to_a'
