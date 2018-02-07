use "logger"
use "term"

primitive LogLevelString
  fun apply(level' : LogLevel): String =>
    match(level')
      | Fine => "Fine"
      | Info => "Info"
      | Warn => "Warn"
      | Error => "Error"
    end

primitive LevelColor
  """
  Return an ANSI colorfied string depends on the LogLevel.
  If no args provided,it would return a string that reset color configs.
  """
  fun apply(level' : (LogLevel | None) = None): String =>
    let color_str = match level'
      | Fine => ANSI.green()
      | Info => ANSI.cyan()
      | Warn => ANSI.yellow()
      | Error => ANSI.red()
    else
      ANSI.reset()
    end
    let bold = ANSI.bold()
    (recover String(color_str.size()
    + bold.size()
    + 1)
    end)
    .> append(bold)
    .> append(color_str)

primitive ColorfyLogString
  fun val apply(msg' : String, level' : LogLevel): String =>
    let level = level'
    let msg = msg'
    let level_str = LogLevelString(level)
    let msg_color = LevelColor(level)
    let reset_color = LevelColor()
    (recover String(
    msg_color.size()
    + level_str.size()
    + reset_color.size()
    + msg.size()
    + msg_color.size()
    + 4)
    end)
    .> append(msg_color)
    .> append("[")
    .> append(level_str)
    .> append("]")
    .> append(reset_color)
    .> append(" ")
    .> append(msg)


primitive ColorLogFormatter is LogFormatter
  """
  A customized formatter for personal tastes
  """
  fun apply(msg: String, loc: SourceLoc): String =>
    (recover String(msg.size()
    +1)
    end)
    .> append(msg)


class val ColorLogger
  """
  Logger handler
  """
  let _level: LogLevel
  let _out: OutStream
  let _formatter: LogFormatter
  let _logger: Logger[String]
  new val create(
    level: LogLevel,
    out: OutStream,
    formatter: LogFormatter = ColorLogFormatter)
  =>
  _level = level
  _out = out
  _formatter = formatter
  _logger = StringLogger(_level,_out,_formatter)

  fun log(msg': String, level': LogLevel = Info): Bool
  =>
  _logger(level') and _logger.log(ColorfyLogString(msg',level'))
