class Engine
  def initialize
    @responses = []
    @name = "KlausDavid"
  end

  def start
    @responses << JoinMessage.new
  end

  def next_response
    response = @responses.shift
    "#{response.to_s}#{@name}"
  end

  def handle_message(message)
    message = Message.parse(message)

    case message
    when AttendMessage
      respond_with AttendMessage.new
    when DicesMessage
      respond_with message
    when SeeOrRoll
      respond_with message
    end
  end

  def respond_with(message)
    @responses << message
  end
end

class Message
  # def self.last_dices=(dices)
  #   @last_dices = dices
  # end

  # def self.last_dices

  # end
  # def initialize
  #   @last_dices = []
  # end

  def self.parse(input)
    type, arguments = input.split(";")
    case type
    when "ATTENDING"
      AttendMessage.new
    when "DICES"
      DicesMessage.new(arguments, @last_dices.nil? ? nil : @last_dices.last)
    when "SEE OR ROLL"
      SeeOrRoll.new(@last_dices)
    when "NEW DICES"
      if @last_dices.nil?
        @last_dices = []
      end

      @last_dices << arguments

      NewDices.new(arguments)
    when "ROUND ENDED"
      @last_dices = []
    else
      NullMessage.new
    end
  end
end

class NullMessage
  def to_s
    ''
  end
end

class AttendMessage
  def to_s
    "ATTEND;"
  end
end

class JoinMessage
  def to_s
    "JOIN;"
  end
end

class DicesMessage
  def initialize(dices, last_dices)
    @dices = dices
    @last_dices= last_dices
  end

  def to_s
    ranking = [
      '31',
      '32',
      '34',
      '35',
      '36',
      '41',
      '42',
      '43',
      '45',
      '46',
      '51',
      '52',
      '53',
      '54',
      '56',
      '61',
      '62',
      '63',
      '64',
      '65',
      '11',
      '22',
      '33',
      '44',
      '55',
      '66',
      '21',
    ]

    other_index = ranking.index(@last_dices)
    our_index = ranking.index(@dices)

    if other_index.nil?
      "DICES;#{@dices};"
    elsif our_index > other_index
      "DICES;#{@dices};"
    else
      dice = ranking[[other_index + 2,ranking.size - 1].min]
      "DICES;#{dice};"
    end
  end
end

class SeeOrRoll
  def initialize(dices)
    @dices = dices
  end

  def to_s
    ranking = [
      '31',
      '32',
      '34',
      '35',
      '36',
      '41',
      '42',
      '43',
      '45',
      '46',
      '51',
      '52',
      '53',
      '54',
      '56',
      '61',
      '62',
      '63',
      '64',
      '65',
      '11',
      '22',
      '33',
      '44',
      '55',
      '66',
      '21',
    ]

    last_index = ranking.index(@dices.last)

    if @dices.size > 1
      second_to_last_dices = ranking.index(@dices[@dices.size - 2])

      if last_index - 1 == second_to_last_dices
        return "SEE;"
      end
    end

    index = ranking.index('65')

    if last_index > index
      "SEE;"
    else
      "ROLL;"
    end
  end
end

class NewDices
  def initialize(dices)
    @dices = dices
  end

  def to_s

  end
end
