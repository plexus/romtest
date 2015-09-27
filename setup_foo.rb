############################################################
# Global, auto

ROM.setup(:memory)
ROM.use(:auto_registration)

class Users < ROM::Relation[:memory]
  # ...
end

class CreateUser < ROM::Commands::Create[:memory]
  # ...
end

# current
ROM.finalize # ROM::Environment

ROM.container.command(:users).create
ROM.container.relation(:users)
# or equivalent
ROM.env.command(:users).create
ROM.env.relation(:users)

# proposed
ROM.finalize

ROM.command(:users).create
ROM.relation(:users)


############################################################
# Global, with register

ROM.setup(:memory)
ROM.use(:auto_registration)

class Users < ROM::Relation[:memory]
  # ...
end

class CreateUser < ROM::Commands::Create[:memory]
  # ...
end

# current
ROM.finalize # ROM::Environment

ROM.container.command(:users).create
ROM.container.relation(:users)
# or equivalent
ROM.env.command(:users).create
ROM.env.relation(:users)

# proposed
ROM.finalize

ROM.command(:users).create
ROM.relation(:users)





# Manual, non-automatic, non-DSL version
rom_env = ROM::Environment.new(:sql, 'postgres://localhost/db') do |config| #config is a Setup
  config.register_relation(:foos)
end
rom_env.register_relation(:bars) # NoMethodError
foos = rom_env.relation(:foos).to_a # [{...}, {...}]

# Time-separated setup (e.g., as part of a framework boot process)
rom_setup = ROM::Setup.new(:sql, 'postgres://localhost/db')
#...
rom_setup.register_relation(:bars)
#...
rom_env = ROM::Environment.new(rom_setup)
bars = rom_env.relation(:bars).to_a # [{...}, {...}]
