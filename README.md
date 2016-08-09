Run through rake tasks in lib/tasks

Write:
  Local:
    mongoexport --db yescoi_development --collection records --jsonArray --out imo.json
    mongoexport --db yescoi_development --collection records --jsonArray --out imo.json  --pretty
  Heroku:
    JSON:
      mongoexport -h ds149565-a0.mlab.com:49565 -d heroku_llk3ncpr -c records -u <user> -p <password> -o imo.json --jsonArray
    BSON:
      mongodump -h ds149565-a0.mlab.com:49565 -d heroku_llk3ncpr -u <user> -p <password> -o imo
    Notes:
      production app is down, as is the db.
Dead Urls:
  http://rptsweb.oswegocounty.com/search.aspx?advanced=true
