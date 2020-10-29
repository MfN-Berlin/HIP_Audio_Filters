#!make
.DEFAULT_GOAL:=all
CONTAINER_NAME:=filters-notebook

all:clean
	cp -r src notebook-home
	cp -r material notebook-home
	cp config.ini notebook-home
	mkdir notebook-home/production
	docker exec -i ${CONTAINER_NAME} bash -c 'python ./src/filter/convert.py -i material -o production -c config.ini'
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/material
	-rm notebook-home/config.ini
	mv notebook-home/production .

clean:
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/material
	-rm notebook-home/config.ini
