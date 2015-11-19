require 'spec_helper'

describe 'out' do
  let(:proxy) { Billy::Proxy.new }
  let(:dest_dir) { Dir.mktmpdir }

  before { proxy.start }
  after  { proxy.reset }

  def git(cmd, dir = dest_dir)
    Dir.chdir(dir) { `git #{cmd}`.chomp }
  end

  def commit(msg)
    git("-c user.name='test' -c user.email='test@example.com' commit -q --allow-empty -m '#{msg}'")
    git('log --format=format:%H HEAD')
  end

  before do
    proxy.stub('https://api.github.com:443/repos/jtarchie/test/pulls/1')
      .and_return(json: {
      url: 'http://example.com',
      number: 1,
      head: { sha: 'abcdef' }
    })
    proxy.stub('https://api.github.com:443/repos/jtarchie/test/statuses/abcdef')
      .and_return(json: [])

    git('init -q')
    git('config --add pullrequest.id 1')
  end

  context 'when acquiring a pull request' do
    it 'sets into pending mode' do
      proxy.stub('https://api.github.com:443/repos/jtarchie/test/statuses/abcdef', method: :post)

      output = put(params: { status: 'pending' }, source: { repo: 'jtarchie/test' })
      expect(output).to eq('version'  => { 'ref' => 'abcdef', 'pr' => '1' },
                           'metadata' => [
                             { 'name' => 'url', 'value' => 'http://example.com'},
                             { 'name' => 'status', 'value' => 'pending' }
      ])
    end
  end

  context 'when the pull request is being release' do
    context 'and the build passed' do
      it 'sets into success mode' do
        proxy.stub('https://api.github.com:443/repos/jtarchie/test/statuses/abcdef', method: :post)

        output = put(params: { status: 'success' }, source: { repo: 'jtarchie/test' })
        expect(output).to eq('version'  => { 'ref' => 'abcdef', 'pr' => '1' },
                             'metadata' => [
                               { 'name' => 'url', 'value' => 'http://example.com'},
                               { 'name' => 'status', 'value' => 'success' }
        ])
      end
    end

    context 'and the build failed' do
      it 'sets into failure mode' do
        proxy.stub('https://api.github.com:443/repos/jtarchie/test/statuses/abcdef', method: :post)

        output = put(params: { status: 'failure' }, source: { repo: 'jtarchie/test' })
        expect(output).to eq('version'  => { 'ref' => 'abcdef', 'pr' => '1' },
                             'metadata' => [
                               { 'name' => 'url', 'value' => 'http://example.com'},
                               { 'name' => 'status', 'value' => 'failure' }
        ])
      end
    end
  end
end
