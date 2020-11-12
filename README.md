# HIP_Audio_Filters
Audio Filters für Hearing in Penguins

[Filter overview](https://github.com/MfN-Berlin/HIP_Audio_Filters/wiki/Filters)


# Usage: filter audio files
1. Make sure docker and docker-compose are installed.
2. Place the audio files to be filtered in `noises`.
3. Start the notebook by calling `docker-compose up -d`.
4. Call `make filter`.
5. The filtered files will be placed in `production`.

# Usage: make spectrograms from audio files
1. Make sure docker and docker-compose are installed.
2. Place the audio files to be filtered in `animals` or `noises` (or both).
3. Start the notebook by calling `docker-compose up -d`.
4. Call `make spectro`.
5. The filtered files will be placed in `production`.

# Developer documentation
The following is only relevant if you wish to write your own notebooks.

## Installation
After cloning the repo, open the repo folder and
create a folder `notebook-home/.jupyter` and `notebook-home/.local`

```
cd HIP_Audio_Filters
mkdir -p notebook-home/.jupyter/
mkdir -p notebook-home/.local/
```

Call `docker-compose up -d` to start the notebook.

Open a terminal in the notebook

```
docker exec -ti filters-notebook script -q -c /bin/bash
```

While in the notebook, install the R kernel by calling

```
Rscript -e "IRkernel::installspec()";
```

## First-time connecting to the notebook
While in the notebook (see above), call `jupyter notebook list` to get the notebooks security token. Copy this token.
Type `exit` to return to the host computer.

Open `http://localhost:9081` in a browser
At the bottom of the page, under "Setup a password", paste the token and set your password.

### Debugging
Logs can be seen by calling `docker logs filters-notebook`.


