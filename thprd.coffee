request = require("request")
cheerio = require("cheerio")
days = [
  "Monday"
  "Tuesday"
  "Wednesday"
  "Thursday"
  "Friday"
  "Saturday"
  "Sunday"
]
pools =
  Aloha: 3
  Beaverton: 15
  Conestoga: 12
  Harman: 11
  Raleigh: 6
  Somerset: 22
  Sunset: 5
  "Tualatin Hills": 2

for pool of pools
  url = "http://www.thprd.org/schedules/schedule.cfm?cs_id=" + pools[pool]
  request url, ((pool) ->
    (err, resp, body) ->
      $ = cheerio.load(body)
      $("#calendar .days td").each (day) ->
        $(this).find("div").each ->
          event = $(this).text().trim().replace(/\s\s+/g, ",").split(",")
          console.log pool + "," + days[day] + "," + event[0] + "," + event[1]  if event.length >= 2 and (event[1].match(/open swim/i) or event[1].match(/family swim/i))
          return

        return

      return
  )(pool)
