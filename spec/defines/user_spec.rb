require 'spec_helper'

describe 'at::user' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'with default parameters' do
          let(:title) { 'foobar' }
          it { is_expected.to create_simpcat_fragment('at+foobar.user').with_content("#{title}\n") }
        end

        context 'with a name that requires substitution' do
          let(:title) { 'foo/bar' }
          it { is_expected.to create_simpcat_fragment('at+foo__bar.user').with_content("#{title}\n") }
        end

      end
    end
  end
end
