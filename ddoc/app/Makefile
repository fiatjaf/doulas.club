all:
	echo "nothing"

couch-ddoc:
	coffee -c --bare indexes/doulas/index.coffee
	coffee -c --bare views/.
	coffee -c --bare lists/.
	coffee -c --bare shows/.
	coffee -c --bare lib/.
	coffee -c --bare .
	rsync -rtvu components/ _attachments/components
	rsync -rtvu lib/ _attachments/lib
	lessc style.less _attachments/style.css
	couchapp push . http://heremeddesedenumforestry:lwhjgjsuCIBTYEMLlMSWXrj8@fiatjaf.cloudant.com/doulas
