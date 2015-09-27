require 'rom'
require 'rom-sql'
require 'rom-mapper'
require 'rom-repository'
require 'virtus'

require_relative './pretty'
TOP = binding


class Users < ROM::Relation[:sql]
  def by_name(name)
    where(name: name)
  end

  view(:listing, [:id, :name, :email, :created_at]) do
    select(:id, :name, :email).order(:name, :id)
  end

  def registered_after(timestamp)
    where { created_at > timestamp }
  end
end

class UserRepository < ROM::Repository::Base
  relations :users

  def [](id)
    users.where(id: id).one!
  end

  def listing
    users.listing
  end
end

rom_setup = ROM::Environment.new.setup(:sql, 'sqlite://test.sqlite3')

rom_setup.register_relation(Users)

rom = rom_setup.finalize

user_repo = UserRepository.new(rom)

show 'user_repo[1]'
show 'user_repo.listing.to_a'
