#!make
CONTAINER_NAME:=filters-notebook
NOISE_DIR:=noises
ANIMALS_DIR:=animals

all:clean filter spectro
	echo "look in ./production"

filter:
	cp -r src notebook-home
	cp -r ${NOISE_DIR} notebook-home
	cp config.ini notebook-home
	docker exec -i ${CONTAINER_NAME} bash -c 'python ./src/filter/convert.py -i ${NOISE_DIR} -o production -c config.ini'
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${NOISE_DIR}
	-rm notebook-home/config.ini
	mv notebook-home/production/* ./production

spectro:
	cp -r src notebook-home
	cp -r ${ANIMALS_DIR} notebook-home
	cp -r ${NOISE_DIR} notebook-home
	docker exec -i ${CONTAINER_NAME} bash -c 'python ./src/spectro/draw.py -i ${ANIMALS_DIR},${NOISE_DIR} -o production'
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${ANIMALS_DIR}
	-rm -Rf notebook-home/${NOISE_DIR}
	mv notebook-home/production/* ./production/

clean:
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${NOISE_DIR}
	-rm -Rf notebook-home/${ANIMALS_DIR}
	-rm -Rf notebook-home/production
	-rm -Rf ./production/*
	-rm notebook-home/config.ini
	mkdir notebook-home/production
