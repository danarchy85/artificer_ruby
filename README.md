<<<<<<< Updated upstream
# python_pull.py

This branch is specifically for a python script which compares a remote repository to a
local repository and copies over and new or modified files.

The script depends on ArtificerRuby to generate configurations for authentication and
repository groups, so run that first from the 'main' git branch.

Checkout this 'python_script' branch again once those configurations exist, and then run
`cd python && bash ./setup.sh` to create a virtualenv and pull in the needed pip dependencies.

Within the python directory run `source ./venv/bin/activate` and `python python_pull.py`,
=======
<<<<<<< Updated upstream
=======
# python_pull.py

This branch is specifically for a python script which compares a remote repository to a
local repository and copies over new or modified files.

The script depends on ArtificerRuby to generate configurations for authentication and
repository groups and to cache the remote repository's artifacts, so run that first from
the 'main' git branch.

The ArtificerRuby::Routine `cache_remote_repository` will handle caching the remote repository.
The default repository_groups.yaml ArtificerRuby installs assumes this with a limit `- 5` to
minimize the amount of data copied in this example.

For example:

    OL8_EPEL:
    routines:
    - cache_remote_repository:
        - "/repodata/"
        - 5
    repos:
      remote:
        key: remote.OL8_EPEL
        rclass: remote
        package_type: rpm
        url: https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/x86_64
        description: Remote - Oracle Linux 8 (x86_64) EPEL
      local:
        key: local.OL8_EPEL
        rclass: local
        package_type: rpm
      virtual:
        key: virtual.OL8_EPEL
        rclass: virtual
        package_type: rpm
        repositories:
        - local.OL8_EPEL"

To run the python_pull.py script, Checkout this 'python_script' branch again once those
configurations exist, and then run `cd python && bash ./setup.sh` to create a virtualenv
and pull in the needed pip dependencies.

Within the same ./python directory run `source ./venv/bin/activate` and `python python_pull.py`,
>>>>>>> Stashed changes
to output the script's help info.

python_pull.py requires a repository group name be provided and it can also take an optional
directory argument:

    :~/github/artificer_ruby git:(python_script) $ cd ./python && bash ./setup.sh
    :~/github/artificer_ruby/python git:(python_script) $ source ./venv/bin/activate
    (venv) :~/github/artificer_ruby/python $ python python_pull.py
    python_pull.py requires a repository group name. Ex: OL8_EPEL
        optionally, -d /dirname/ can be provided to sync that directory.
    Example: python python_pull.py OL8_EPEL -d /repodata/

<<<<<<< Updated upstream
-------------------------
=======
Running python_pull.py on the OL8_EPEL repository group on the /repodata/ directory will
grab directory listings of both repositories, compare them to one another, and if a file
does not exist on the local repository, or does not match the remote file's sha256 sum,
it will copy over the file to add or update it in the local repository.

In this example, 6 files exist on the remote cache, and 2 of those files with older content
already exist on the local repository. It will copy over the four new files, and overwrite
the two updated files.

    (venv) :~/github/artificer_ruby/python  $ python python_pull.py OL8_EPEL -d repodata
    Loaded auth http://localhost:8082/artifactory/
    Fetching file list from: remote.OL8_EPEL-cache/.
    Found 6 artifacts.
    Fetching file list from: local.OL8_EPEL/.
    Found 2 artifacts.
    New file: Gemfile
    New file: Gemfile.lock
    Files differ: LICENSE
    Files differ: README.md
    New file: Rakefile
    New file: artificer_ruby.gemspec

    Copying files from remote.OL8_EPEL-cache/ to local.OL8_EPEL/
    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Gemfile
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/Gemfile
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Gemfile to http://localhost:8082/artifactory/local.OL8_EPEL/Gemfile

    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Gemfile.lock
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/Gemfile.lock
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Gemfile.lock to http://localhost:8082/artifactory/local.OL8_EPEL/Gemfile.lock

    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/LICENSE
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/LICENSE
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/LICENSE to http://localhost:8082/artifactory/local.OL8_EPEL/LICENSE

    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/README.md
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/README.md
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/README.md to http://localhost:8082/artifactory/local.OL8_EPEL/README.md

    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Rakefile
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/Rakefile
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/Rakefile to http://localhost:8082/artifactory/local.OL8_EPEL/Rakefile

    Source: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/artificer_ruby.gemspec
    Destination: http://localhost:8082/artifactory/local.OL8_EPEL/artificer_ruby.gemspec
    Copied: http://localhost:8082/artifactory/remote.OL8_EPEL-cache/artificer_ruby.gemspec to http://localhost:8082/artifactory/local.OL8_EPEL/artificer_ruby.gemspec

