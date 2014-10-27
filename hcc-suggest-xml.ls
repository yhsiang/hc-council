require! <[ fs cheerio prelude-ls ]>
{ lists-to-obj } = require 'prelude-ls' .Obj

keys = <[ suggestion position suggest_expense approved_expense expend_on brought_by bid_type bid_by suggest_year suggest_month uid ]>
i = 1
result = []

err, buf <- fs.readFile 'hcc-raw/103_tophalf.xml'
$ = cheerio.load buf.toString!
do
  idx, e <- $ 'table tr' .each #|> console.log
  data = $ e .find 'td' .map (,it) ->
    $ it .text!trim! #|> console.log
  .to-array!
  if data.length >= 7
    data ++= '' if data.length is 7
    data ++= <[ 2014 6 ]>
    data ++= "新竹縣-2014-#{i++}"
    result ++= lists-to-obj keys, data

result |> JSON.stringify |> console.log