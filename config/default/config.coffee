module.exports = {
  loggers:
    telegram: {}

  storage:
    enable: true

    redis: {}

    mongo:
      name: "luxy"

  subscribe: {
    luxyOrder: {
      script: "luxy_order"
      channels: ["luxy_order"]
      redis: "main"
    }
  }

  loggers:
    bot: {}


  bot: {
    token: "138729684:AAHRUzWhlZf3BYGiuEvwQGbb2yqHIrg6YE0"
    chatId: 20045630
  }
}