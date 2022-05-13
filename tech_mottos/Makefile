default: package

.PHONY: fmt
fmt:
	black .
	isort .

.PHONY: lint
lint:
	flake8

requirements.txt: poetry.lock
	poetry export > $@

package: *.py poetry.lock requirements.txt
	mkdir -p $@
	cp *.py $@
	poetry run pip install --target ./$@ -r requirements.txt

.PHONY: clean
clean:
	rm -rf requirements.txt package
