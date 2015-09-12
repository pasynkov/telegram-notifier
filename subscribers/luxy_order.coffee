
TelegramBot = require "node-telegram-bot-api"

class LuxyOrder

  constructor: (channel, message, callback)->

    @config = vakoo.configurator.config.bot

    @bot = new TelegramBot @config.token, polling: true

    @bot.sendMessage @config.chatId, message

    callback()


module.exports = LuxyOrder