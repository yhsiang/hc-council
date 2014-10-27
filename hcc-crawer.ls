# district: []

require! <[ fs request cheerio iconv-lite async ]>

{ XmlEntities } = require 'html-entities'
entities = new XmlEntities!

url = \http://www.hcc.gov.tw/03councilor/councilor.asp

pre-path = \http://www.hcc.gov.tw/03councilor/

base-council = do
  election_year: \2009
  title: \議員
  county: \新竹縣

function parse-council (person, next)
  councilor = {}
  councilor <<< base-council
  councilor.constituency = person.constituency
  councilor.contact_details = []
  councilor.links = []
  councilor.links.push do
    note: "議會個人官網"
    url: person.url

  err, res, body <- request do
    url: person.url
    encoding: null
  $ = cheerio.load iconv-lite.decode body, 'big5'

  councilor.name = $($ 'table[width="90%"] table' .3).text!trim!match /.+\-(.+)/ .0
  councilor.image = pre-path + $($ 'table[width="90%"] table' .4).find 'img[width="120"]' .attr \src


  up = $ 'table[width="90%"] table' .6
  $ up .children!each (idx, e) ->
    councilor.party = $ e .find 'td' .text!trim! if $ e .find 'th' .text!match /黨籍/
    councilor.education = $ e .find 'td' .text!trim!split /\s/ if $ e .find 'th' .text!match /學歷/

  down = $ 'table[width="90%"] table' .7
  $ down .children!each (idx, e) -> #.find 'td' .map (,it) -> $ it .text!trim! if $ it .text!trim! isnt '').to-array! |> console.log
    councilor.experience = entities.decode($ e .find 'td' .html!)split '<br>' .map (-> it.replace /\s+/, '') if $ e .find 'th' .text!match /經歷/
    councilor.platform = ($ e .find 'li' .map (,it)-> $ it .text!).to-array! if $ e .find 'th' .text!match /政見/
    if $ e .find 'th' .text!match /E-mail/
      councilor.contact_details.push do
        label: \E-mail
        type: \email
        value: $ e .find 'td' .text!
    if $ e .find 'th' .text!match /網站/
      councilor.links.push do
        note: $ e .find 'th' .text!
        url: $ e .find 'td' .text!

  next null, councilor

err, res, body <- request do
  url: url
  encoding: null

$ = cheerio.load iconv-lite.decode body, 'big5'

# councils = ($ 'table[width="50"]' .map (,it) -> pre-path + $ it .find 'a' .attr \href).to-array!

councils = $ 'table[width="680"]' .children 'tr' .map (,it)->
  if $ it .children 0 .text!trim!match /^\d/
    constituency = $ it .children 0 .text!trim!replace /\r\n\s+/g, ''
    con-councils-urls = ($ it .find 'table[width="50"]' .map (,it) -> pre-path + $ it .find 'a' .attr \href).to-array!# |> console.log
    return con-councils-urls.map -> { url: it, constituency: constituency}
.to-array!


err, result <- async.map councils, parse-council
console.log JSON.stringify result
