# HIP_Audio_Filters
Audio Filters für Hearing in Penguins



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
Rscript -e "devtools::install_github('IRkernel/IRkernel')";
Rscript -e "IRkernel::installspec()";
```

## First-time connecting to the notebook
While in the notebook (see above), call `jupyter notebook list` to get the notebooks security token.

Open `http://localhost:9081` in a browser
At the bottom of the page, under "Setup a password", paste the token and set your password.

### Debugging
Logs can be seen by calling `docker logs filters-notebook`.


