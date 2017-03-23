#!/bin/bash

MINICONDA_VERSION=${MINICONDA3_VERSION:-4.2.12}
MINICONDA_BASE_URL=${MINICONDA_BASE_URL:-https://repo.continuum.io/miniconda}
PYVER_PREFIX=3
ANA_PLATFORM="Linux-x86_64"

miniconda_file_name="Miniconda${PYVER_PREFIX}-${MINICONDA_VERSION}-${ANA_PLATFORM}.sh"
curl -# -L -O "${MINICONDA_BASE_URL}/${miniconda_file_name}"
bash "$miniconda_file_name" -b -p "/miniconda"