This should result in a local repository collecting remote artifacts over time, updating modified files, and retaining old files
when removed from the remote repository.

-------------------------
>>>>>>> Stashed changes
>>>>>>> Stashed changes
# ArtificerRuby
A Ruby gem to facilitiate routines in Artifactory

It is configuration-driven and running the program without any arguments
will run through an initial setup with example configurations provided.

This configuration process will open your `ENV['EDITOR']` or `/bin/vi`
to allow you to edit the files before saving them to `~/.config/artificer_ruby/`,
so ensure that your editor is defined or that Vi is installed. If neither is
available, answer `N` on each prompt and then edit the files however you do so.


## Initialization
To begin, there is no gem up on rubygems.org yet, so for now:

Checkout this repository and then run `bundler install` within the rootdir.

    :~/github $ git clone https://github.com/danarchy85/artificer_ruby.git
    :~/github $ cd artificer_ruby
    :~/github/artificer_ruby git:(main) $ bundle install
    Using rake 12.3.3
    Using artifactory 3.0.15
    Using concurrent-ruby 1.1.7
    Using tzinfo 2.0.2
    Using et-orbi 1.2.4
    Using raabro 1.4.0
    Using fugit 1.3.9
    Using rufus-scheduler 3.6.0
    Using artificer_ruby 0.1.0 from source at `.`
    Using bundler 2.1.4
    Bundle complete! 2 Gemfile dependencies, 10 gems now installed.
    Use `bundle info [gemname]` to see where a bundled gem is installed.

You can also build RDoc content to read technical documentation within a web browser.

    github/artificer_ruby git:(release_0.1.0) $ rdoc --main README.md
    github/artificer_ruby git:(release_0.1.0) $ firefox ./doc/index.html

Now, within this directory, run `bin/artificer_ruby` without any arguments and it
will walk you through setting up your configuration and authentication and will
save them to `~/.config/artificer_ruby/`.

### config.yaml

Up first is the program's configuration. Default settings are probably okay.

schedule:     crontab format string to define how frequently routines will run. 
date_format:  configures the format of the datestamp that is used to name new local repositories.
http_timeout: sets the allowable time for HTTP requests to cache artifacts.

**Note!** schedule: crontab needs 6 items (eg: 0 7 1 * * *) or the daemon will hang indefinitely.

**Note!** date_format: avoid using `/,\,:,|,?,<,>,*,"` in date_format as it is incompatible with
Artifactory's repository naming schemas. For example: `%Y-%m-%d_%H:%M:%S` will error upon
repository creation in Artifactory due to the colons in the time. `%Y%m%d_%H%M%S` is the default.

    :~/github/artificer_ruby git:(main) $ bin/artificer_ruby
    Creating configuration directories at: /home/dan/.config/artificer_ruby
    ---
    schedule: 0 7 1 * *
    date_format: "%Y%m%d_%H%M%S"
    http_timeout: 300

    Do any changes need to be made to '/home/dan/.config/artificer_ruby/config.yaml'? (Y/N): n

### auth.yaml

Next is authentication. This one will likely need to be edited, so enter `Y` to launch your editor.
Enter your Artifactory endpoint with the /artifactory/ directory appended with a trailing forwardslash '/'.
Enter your username and password, or use an api_key, and configure any other authentication settings
that may be required for your setup. Null fields can be left in place or removed.
    
    ---
    endpoint: http://127.0.0.1:8080/artifactory/
    username: admin
    password: password
    api_key: null
    proxy_address: null
    proxy_password: null
    proxy_port: null
    proxy_username: null
    ssl_pem_file: null
    ssl_verify: null
    user_agent: null
    read_timeout: null

    Do any changes need to be made to '/home/dan/.config/artificer_ruby/auth.yaml'? (Y/N): y

### repository_groups.yaml

And finally is the repository_group configuration. Each repository group controls a remote, local,
and virtual repository, as well as the routines to run on these repositories as well as an archive
of previous local repositories. Routines and archive is documented further down.

