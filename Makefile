all:
	echo "nothing"

json-docs:
	python ./scripts/preprocess.py

couch-docs:
	make json-docs
	python ./scripts/senddocs.py

couch-ddoc:
	coffee -c --bare ddoc/app/indexes/doulas/index.coffee
	coffee -c --bare ddoc/app/views/all/map.coffee
	coffee -c --bare ddoc/app/lists/sitemap.coffee
	couchapp push ddoc/app http://bliengerventookinglearkm:0NPW5hCmfTu1MOT0ys8H8wgs@fiatjaf.cloudant.com/doulas

run:
	npm run build
	foreman run coffee server.coffee
