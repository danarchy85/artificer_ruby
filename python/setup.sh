#!/bin/bash

virtualenv ./venv
source ./venv/bin/activate
pip install -r ./requirements.txt
echo "Running 'python python_pull.py'"
python ./python_pull.py