This built-in example configures two repository groups: 'OL8_BaseOS' and 'OL8_EPEL'.
I'll break down each one of these groups and how to configure them in more detail later.

    ---
    OL8_BaseOS:
    routines:
      - create_archive_local_repository
      - cache_remote_repository:
          - "/repodata/"
          - 5
      - copy_remote_repository_cache
      - update_virtual_repositories
    repos:
      remote:
        key: remote.OL8_BaseOS
        rclass: remote
        package_type: rpm
        url: https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64
        description: Remote - Oracle Linux 8 (x86_64) BaseOS Latest
      local:
        key: local.OL8_BaseOS
        rclass: local
        package_type: rpm
      virtual:
        key: virtual.OL8_BaseOS
        rclass: virtual
        package_type: rpm
        repositories:
        - local.OL8_BaseOS
    OL8_EPEL:
    routines:
    - cache_remote_repository:
        - "/repodata/"
        - 5
    repos:
      remote:
        key: remote.OL8_EPEL
        rclass: remote
        package_type: rpm
        url: https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/x86_64
        description: Remote - Oracle Linux 8 (x86_64) EPEL
      local:
        key: local.OL8_EPEL
        rclass: local
        package_type: rpm
      virtual:
        key: virtual.OL8_EPEL
        rclass: virtual
        package_type: rpm
        repositories:
        - local.OL8_EPEL

    Do any changes need to be made to '/home/dan/.config/artificer_ruby/repository_groups.yaml'? (Y/N): n
    
Finally, if authentication was successful, The program should exit back out after verifying 
connection to Artifactory

    Connected to Artifactory: http://127.0.0.1:8080/artifactory/
    
If this yields a connection error, verify that your settings are correct in `~/.config/artificer_ruby/auth.yaml`

# Usage

Now that ArtificerRuby has been configured, it can be ran again with `start` to launch the daemon;
forking a process and exiting back out. This will run ArtificerRuby in daemon mode, which will run
routines per our scheduled cron defined in `~/.config/artificer_ruby/config.yaml`. 

To see the output shown below, logs are placed in `~/.config/artificer_ruby/logs/`.

Here is example output from the default repository_groups.yaml configured above:

    :~/github/artificer_ruby git:(main) $ bin/artificer_ruby start
    Starting ArtificerRuby
    Connected to Artifactory: https://danarchy.jfrog.io/artifactory/
    Running routines: 2020-10-23 01:55:00 UTC

    Running routines for repository group: OL8_BaseOS
    Applying repository: remote.OL8_BaseOS
    Applying repository: local.OL8_BaseOS.20201023_014705
    Applying repository: virtual.OL8_BaseOS
    Archived: local.OL8_BaseOS.20201023_014705
    New local repository: local.OL8_BaseOS.20201023_015503
    Applying repository: local.OL8_BaseOS.20201023_015503
    Caching artifacts in: remote.OL8_BaseOS/repodata/
    Cached (1/199): 03416e5fcbebbccb4cfdd553169d5c025248f274-updateinfo.xml.gzl.gz
    Cached (2/199): 03622d91356b19b76a367b5b9fda0c93a3f91709-other.sqlite.bz2.bz2
    Cached (3/199): 04623a8703b35f34c4b04389137b69cc4b47a025-other.xml.gzl.gz
    Cached (4/199): 04ba03a9022ca64728e57dec4bef73b92a2b8d85-updateinfo.xml.gzl.gz
    Cached (5/199): 04c3e4573146b796e45493fb0d3077fa06d53240-primary.xml.gzl.gz
    copying remote.OL8_BaseOS-cache: to local.OL8_BaseOS.20201023_015503: completed successfully, 5 artifacts and 1 folders were copied
    Swapped virtual repository: local.OL8_BaseOS.20201023_014705 => local.OL8_BaseOS.20201023_015503
    Applying repository: virtual.OL8_BaseOS

    Running routines for repository group: OL8_EPEL
    Applying repository: remote.OL8_EPEL
    Applying repository: local.OL8_EPEL
    Applying repository: virtual.OL8_EPEL
    Caching artifacts in: remote.OL8_EPEL/repodata/
    Cached (1/199): 07aab311753e334600686eda6f13f075b9540dfe-primary.sqlite.bz2z2
    Cached (2/199): 081a0c7fa70b3577d434a238d7e31a9edb03c233-filelists.sqlite.bz2z2
    Cached (3/199): 09b3780ab325d9d39a7bc840376172853ac35478-updateinfo.xml.gzgz
    Cached (4/199): 09ba6052f97aa03ef34b2293a53a4f74da6ac3d8-filelists.xml.gzgz
    Cached (5/199): 0a5f84004c4e4e19bacf43a49287c92ea75e5aaf-primary.sqlite.bz2z2
    Finished: 2020-10-23 01:55:14 UTC (14.28 seconds)
    
