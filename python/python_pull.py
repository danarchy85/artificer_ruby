#!/usr/bin/env python

import yaml
import os, sys, getopt
from artifactory import ArtifactoryPath

class SyncRepo:
    def __init__(self, _auth, _basedir):
        global auth, basedir
        auth = _auth
        basedir = _basedir
        print('Loaded auth ' + auth['endpoint'])

    def connector_path(self, path):
        path = auth['endpoint'] + path
        if 'username' in auth and 'password' in auth:
            path = ArtifactoryPath(path, auth=(auth['username'], auth['password']))
        elif 'api_key' in auth:
            path = ArtifactoryPath(path, apikey=auth['api_key'])

        return path

    def fetch_file_list(self, repo):
        path = repo['key'] + basedir
        print('Fetching files at: ' + path)
        path = self.connector_path(path)

        artifacts = dict()
        p = '.' if basedir == '/' else basedir
        query = ["items.find",
                 { "$and": [{ "repo": { "$eq": repo['key'] } },
                            { "path": { "$match": p } }] }]

        print(path.aql(*query))
        for a in path.aql(*query):
            print(a)
            artifacts[a['name']] = a

        return artifacts

    def compare_file_sets(self, r_files, l_files):
        files_to_copy = list()
        for name, f in r_files.items():
            if name not in l_files:
                print('New file: ' + name)
                files_to_copy.append(name)
            else:
                lf = l_files[name]
                r_sha256 = self.get_sha256_sum(f['repo'] + basedir + name)
                l_sha256 = self.get_sha256_sum(lf['repo'] + basedir + name)

                if r_sha256 != l_sha256:
                    print('Files differ: ' + name)
                    files_to_copy.append(name)

        return files_to_copy

    def get_sha256_sum(self, f):
        path = self.connector_path('/' + f)
        return ArtifactoryPath.stat(path).sha256


def main(rgroup, argv):
    cfgdir = os.environ['HOME'] + '/.config/artificer_ruby/'
    with open(cfgdir + 'auth.yaml') as file:
        auth = yaml.full_load(file)

    # with open(cfgdir + 'repository_groups.yaml') as file:
    with open('./example_repository_groups.yaml') as file:
        rgroups = yaml.full_load(file)

    basedir = '/'
    try:
        opts, args = getopt.getopt(argv, "hd:", ["dir="])
    except getopt.GetoptError:
        print('python_pull.py -r repository_group -d /repodata/')
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print('python_pull.py -r repository_group -d /repodata/')
        elif opt in ('-d', '--dir'):
            basedir = arg

    sync   = SyncRepo(auth, basedir)
    rgroup = rgroups[rgroup]

    r_repo = rgroup['repos']['remote']
    r_files = sync.fetch_file_list(r_repo)

    l_repo = rgroup['repos']['local']
    l_files = sync.fetch_file_list(l_repo)

    files_to_copy = sync.compare_file_sets(r_files, l_files)
    # sync.copy_files_remote_to_local(files_to_copy, r_repo, l_repo)
    print(files_to_copy)


if __name__ == '__main__':
    argv = sys.argv[1:]
    if argv == []:
        print('python_pull.py requires a repository group name. Ex: OL8_EPEL')
        print(' optionally, -d /dirname/ can be provided to sync that directory.')
    else:
        rgroup = argv.pop(0)
        main(rgroup, argv)

