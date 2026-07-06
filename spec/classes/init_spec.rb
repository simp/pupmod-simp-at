require 'spec_helper'

describe 'at' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('at') }
          it { is_expected.to create_package('at') }
          it { is_expected.to create_at__user('root') }
          # /etc/at.allow is the at(1) allow-list: only the users listed in it
          # may schedule jobs. It must be root-owned and not world-readable (a
          # readable allow-list leaks who is permitted to schedule work), so
          # assert the mode/ownership, not merely that the file is managed.
          it do
            is_expected.to create_concat('/etc/at.allow')
              .with(
                owner: 'root',
                group: 'root',
                mode: '0600',
              )
          end
          it { is_expected.to create_file('/etc/at.deny').with({ ensure: 'absent' }) }
          it do
            is_expected.to create_service('atd')
              .with(
                ensure: 'running',
                enable: true,
                hasstatus: true,
                hasrestart: true,
              )
          end
        end

        context 'with a users parameter' do
          let(:params) do
            {
              users: ['test', 'foo', 'bar'],
            }
          end

          it { is_expected.to create_at__user('test') }
          it { is_expected.to create_at__user('foo') }
          it { is_expected.to create_at__user('bar') }

          # root must always be permitted, in addition to any explicitly listed
          # users -- otherwise enabling the allow-list would lock root out of
          # at(1). The default-parameters context above only proves root is
          # added when `users` is empty; this proves it is not dropped when
          # users are supplied.
          it { is_expected.to create_at__user('root') }
        end
      end
    end
  end
end
