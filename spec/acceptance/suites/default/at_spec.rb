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
      it 'works with default values' do
        apply_manifest_on(host, manifest, catch_failures: true)
      end

      it 'is idempotent' do
        apply_manifest_on(host, manifest, catch_changes: true)
      end

      # `catch_changes: true, noop: true` is not a valid check: `puppet apply
      # --noop` always exits 0 regardless of pending changes, so that assertion
      # can never fail. Real idempotency is covered above; here we verify the
      # security-relevant end state on disk, which is the point of this module.
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
