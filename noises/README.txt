## Before you start
Make sure Docker and Docker-compose are installed.
Start the Docker containers: `docker-compose up -d`
Examine the filters by opening `localhost:9081` (the first time you'll need to set a password).

## Filter noise files according to animal hearing ranges
* Place the noise recordings to be converted here: `noises`.
* Make sure the filters are configured in `config.ini`
* call `make filter`
* The resulting filtered audio files will be placed here: `production`

## Draw spectrograms of animals
* Place the animal recordings here: `animals`
* call `make spectro`
* The resulting spectrograms will be placed here: `production`

