
TelegramBot = require "node-telegram-bot-api"

_ = require "underscore"
request = require "request"

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

            unless orders.length
              return @bot.sendMessage message.chat.id, "Not found orders"

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

        when "/send"
          @logger.info "Send command. Set `sent` status to order `#{option}`"
          vakoo.mongo.collection("orders").findOne {_id: option}, (err, order)=>
            if err
              return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"

            unless order
              return @bot.sendMessage message.chat.id, "Not found order `#{option}`"

            request.post {
                url: "http://uslada-shop.ru/lxsx.php"
                form: {
                  key: "sdifg7s9d8hi3w4r"
                  name: order.fullname
                  phone: order.phone
                  city: order.address.city
                  address: """
                    #{order.address.code}, #{order.address.region}, #{order.address.city}.
                    #{order.address.street}, д. #{order.address.house}, #{if order.address.block then "корп. #{order.address.block}," else ""} кв. #{order.address.flat}
                  """
                  products: _.map(
                    order.products
                    (product)->
                      "#{product.distributor_sku}:#{product.count}"
                  )
                }
              }, (err, res, body)=>
                if err
                  return @bot.sendMessage message.chat.id, "Request err: `#{err}`"
                else
                  vakoo.mongo.collectionNative("orders").update {_id: order._id}, {$set: {status: "sent"}}, (err)=>
                    if err
                      return @bot.sendMessage message.chat.id, "Mongo err: `#{err}`"
                    return @bot.sendMessage message.chat.id, "Set status `sent` to order `#{option}` successfully"


        else
          return @bot.sendMessage message.chat.id, "Unknown command `#{command}`"




module.exports = Bot