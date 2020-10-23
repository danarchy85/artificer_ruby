# ArtificerRuby
A Ruby gem to facilitiate routines in Artifactory

It is configuration-driven and running the program without any arguments
will run through an initial startup with example configurations. 

This configuration will open your `ENV['EDITOR']` or `/bin/vi` to allow you
to edit the files before saving them to `ENV['HOME']/.config/artificer_ruby/`,
so ensure that your editor is chosen or VI is installed.

## Initialization
There is no gem up on rubygems.org yet, so for now:
To begin, checkout this repository and then run `bundler install` within the rootdir.

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

Now run `bin/artificer_ruby` without any arguments and it will walk you through
setting up your configuration and authentication and will save them to 
ENV['HOME']/.config/artificer_ruby/.

Up first is the program's configuration. Schedule defines how frequently routines will
run and is input in standard crontab format. date_format configures the format of the
datestamp that is used to name new local repositories. Default settings are probably okay.

**Note!** avoid using `/,\,:,|,?,<,>,*,"` in date_format as it is incompatible with
Artifactory repository naming schemas.

    :~/github/artificer_ruby git:(main) $ bin/artificer_ruby start
    Creating configuration directories at: /home/dan/.config/artificer_ruby
    ---
    schedule: 0 0 7 * * *
    date_format: "%Y%m%d_%H%M%S"
    http_timeout: 300

    Do any changes need to be made to '/home/dan/.config/artificer_ruby/config.yaml'? (Y/N): n

Next is authentication. This one will likely need to be edited, so enter 'Y' to launch your editor.
Enter your Artifactory endpoint with the /artifactory/ directory and end with a forwardslash '/'.
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

    Do any changes need to be made to '/home/dan/.config/artificer_ruby/auth.yaml'? (Y/N): n

And finally is the repository_group configuration. Each repository group controls a remote, local,
and virtual repository, as well as the routines to run on these repositories and an archive. 
We'll get back to routines and archiving later.

This built-in example configures configures two repository groups.

First is a group for Oracle Linux 8 BaseOS and its routines and remote, local, and virtual repositories. 
And the second group for Oracle Linux 8 EPEL with routines and remote, local, and virtual repositories.
    
    ---
    OL8_BaseOS:
    routines:
        - prepare_new_local_repository
        - cache_remote_repository:
          - "/repodata/"
          - 5
        - copy_remote_repository_cache
        - update_virtual_repositories
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
    archive: []
    OL8_EPEL:
    routines:
        - cache_remote_repository:
        - "/repodata/"
        - 5
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
    

## Use

Now that ArtificerRuby has been configured, it can be ran again with 'start' to launch the daemon. 
This will run ArtificerRuby in daemon mode, which will run routines per our scheduled cron set
in the first config file `ENV['HOME']/.config/artificer_ruby/config.yaml`. 

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
    copying remote.OL8_BaseOS-cache: to local.OL8_BaseOS.20201023_015503: completed successfully, 0 artifacts and 1 folders were copied
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
    
### Routines
*to do*

### Archives
*to do*
