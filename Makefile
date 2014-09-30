json-docs:
	python ./scripts/preprocess.py

couch:
	make json-docs
	python ./scripts/senddocs.py
