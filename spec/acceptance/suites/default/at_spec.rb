require 'spec_helper_acceptance'

test_name 'at'

describe 'at class' do
  let(:manifest) do
    <<-EOS
      include 'at'
    EOS
  end

  let(:manifest_users) do
    <<-EOS
      class { 'at':
        users => ['joe', ' mary ']
      }
      at::user {' george': }
    EOS
  end

  let(:expected_content) do
    <<~EOS
      george
      joe
      mary
      root
    EOS
  end

  context 'on each host' do
    hosts.each do |host|
      # Exercise noop from a clean (uninstalled) state. The Sicura console runs
      # modules under `puppet apply --noop` to preview changes on a node, and
      # that run must not fail on a fresh system where the managed package is
      # still absent -- resources whose compilation or guards assume `at` is
      # already present would explode under noop. A noop apply must report the
      # module's intended changes without enacting them, so `at` must remain
      # uninstalled afterward. Real convergence and idempotence are covered by
      # the 'when applied' context below.
      #
      # A *post-convergence* noop check is deliberately omitted: `puppet apply
      # --noop --detailed-exitcodes` always exits 0 regardless of pending
      # changes, so a catch_changes+noop assertion can never fail and would test
      # nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: a failure here should error the context
        # rather than abort the suite under --fail-fast. `puppet resource` exits
        # 0 whether it removes the package or finds it already absent (it does
        # not use --detailed-exitcodes), so no acceptable_exit_codes override is
        # needed.
        before(:context) do
          on(host, 'puppet resource package at ensure=absent')
        end

        it 'applies without errors in noop mode' do
          apply_manifest_on(host, manifest, catch_failures: true, noop: true)
        end

        it 'does not install the at package' do
          # rpm -q exits 1 when the package is absent; beaker raises on any
          # other exit code, so this asserts the noop run enacted nothing.
          on(host, 'rpm -q at', acceptable_exit_codes: [1])
        end
      end

      context 'when applied' do
        it 'works with default values' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end

        # End-state hardening coverage -- orthogonal to the noop check above and
        # the real point of this module.
        it 'enforces the hardened at.allow state on disk' do
          apply_manifest_on(host, manifest, catch_failures: true)

          # A readable allow-list leaks who may schedule at(1) jobs, so it must
          # be root-owned and mode 0600.
          perms = on(host, 'stat -c "%a %U %G" /etc/at.allow').stdout.strip
          expect(perms).to eq('600 root root')

          # root must always retain access to at(1).
          expect(on(host, 'cat /etc/at.allow').stdout).to match(%r{^root$})

          # /etc/at.deny must not exist: at.allow is the sole gate, and a present
          # deny-list would change at(1) semantics. `test` exits non-zero (and
          # beaker raises) if the file is present.
          on(host, 'test ! -e /etc/at.deny')
        end

        it 'adds users' do
          apply_manifest_on(host, manifest_users, catch_failures: true)
          at_allout_output = on(host, 'cat /etc/at.allow')
          expect(at_allout_output.stdout).to match(expected_content)
        end
      end
    end
  end
end
