module.exports = {
  loggers:
    telegram: {}

  storage:
    enable: true

    redis: {}

  subscribe: {
    luxyOrder: {
      script: "luxy_order"
      channels: ["luxy_order"]
      redis: "main"
    }
  }


  bot: {
    token: "138729684:AAHRUzWhlZf3BYGiuEvwQGbb2yqHIrg6YE0"
    chatId: 20045630
  }
}