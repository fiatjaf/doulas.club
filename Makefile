all:
	echo "nothing"

json-docs:
	python ./scripts/preprocess.py

couch-docs:
	make json-docs
	python ./scripts/senddocs.py
