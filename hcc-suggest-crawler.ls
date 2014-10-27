require! <[ fs request cheerio ]>

url = \http://w3.hsinchu.gov.tw/infr_events/

err, res, body <- request url
$ = cheerio.load body

links = ($ 'li a' .map (,it) -> url + $ it .attr \href).to-array!

links.map ->
  filename = "hcc-raw/" + it.match /^http:.+\/(\w+\.\w+)$/ .1
  request it .pipe fs.createWriteStream filename
