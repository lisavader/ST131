#!/bin/bash

#Create conda environment
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh
conda create -n mandrake python numpy pandas scipy scikit-learn tqdm hdbscan pp-sketchlib cmake pybind11 openmp matplotlib-base boost-cpp plotly ffmpeg
conda activate mandrake

#Clone git repository
cd ../tools
git clone https://github.com/johnlees/mandrake.git mandrake

#First time setup
cd mandrake
python setup.py install
