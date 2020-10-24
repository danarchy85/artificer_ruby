#!/usr/bin/env python

import yaml
import os
from artifactory import ArtifactoryPath

class SyncRepo:
    def __init__(self, auth, rgroups, rgroup):
        print('Running')


if __name__ == '__main__':
    sync = SyncRepo('','','')

    cfgdir = os.environ['HOME'] + '/.config/artificer_ruby/'
    with open(cfgdir + 'auth.yaml.bkp') as file:
        auth = yaml.full_load(file)

    print(auth)

    with open(cfgdir + 'repository_groups.yaml') as file:
        rgroups = yaml.full_load(file)

    print(rgroups)