## Repository group configuration

Let's go through the 'OL8_BaseOS' repository group example above.

### Routines

Routines are defined as an array of strings or hashes. The string or hash key must be
one of the methods found in the ArtificerRuby::Routines class. If a method is misspelled,
or simply does not exist, the program will skip the rest of this group's routines and
continue on to any other repository groups.

If the routine is a string as `create_archive_local_repository` is in this example, it will call
that method with no arguments passed.

If the routine is a hash as `cache_remote_repository` is in this example, the key is the method name,
and its value is an array of arguments that will be passed to that called method. This example passes
`['/repodata/', 5]` as the path to be cached, and 5 as the limit to number of artifacts to cache.
This limit is purely for testing/debugging and is probably not something most users will use, but it
is set in this example to prevent a full replication of Oracle Linux 8's repository.

The `copy_remote_repository_cache` routine also accepts arguments, but in this case it will copy the full repository,
so no argument is passed.

See each routine's documentation in RDoc for what arguments are accepted.

    ---
    OL8_BaseOS:
    routines:
      - create_archive_local_repository
      - cache_remote_repository:
          - "/repodata/"
          - 5
      - copy_remote_repository_cache
      - update_virtual_repositories

### Repositories

Next we have this group's repositories defined. The keys 'remote','local','virtual' are treated 
as static references in code to each corresponding repository. The naming of your repository is done
within the hash as the `key` parameter. These entries match the parameter of Artifactory repositories,
so see their documentation for what parameters are allowed or required.

    repos:
      remote:
        key: remote.OL8_BaseOS
        rclass: remote
        package_type: rpm
        url: https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64
        description: Remote - Oracle Linux 8 (x86_64) BaseOS Latest
      local:
        key: local.OL8_BaseOS
        rclass: local
        package_type: rpm
      virtual:
        key: virtual.OL8_BaseOS
        rclass: virtual
        package_type: rpm
        repositories:
        - local.OL8_BaseOS

## Archive

Archive is a feature that is a result of the `Repositories.generate_and_archive_local_repository` method,
which is called within the `create_archive_local_repository` routine. See that method's documentation for
more details, but in short: it creates a new local repository based on the remote repository that will
replace the existing local repository.

Its new name is taken from the remote repository's key with `remote` replaced with `local`, then a
datestamp suffix added per Config.date_format, so `remote.OL8_BaseOS` becomes `local.OL8_BaseOS.20201023_221431`.

The existing local repository's configuration is pushed into the archive array on the repository group for safe keeping.

In this example, the routines continue on with `cache_remote_repository` which caches the remote artifacts
so that its contents can be copied with `copy_remote_repository_cache` to the new datestamped local repository.
And finally it runs `update_virtual_repositories` to update the virtual repository; swapping the old local
repository key with the new.

Below shows that routines have been run twice because there are two archives in the array at the bottom.
And it shows the local repository is newly datestamped with `20201023_221431`, and the virtual repository
references it.


    routines:
      - create_archive_local_repository
      - cache_remote_repository:
          - "/repodata/"
          - 5
      - copy_remote_repository_cache
      - update_virtual_repositories
    repos:
      remote:
        key: remote.OL8_BaseOS
        rclass: remote
        package_type: rpm
        url: https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64
        description: Remote - Oracle Linux 8 (x86_64) BaseOS Latest
      local:
        key: local.OL8_BaseOS.20201023_221431
        rclass: local
        package_type: rpm
      virtual:
        key: virtual.OL8_BaseOS
        rclass: virtual
        package_type: rpm
        repositories:
        - local.OL8_BaseOS.20201023_221431
    archive:
      - key: local.OL8_BaseOS.20201023_211204
        rclass: local
        package_type: rpm
      - key: local.OL8_BaseOS.20201023_211604
        rclass: local
        package_type: rpm

### Archive cleanup

Should you want to clean up *all* archives, add the routine `purge_archive`, which runs the `Repositories.cleanup_archive`
to do just that. For example, running it as the first routine would leave you with an active local repository and the
previous one archived.
