Firebase = require 'firebase'
dialogue = require '../assets/dialogue'
parser = require './parser'
helpers = require './helpers'
messenger = require './messenger'

dataRef = new Firebase("https://vera.firebaseIO.com/")

schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.second = [0, 30]

module.exports =
  checkUp: ()->

    updateFriends = () ->
      dataRef.once "value", (snapshot) ->
        for phoneNumber, dataSet of snapshot.val()
          # helpers.random_tip(messenger.sendMessage, phoneNumber, 'food') # SEND TIPS
          console.log "===" + phoneNumber + "==="
          phoneRef = dataRef.child(phoneNumber)
          for dataKey, dataPack of dataSet
            console.log "---" + dataKey + "---"
            if typeof dataPack is 'object'
              for measurementKey, measurementData of dataPack
                console.log measurementData.height
                console.log measurementData.time
            else
              if dataKey is 'daysUntil'
                phoneRef.child('daysUntil').once "value", (snapshot) ->
                  if parseInt(snapshot.val()) is 0
                    helpers.random_tip(messenger.sendMessage, phoneNumber, 'activity')
                    parser.updateTimeSeries phoneNumber
                  phoneRef.update daysUntil: snapshot.val()-1
              console.log dataPack

    job = schedule.scheduleJob rule, () ->
      console.log "Checking on our friends..."
      updateFriends()
