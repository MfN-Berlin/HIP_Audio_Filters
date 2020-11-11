#!make
CONTAINER_NAME:=filters-notebook
NOISE_DIR:=noises
ANIMALS_DIR:=animals

filter:clean
	cp -r src notebook-home
	cp -r ${NOISE_DIR} notebook-home
	cp config.ini notebook-home
	mkdir notebook-home/production
	docker exec -i ${CONTAINER_NAME} bash -c 'python ./src/filter/convert.py -i ${NOISE_DIR} -o production -c config.ini'
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${NOISE_DIR}
	-rm notebook-home/config.ini
	mv notebook-home/production .

spectro:clean
	cp -r src notebook-home
	cp -r ${ANIMALS_DIR} notebook-home
	cp -r ${NOISE_DIR} notebook-home
	mkdir notebook-home/production
	docker exec -i ${CONTAINER_NAME} bash -c 'python ./src/spectro/draw.py -i ${ANIMALS_DIR},${NOISE_DIR} -o production'
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${ANIMALS_DIR}
	-rm -Rf notebook-home/${NOISE_DIR}
	mv notebook-home/production .

clean:
	-rm -Rf notebook-home/src
	-rm -Rf notebook-home/${NOISE_DIR}
	-rm -Rf notebook-home/${ANIMALS_DIR}
	-rm notebook-home/config.ini
