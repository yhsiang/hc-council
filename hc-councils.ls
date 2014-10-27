require! <[ fs request cheerio async ]>
{ concat-map } = require 'prelude-ls' .List
main-url = \http://www.hsinchu-cc.gov.tw/content/councilor.htm
councils = []
area = ''
pre-path = 'http://www.hsinchu-cc.gov.tw/content/'
council-base =
  county: \新竹市
  title: \議員
  party: \無黨籍
  election_year: \2009


function parse-council (person, next)
  council = {}
  council <<< council-base
  council.contact_details = []
  council.constituency = person.constituency
  council.links = []
  council.links.push note: "議會個人官網", url: person.url

  err, res, body <- request.get person.url
  $ = cheerio.load body
  main = ($ 'table[bordercolordark="#4ab69c"] > tbody > tr' .get 0) or ($ '.MsoNormalTable tr' .get 4)
  avatar = $($ main .children!.0).find 'img' .attr \src #|> console.log
  info = $($ main .children!.1).find 'p' .text! # |> console.log
  council["image"] = pre-path + avatar
  council.name = info.match /^(.+)性/ .1 if info.match /^(.+)性/  #|> console.log
  council.name = info.match /^(.+)\r\n/ .1 if not council.name  and info.match /^(.+)\r\n/
  council.party = info.match /黨 籍：(.+黨)/ .1 if info.match /黨 籍：(.+黨)/
  more = ($ 'table[bordercolordark="#4ab69c"] > tbody > tr' .get 1) or ($ '.MsoNormalTable tr' .get 5)
  do
    idx, e <- $ more .find 'tr' .each
    label = $($ e .children!0).text!trim!replace /[\ |\s]/g, ''
    value = $($ e .children!1).text!trim!replace /\ /g, ''
    type = 'address' if label.match /地址/
    type = 'voice' if label.match /電話/
    type = 'email' if label.match /信箱/
    type = 'blog' if label.match /部落格/
    if type and type isnt 'blog'
      council.contact_details.push do
        label: label
        type: type
        value: value
    if type is 'blog'
      council.links.push note: label, url: value
    if label.match /政見/
      council.platform = value.split(/\r\n/).map (-> it.trim! ) .filter -> it isnt ''
  next null, council

err, res, body <- request.get main-url
$ = cheerio.load body
table = $ 'table table[bordercolordark="#4ab69c"]' .get 1 #|> console.log
do
  idx, e <- $ table .children!children!each
  cols = $ e .find 'td' .length
  switch cols
  | 1 => area := $ e .find 'td' .text!trim!replace /\ /g, ''
  # | 2 => councils ++= ($ e .find 'td' .map (,it)-> pre-path + encodeURIComponent($ it .find 'a' .attr \href)).toArray!
  | otherwise =>
    councils ++= $ e .find 'td' .map (,it) ->
      (pre-path + encodeURIComponent($ it .find 'a' .attr \href)) if $ it .children!is 'font' and $ it .text!trim! isnt ''
    .toArray!map -> { url: it, constituency: area }

err, result <- async.map councils, parse-council
# result.toString!
console.log JSON.stringify result