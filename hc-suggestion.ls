require! <[ fs csv-parse ]>
csv = csv-parse
{ lists-to-obj } = require 'prelude-ls' .Obj

keys = <[ councilor suggestion position suggest_expense approved_expense expend_on brought_by bid_type bid_by suggest_year suggest_month uid ]>
i = 1
result = []


end = ->
  JSON.stringify result |> console.log

data <- fs.createReadStream 'raw/10301-0.csv' .pipe csv! .on \end end .on \data
if not data.0.match /[新竹|姓名|表\d]/ and data.0 isnt ''
  formated = data.map -> it.trim!
  formated ++= <[ 2014 6 ]>
  formated ++= "新竹市-2014-#{i++}"
  result ++= lists-to-obj keys, formated if data.length is 9 and not data.0.match /合\s+計/

