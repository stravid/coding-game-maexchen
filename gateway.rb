class Gateway
  def initialize
    @game = Game.new

    @command_dispatcher = CommandDispatcher.new
    @command_dispatcher.register NullCommand, NullHandler
    @command_dispatcher.register AttendCommand, AttendHandler
    @command_dispatcher.register DicesCommand, DicesHandler
    @command_dispatcher.register SeeOrRollCommand, SeeOrRollHandler
    @command_dispatcher.register NewDicesCommand, NewDicesHandler
    @command_dispatcher.register NewRoundCommand, NewRoundHandler

    @server_command_client_command_map = Hash.new(NullCommand)
    @server_command_client_command_map["ATTENDING"] = AttendCommand
    @server_command_client_command_map["DICES"] = DicesCommand
    @server_command_client_command_map["SEE OR ROLL"] = SeeOrRollCommand
    @server_command_client_command_map["NEW DICES"] = NewDicesCommand
    @server_command_client_command_map["ROUND STARTING"] = NewRoundCommand
  end

  def on(message, &block)
    parts = message.split(";")

    command_part = parts[0]
    data_part = parts[1]
    command = @server_command_client_command_map[command_part]

    response = @command_dispatcher.call(command.new(@game, data_part))

    yield(response)
  end
end

class Game
  attr_reader :previous_dices

  def initialize
    @previous_dices = []

    @ranking = [
      "31",
      "32",
      "41",
      "42",
      "43",
      "51",
      "52",
      "53",
      "54",
      "61",
      "62",
      "63",
      "64",
      "65",
      "11",
      "22",
      "33",
      "44",
      "55",
      "66",
      "21"
    ]
  end

  def reset
    @previous_dices = []
  end

  def see_or_roll
    last_dices_index = @ranking.index(previous_dices.last)
    last_last_dices = previous_dices[-2] || previous_dices[-1]
    last_last_dices_index = @ranking.index(last_last_dices)

    if (last_dices_index >= @ranking.index("33") || last_dices_index - 1 == last_last_dices_index)
      "SEE;David2"
    else
      "ROLL;David2"
    end
  end

  def next_dices(dices)
    return "21" if dices == "21"

    if @ranking.index(dices) <= @ranking.index(previous_dices.last)
      @ranking[@ranking.index(previous_dices.last) + 1]
    else
      dices
    end
  end
end

module BaseCommand
  attr_reader :data, :game

  def initialize(game, data)
    @game = game
    @data = data
  end
end

class CommandDispatcher
  def initialize
    @handlers = {}
  end

  def register(command_klass, handler_klass)
    @handlers[command_klass] = handler_klass
  end

  def call(command)
    @handlers[command.class].new.call(command)
  end
end

class NullCommand
  include BaseCommand
end

class NullHandler
  def call(command)
  end
end

class AttendCommand
  include BaseCommand
end

class AttendHandler
  def call(command)
    puts "AttendHandler"

    "ATTEND;David2"
  end
end

class DicesCommand
  include BaseCommand
end

class DicesHandler
  def call(command)
    puts "DicesHandler"

    if command.game.previous_dices.length > 0
      result = "DICES;#{command.game.next_dices(command.data)};David2"
    else
      result = "DICES;#{command.data};David2"
    end

    result
  end
end

class SeeOrRollCommand
  include BaseCommand
end

class SeeOrRollHandler
  def call(command)
    puts "SeeOrRoll"

    command.game.see_or_roll
  end
end

class NewDicesCommand
  include BaseCommand
end

class NewDicesHandler
  def call(command)
    puts "NewDices"

    # if command.game.previous_dices.length > 0
    #   result = "DICES;#{command.game.next_dices(command.data)};David2"
    # else
    #   result = "DICES;#{command.data};David2"
    # end

    command.game.previous_dices << command.data

    # result
    ""
  end
end

class NewRoundCommand
  include BaseCommand
end

class NewRoundHandler
  def call(command)
    command.game.reset
  end
end
