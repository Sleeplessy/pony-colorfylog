use "logger"
use "colorfylog"

actor Main
  new create(env: Env) =>
    let logger = ColorLogger(Fine, env.out)
    logger.log("Our base is safe!", Fine)
    logger.log("User logged in base's server.", Info)
    logger.log("Some was attacking our system!", Warn)
    logger.log("System interepted!", Error)
