require './matcher'
require 'spec_helper'

RSpec.describe Matcher do
  before do
    stub_const('Matcher::API_HOST', 'http://match.test')
    stub_const('Matcher::DEFAULT_CONFIG_PATH', File.join(File.dirname(__FILE__), 'fixtures/config.yml'))
  end

  describe '.new' do
    it "configures from specified file" do
      path = File.join(File.dirname(__FILE__), 'fixtures/config.yml')
      m = Matcher.new(path)

      expect(m.config).to eq({
        'facebook_token' => 'fb_test_token',
        'facebook_id' => 'fb_test_id',
        'client_version' => 'test_version'
      })
    end
  end

  describe '#authenticate' do
    let(:m) { Matcher.new }
    let(:res) do
      JSON.dump({
        'meta' => {
          'status' => 200
        },
        'data' => {
          'is_new_user' => false,
          'api_token' => 'api-test-token'
        }
      })
    end

    it 'sets headers properly' do
      stub_request(
        :post,
        'http://match.test/v2/auth/login/facebook'
      ).with do |req|
        expect(req.headers['App-Version']).to eq('2061')
        expect(req.headers['X-Client-Version']).to eq('80025')
        expect(req.headers['X-Experiment-Id']).to eq('bfced51')
        expect(req.headers['Platform']).to eq('ios')
        expect(req.headers['Install-Id']).to eq('A927C19E-F74C-4FF6-8AAF-A4963DE6A32B')
        expect(req.headers['User-Agent']).to eq('Tinder/8.0.0 (iPhone; iOS 10.3.3; Scale/2.00)')
        expect(req.headers['App-Session']).to eq('a2fc7739760f2a86da9f1c8b98690920727029b4')
      end.to_return(body: res)

      m.authenticate

      expect(WebMock).to have_requested(:post, 'http://match.test/v2/auth/login/facebook')
    end

    it 'sets body properly' do
      stub_request(
        :post,
        'http://match.test/v2/auth/login/facebook'
      ).with do |req|
        options = JSON.parse(req.body)
        expect(options['token']).to eq('fb_test_token')
        expect(options['id']).to eq('fb_test_id')
        expect(options['client_version']).to eq('test_version')
      end.to_return(body: res)

      m.authenticate
    end

    it 'sets token from response' do
      stub_request(
        :post,
        'http://match.test/v2/auth/login/facebook'
      ).to_return(body: res)

      m.authenticate

      expect(m.token).to eq('api-test-token')
    end
  end

  describe '#fetch' do
    let(:m) { Matcher.new }

    before do
      stub_request(
        :post,
        'http://match.test/v2/auth/login/facebook'
      ).to_return(
        body: JSON.dump({
          'meta' => {
            'status' => 200
          },
          'data' => {
            'is_new_user' => false,
            'api_token' => 'api-test-token'
          }
        })
      )
      m.authenticate
    end

    it 'fetches with proper headers' do
      stub_request(
        :get,
        'http://match.test/v2/recs/core?fast_match=1&locale=en-SG'
      ).with do |req|
        expect(req.headers['App-Version']).to eq('2061')
        expect(req.headers['X-Client-Version']).to eq('80025')
        expect(req.headers['X-Experiment-Id']).to eq('bfced51')
        expect(req.headers['Platform']).to eq('ios')
        expect(req.headers['Install-Id']).to eq('A927C19E-F74C-4FF6-8AAF-A4963DE6A32B')
        expect(req.headers['User-Agent']).to eq('Tinder/8.0.0 (iPhone; iOS 10.3.3; Scale/2.00)')
        expect(req.headers['X-Auth-Token']).to eq('api-test-token')
        expect(req.headers['Authorization']).to eq('Token token="api-test-token"')
      end.to_return(body: JSON.dump({
        'data' => {
          'results' => {
            'ok' => true
          }
        }
      }))

      res = m.fetch

      expect(WebMock).to have_requested(:get, 'http://match.test/v2/recs/core?fast_match=1&locale=en-SG')
      expect(res).to eq({'ok' => true})
    end
  end

  describe '#like' do
    let(:m) { Matcher.new }

    before do
      stub_request(
        :post,
        'http://match.test/v2/auth/login/facebook'
      ).to_return(
        body: JSON.dump({
          'meta' => {
            'status' => 200
          },
          'data' => {
            'is_new_user' => false,
            'api_token' => 'api-test-token'
          }
        })
      )
      m.authenticate
    end

    it 'likes with proper headers' do
      stub_request(
        :get,
        'http://match.test/like/12345?content_hash=test-hash'
      ).with do |req|
        expect(req.headers['App-Version']).to eq('2061')
        expect(req.headers['X-Client-Version']).to eq('80025')
        expect(req.headers['X-Experiment-Id']).to eq('bfced51')
        expect(req.headers['Platform']).to eq('ios')
        expect(req.headers['Install-Id']).to eq('A927C19E-F74C-4FF6-8AAF-A4963DE6A32B')
        expect(req.headers['User-Agent']).to eq('Tinder/8.0.0 (iPhone; iOS 10.3.3; Scale/2.00)')
        expect(req.headers['X-Auth-Token']).to eq('api-test-token')
        expect(req.headers['Authorization']).to eq('Token token="api-test-token"')
      end

      m.like(12345, 'test-hash', false)
      expect(WebMock).to have_requested(:get, 'http://match.test/like/12345?content_hash=test-hash')
    end

    it 'adds user_traveling=1 when user_traveling is true' do
      stub_request(
        :get,
        'http://match.test/like/12345?content_hash=test-hash&user_traveling=1'
      )

      m.like(12345, 'test-hash', true)
      expect(WebMock).to have_requested(:get, 'http://match.test/like/12345?content_hash=test-hash&user_traveling=1')
    end
  end
end
