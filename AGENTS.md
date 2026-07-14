# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`pupmod-simp-at` is a SIMP Puppet module that manages the `at`/`atd` job
scheduler on Enterprise Linux systems. It installs the `at` package, keeps the
`atd` service running, and manages the `at(1)` access-control files
(`/etc/at.allow` and `/etc/at.deny`) as an **allow-list**: only users listed in
`/etc/at.allow` may schedule `at` jobs.

### Business logic

The module is two files:

- **`at` (`manifests/init.pp`)** — the main class.
  - **`$users`** (`Array[String]`, default `[]`) — additional users to permit.
    Each becomes an `at::user` resource.
  - **`$package_ensure`** (`String`, default `'installed'`) — the `ensure` value
    for the `at` package. Note this is a **plain default**, *not* a
    `simp_options::package_ensure` `simplib::lookup` (unlike many SIMP modules);
    the module has no `simp/simplib` dependency.
  - Always declares `at::user { 'root': }` in addition to any `$users`, so
    enabling the allow-list never locks root out of `at(1)`.
  - Manages `concat { '/etc/at.allow': }` with `order => 'alpha'`,
    `owner => 'root'`, `group => 'root'`, `mode => '0600'`,
    `ensure_newline => true`. The `0600`/root ownership matters: a
    world-readable allow-list would leak who is permitted to schedule work.
  - Manages `file { '/etc/at.deny': ensure => 'absent', require => Package['at'] }`
    — under an allow-list model the deny-list is removed.
  - Declares `package { 'at': }` and `service { 'atd': ensure => 'running',
    enable => true, hasstatus => true, hasrestart => true }`; both the service
    and `/etc/at.deny` `require => Package['at']`.

- **`at::user` (`manifests/user.pp`)** — defined type; adds one user to the
  allow-list. It `include 'at'`, strips whitespace from the name
  (`$_name = strip($name)`), sanitises `/` to `__` for the fragment resource
  title (`$_safe_name = regsubst($_name,'/','__')`), and declares a
  `concat_fragment { "at+${_safe_name}.user": target => '/etc/at.allow',
  content => $_name }`. The `alpha` ordering on the concat means the resulting
  file is sorted regardless of declaration order.

There are no facts, functions, or templates, and no conditional OS logic in the
manifests. OS coverage comes from `metadata.json` and the acceptance node sets.

## Dependencies

- `puppetlabs/concat` (`>= 6.4.0 < 10.0.0`) — provides `concat` / `concat_fragment`.
- `puppetlabs/stdlib` (`>= 8.0.0 < 10.0.0`).
- Runtime: `openvox >= 8.0.0 < 9.0.0` (see `metadata.json` `requirements`).

Note: no `simp/simplib` dependency — this module does not use `simplib::lookup`.

## Repository layout

- `manifests/init.pp` — class `at`.
- `manifests/user.pp` — defined type `at::user`.
- `spec/classes/init_spec.rb` — rspec-puppet unit tests for `at`.
- `spec/defines/` — rspec-puppet unit tests for `at::user`.
- `spec/acceptance/suites/default/` — beaker acceptance suite; `nodesets/` holds
  the per-OS node definitions.
- `REFERENCE.md` — generated Puppet Strings reference (do not hand-edit; regenerate).
- `metadata.json` — module metadata, dependencies, and supported OS matrix.

## Common commands

Tasks come from `Simp::Rake::Pupmod::Helpers` (see `Rakefile`).

```sh
bundle install

# Unit tests (rspec-puppet)
bundle exec rake spec

# Lint / style
bundle exec rake lint
bundle exec rake rubocop

# Regenerate REFERENCE.md after changing manifest docstrings
bundle exec puppet strings generate --format markdown --out REFERENCE.md

# Acceptance tests (beaker; CI uses podman-backed container node sets)
bundle exec rake beaker:suites[default]
```

Note `.rspec` sets `--fail-fast`, so `rake spec` stops at the first failure.

## Conventions

- This is a component of the SIMP ecosystem. Follow SIMP module conventions.
- The allow-list model is the security posture of this module: `/etc/at.allow`
  must stay root-owned and `0600`, root must always be permitted, and
  `/etc/at.deny` is kept absent. Preserve these when changing the manifests.
- Keep manifest parameter `@param` docstrings current — `REFERENCE.md` is
  generated from them.
