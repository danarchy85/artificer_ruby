#!/bin/bash

virtualenv ./venv
source ./venv/bin/activate
pip install -r ./requirements.txt
echo -e "\nRun 'source ./venv/bin/activate before running 'python python_pull.py'"
