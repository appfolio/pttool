# PTTool: Command line tool that interfaces with pivotaltracker


### Installation

    gem install pttool

## Usage

In order to use this tool, the environment variable `PT_TOKEN` must be set to
your PivotalTracker API key. The key is listed under the "API TOKEN" section at
the bottom of your PivotalTracker
[profile](https://www.pivotaltracker.com/profile)."

### Obtain List of PivotalTracker Projects

    pttool projects

Its output will look similar to:

     1130000: Engineering Backlog
      820000: Product Backlog

### Synchronize Users Across Projects

    pttool sync "Engineering Backlog" "Product Backlog"

The above command will obtain a list of users for both of the PivotalTracker
projects, and then prompt you to add the missing users. Its output looks
similar to:

    Do you want to add 28 people to Engineering Backlog? [(y)es|(N)o|(a)bort]
    Do you want to add 34 people to Product Backlog? [(y)es|(N)o|(a)bort]

If you want to see which users are to be added try the `--dryrun` option:

    pttool sync "Engineering Backlog" "Product Backlog" --dryrun

Its output looks like:

    The following would become members on all projects:
    Captain Hook (hook@never.land)
    Peter Pan (pan@never.land)
    Tinker Bell (tink@never.land)

    New members for Engineering Backlog:
    Tinker Bell (tink@never.land)

    New members for Product Backlog:
    Peter Pan (pan@never.land)

### Other

To see a list of all commands simply run `pttool` or `pttool --help`.


## Copyright and license

Source released under the Simplified BSD License.

* Copyright (c), 2015, AppFolio, Inc
* Copyright (c), 2015, Bryce Boe
