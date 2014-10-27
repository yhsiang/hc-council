require! <[ request cheerio fs ]>

url = \http://dep-auditing.hccg.gov.tw/web/SG?pageID=27404&FP=42985

err, res, body <- request.get url
$ = cheerio.load body
links = []

$ '.dlarktext-13 table a' .each (,it) -> links.push ($ it .attr \href)

links.map ->
  filename = "raw/" +it.match /^http:.+\/(\w+\.\w+)$/ .1
  request it .pipe fs.createWriteStream filename
