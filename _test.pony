use "logger"
use "term"
use "ponytest"
use "promises"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestLogLevelString)
    test(_TestFineLevelColor)
    test(_TestInfoLevelColor)
    test(_TestWarnLevelColor)
    test(_TestErrorLevelColor)
    test(_TestFineColorfyLogger)
    test(_TestInfoColorfyLogger)
    test(_TestWarnColorfyLogger)
    test(_TestErrorColorfyLogger)


actor _TestStream is OutStream
  let _output: String ref = String
  let _h: TestHelper
  let _promise: Promise[String]

  new create(h: TestHelper, promise: Promise[String]) =>
    _h = h
    _promise = promise

  be print(data: ByteSeq) =>
    _collect(data)
  be write(data: ByteSeq) =>
    _collect(data)

  be printv(data: ByteSeqIter) =>
    for bytes in data.values() do
      _collect(bytes)
    end

  be writev(data: ByteSeqIter) =>
    for bytes in data.values() do
      _collect(bytes)
    end

  fun ref _collect(data: ByteSeq) =>
    _output.append(data)

  be logged() =>
    let s: String = _output.clone()
    _promise(s)

  be flush() => None

class iso _TestLogLevelString is _StringGenTest
  fun name(): String => "ColorfyLog/LogLevelString"

  fun tag expected(): String =>
    "FineInfoWarnError"

  fun produce_str(): String =>
    LogLevelString(Fine)+
    LogLevelString(Info)+
    LogLevelString(Warn)+
    LogLevelString(Error)


class iso _TestFineLevelColor is _StringGenTest
  fun name(): String => "ColorfyLog/LevelString"
  fun tag expected(): String =>
    ANSI.bold()+ANSI.green()+"Fine"+ANSI.reset()
  fun produce_str(): String =>
    LevelColor(Fine)+"Fine"+ANSI.reset()

class iso _TestInfoLevelColor is _StringGenTest
  fun name(): String => "ColorfyLog/LevelString"
  fun tag expected(): String =>
    ANSI.bold()+ANSI.cyan()+"Info"+ANSI.reset()
  fun produce_str(): String =>
    LevelColor(Info)+"Info"+ANSI.reset()

class iso _TestWarnLevelColor is _StringGenTest
  fun name(): String => "ColorfyLog/LevelString"
  fun tag expected(): String =>
    ANSI.bold()+ANSI.yellow()+"Warn"+ANSI.reset()
  fun produce_str(): String =>
    LevelColor(Warn)+"Warn"+ANSI.reset()


class iso _TestErrorLevelColor is _StringGenTest
  fun name(): String => "ColorfyLog/LevelString"
  fun tag expected(): String =>
    ANSI.bold()+ANSI.red()+"Error"+ANSI.reset()
  fun produce_str(): String =>
    LevelColor(Error)+"Error"+ANSI.reset()

class iso _TestFineColorfyLogger is _LoggerTest
  fun name(): String => "Colofylog/ColorLogger(Fine)"
  fun level(): LogLevel => Fine
  fun tag expected(): String =>
    ColorfyLogString("Fine message", Fine)+
    ColorfyLogString("Info message", Info)+
    ColorfyLogString("Warn message", Warn)+
    ColorfyLogString("Error message", Error)
  fun tag log(logger': ColorLogger)
  =>
  logger'.log("Fine message", Fine)
  logger'.log("Info message", Info)
  logger'.log("Warn message", Warn)
  logger'.log("Error message", Error)

class iso _TestInfoColorfyLogger is _LoggerTest
  fun name(): String => "Colofylog/ColorLogger(Fine)"
  fun level(): LogLevel => Info
  fun tag expected(): String =>
    ColorfyLogString("Info message", Info)+
    ColorfyLogString("Warn message", Warn)+
    ColorfyLogString("Error message", Error)
  fun tag log(logger': ColorLogger)
  =>
  logger'.log("Fine message", Fine)
  logger'.log("Info message", Info)
  logger'.log("Warn message", Warn)
  logger'.log("Error message", Error)

class iso _TestWarnColorfyLogger is _LoggerTest
  fun name(): String => "Colofylog/ColorLogger(Fine)"
  fun level(): LogLevel => Warn
  fun tag expected(): String =>
    ColorfyLogString("Warn message", Warn)+
    ColorfyLogString("Error message", Error)
  fun tag log(logger': ColorLogger)
  =>
  logger'.log("Fine message", Fine)
  logger'.log("Info message", Info)
  logger'.log("Warn message", Warn)
  logger'.log("Error message", Error)

class iso _TestErrorColorfyLogger is _LoggerTest
  fun name(): String => "Colofylog/ColorLogger(Fine)"
  fun level(): LogLevel => Error
  fun tag expected(): String =>
    ColorfyLogString("Error message", Error)
  fun tag log(logger': ColorLogger)
  =>
  logger'.log("Fine message", Fine)
  logger'.log("Info message", Info)
  logger'.log("Warn message", Warn)
  logger'.log("Error message", Error)

trait _StringGenTest is UnitTest
  fun apply(h: TestHelper) =>
    let promise = Promise[String]
    promise.next[None](recover this~_fulfill(h) end)
    let stream = _TestStream(h, promise)
    print_to_stream(produce_str(),stream)
    stream.logged()
    h.long_test(2_000_000)

  fun produce_str(): String

  fun tag expected(): String

  fun print_to_stream(str': String,
    stream': OutStream)
  =>
  stream'.write(str')

  fun timed_out(h: TestHelper) =>
    h.complete(false)

  fun tag _fulfill(h: TestHelper, value: String) =>
    h.assert_eq[String](value, expected())
    h.complete(true)


trait _LoggerTest is UnitTest
  fun apply(h: TestHelper) =>
    let promise = Promise[String]
    promise.next[None](recover this~_fulfill(h) end)
    let stream = _TestStream(h, promise)
    log(logger(level(), stream))
    stream.logged()
    h.long_test(2_000_000)


  fun tag _fulfill(h: TestHelper, value: String) =>
    h.assert_eq[String](value, expected())
    h.complete(true)

  fun tag expected(): String

  fun level(): LogLevel

  fun log(logger': ColorLogger)

  fun logger(
    level': LogLevel,
    stream': OutStream)
    : ColorLogger
  =>
  ColorLogger(level',stream')
