[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/at.svg)](https://forge.puppetlabs.com/simp/at)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/at.svg)](https://forge.puppetlabs.com/simp/at)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-at.svg)](https://travis-ci.org/simp/pupmod-simp-at)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [This is a SIMP module](#this-is-a-simp-module)
* [Setup](#setup)
  * [What at affects](#what-at-affects)
* [Usage](#usage)
* [Reference](#reference)
* [Development](#development)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Description

This module manages the at service and /etc/at.allow.

## This is a SIMP module
This module is a component of the
[System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).


## Setup


### What at affects

  * atd service
  * `/etc/at.deny`
  * `/etc/at.allow`

## Usage

To use this module, simply include the class as follows:

```ruby
include 'at'
```

Users can also be added to `/etc/at.allow` with the `at::user` defined type, or
the `at::users` array in `hiera`. The following example adds a few users to
`/etc/at.allow`:

```yaml
at::users:
  - foo
  - bar
```


## Reference

Please refer to the inline documentation within each source file, or to the
module's generated `YARD` documentation for reference material.


## Development

Please read our [Contribution Guide] (https://simp.readthedocs.io/en/stable/contributors_guide/index.html).


### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md)
for more information.
