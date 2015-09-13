
TelegramBot = require "node-telegram-bot-api"

_ = require "underscore"

class Bot

  constructor: ->

    @config = vakoo.configurator.config.bot

    @bot = new TelegramBot @config.token, polling: true

    @logger = vakoo.logger.bot

    @bot.on "text", (message)=>

      @logger.info "Incoming message `#{message.text}`"

      if @config.chatId isnt message.chat.id
        return @bot.sendMessage message.chat.id, "Sorry, im dont know who are you. Place concact with @pasynkov"

      [command, option] = message.text.split " "

      switch command
        when "/list"
          @logger.info "List command. Get orders ..."
          vakoo.mongo.collection("orders").find {status: option}, (err, orders)=>
            if err
              return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

            @logger.info "Finded `#{orders.length}` with option `#{option}`. Sending"

            list = _.map(
              orders
              (order)->
                order.fullname + "\n" + order.contact + "\n" + order.comment + "\n" + order._id + "\nhttp://www.luxy.sexy/admin/?task=shop.orders%2Fitem&id=#{order._id}"
            )

            for item in list
              @bot.sendMessage message.chat.id, item

        when "/get"
          @logger.info "Get command. Get order `#{option}`"
          vakoo.mongo.collection("orders").findOne {_id: option}, (err, order)=>
            if err
              return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

            unless order
              return @bot.sendMessage message.chat.id, "Not found order `#{option}`"

            @bot.sendMessage message.chat.id, """
              #{order.fullname}
              #{order.contact}
              #{JSON.stringify order.address}
              comment: #{order.comment}
              count: #{order.productCount}
              total: #{order.total}
              link: http://www.luxy.sexy/admin/?task=shop.orders%2Fitem&id=#{order._id}
            """

        when "/spam"
          @logger.info "Spam command. Set `spam` status to order `#{option}`"
          vakoo.mongo.collection("orders").findOne {_id: option}, (err, order)=>
            if err
              return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

            unless order
              return @bot.sendMessage message.chat.id, "Not found order `#{option}`"

            vakoo.mongo.collectionNative("orders").update {_id: order._id}, {$set: {status: "spam"}}, (err)=>
              if err
                return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

              return @bot.sendMessage message.chat.id, "Set status `spam` to order `#{option}` successfully"

        when "/cancel"
          @logger.info "Spam command. Set `spam` status to order `#{option}`"
          vakoo.mongo.collection("orders").findOne {_id: option}, (err, order)=>
            if err
              return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

            unless order
              return @bot.sendMessage message.chat.id, "Not found order `#{option}`"

            vakoo.mongo.collectionNative("orders").update {_id: order._id}, {$set: {status: "cancelled"}}, (err)=>
              if err
                return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

              return @bot.sendMessage message.chat.id, "Set status `cancelled` to order `#{option}` successfully"


module.exports = Bot