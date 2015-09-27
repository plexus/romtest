require 'rom'
require 'rom-sql'
require 'rom-mapper'
require 'virtus'

class User
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :email, String
end

# Setup, Environment, Container, Registry

env = ROM::Environment.new

GATEWAY_NAME = :my_sqlite

# ROM::Setup
setup = env.setup GATEWAY_NAME => [:sql, 'sqlite://test.sqlite3']

# ROM::Gateway
gateway = setup[GATEWAY_NAME]

class Users < ROM::Relation[:sql]
  gateway GATEWAY_NAME
  def by_name(name)
    where(name: name)
  end
end

class CreateUser < ROM::Commands::Create[:sql]
  relation :users
  register_as :create
  result :one
end

class UserAsEntity < ROM::Mapper
  register_as :entity # the registered name of the mapper
  relation :users     # the name of the relation the mapper is applicable to
  model User          # the domain model to map tuples to
end

setup.register_relation(Users)
setup.register_command(CreateUser)
setup.register_mapper(UserAsEntity)

# ROM::Container containing (gateways, relations, mappers, commands)
container = setup.finalize

create_user = container.command(:users).create

if ARGV.first == "--setup"
  gateway.connection.create_table :users do
    primary_key :id
    column :name, String
    column :email, String
  end
end

if ARGV.first == "--create"
  new_users = [
    { name: 'Jane' },
    { name: 'Joe' }
  ]

  create_user.call(new_users) # returns created users
end

p container.relation(:users).by_name("Jane").to_a

# p container.mappers
