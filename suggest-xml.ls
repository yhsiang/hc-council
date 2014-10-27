require! <[ fs cheerio prelude-ls ]>
{ lists-to-obj } = require 'prelude-ls' .Obj

keys = <[ councilor suggestion position suggest_expense approved_expense expend_on brought_by bid_type bid_by suggest_year suggest_month uid ]>
i = 1
result = []

err, buf <- fs.readFile 'raw/10102.xml'
$ = cheerio.load buf.toString!
do
  idx, e <- $ 'table tr' .each #|> console.log
  if $ e .text!match /.+等32位議員/  #|> console.log
    data = $ e .find 'td' .map (,it)->
      $ it .text!trim!
    .to-array! #|> console.log
    data ++= <[ 2012 12 ]>
    data ++= "新竹市-2012-#{i++}"
    result ++= lists-to-obj keys, data

result |> JSON.stringify |> console.log