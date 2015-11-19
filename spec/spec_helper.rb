require 'billy'

Billy.configure do |c|
  c.non_successful_error_level = :error
  c.non_whitelisted_requests_disabled = true
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def check(payload)
  path = ['./assets/check', '/opt/resource/check'].find { |p| File.exist? p }

  output = `echo '#{JSON.generate(payload)}' | env http_proxy=#{proxy.url} #{path}`
  JSON.parse(output)
end

def get(payload = {})
  path = ['./assets/in', '/opt/resource/in'].find { |p| File.exist? p }

  output = `echo '#{JSON.generate(payload)}' | env http_proxy=#{proxy.url} #{path} #{dest_dir}`
  JSON.parse(output)
end

def put(payload = {})
  path = ['./assets/out', '/opt/resource/out'].find { |p| File.exist? p }
  payload[:source] = { repo: 'jtarchie/test' }

  output = `echo '#{JSON.generate(payload)}' | env http_proxy=#{proxy.url} #{path} #{dest_dir}`
  JSON.parse(output)
end


