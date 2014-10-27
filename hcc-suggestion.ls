require! <[ fs ]>
{ lists-to-obj } = require 'prelude-ls' .Obj
# keys = <[ councilor suggestion position suggest_expense approved_expense expend_on brought_by bid_type bid_by suggest_year suggest_month uid ]>

keys = <[ suggestion position suggest_expense approved_expense expend_on brought_by bid_type bid_by suggest_year suggest_month uid ]>
# 建議項目及內容
# 建議地點
# 建議 金額
# 核定 金額
# 經費支用科目
# 主辦機關
# 有無公 開招標
# 得標廠商
result = []
uid = 1
year = 2014
month = 6


err, file1 <- fs.readFile 'hcc-csv/103top.csv'
#err, file2 <- fs.readFile 'hcc-csv/102down.csv'
data = file1.toString! #+ file2.toString!
do
  <- data.toString!split '\n' .map
  # 101: 382, 102: 314
  # month := 12 if uid > 314
  if it.split ',' .length > 200
    line = []
    (item, i) <- it.split ',' .forEach
    line ++= item
    if (i+1) % 8 is 0
      line ++= [ "#{year}", "#{month}"]
      line ++= "新竹縣-#{year}-#{uid++}"
      result.push lists-to-obj keys, line
      line := []

month := 12
data = file2.toString!
do
  (items, i)<- data.toString!split '\n' .map
  if (line = items.split ',') .length >= 9
    line ++= [ "#{year}", "#{month}"]
    line ++= "新竹縣-#{year}-#{uid++}"
    line = line.map -> it.replace /"/g, ''

    line.4 ++= line.5
    formatted = line.slice 0, 5 .concat line.slice 6, 13 #|> console.log
    result.push lists-to-obj keys, formatted

console.log result
# console.log JSON.stringify result

