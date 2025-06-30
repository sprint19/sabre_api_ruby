# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SabreApiRuby::Configuration do
  let(:configuration) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(configuration.client_id).to be_nil
      expect(configuration.client_secret).to be_nil
      expect(configuration.environment).to eq(:development)
      expect(configuration.timeout).to eq(30)
      expect(configuration.open_timeout).to eq(10)
      expect(configuration.user_agent).to include('SabreApiRuby')
    end
  end

  describe '#environment=' do
    it 'accepts valid environment symbols' do
      configuration.environment = :production
      expect(configuration.environment).to eq(:production)

      configuration.environment = :test
      expect(configuration.environment).to eq(:test)

      configuration.environment = :development
      expect(configuration.environment).to eq(:development)
    end

    it 'accepts valid environment strings' do
      configuration.environment = 'production'
      expect(configuration.environment).to eq(:production)

      configuration.environment = 'test'
      expect(configuration.environment).to eq(:test)

      configuration.environment = 'development'
      expect(configuration.environment).to eq(:development)
    end

    it 'raises error for invalid environment' do
      expect { configuration.environment = :invalid }.to raise_error(
        ArgumentError,
        'Environment must be one of: development, test, production'
      )
    end
  end

  describe '#api_base_url' do
    it 'returns correct URL for development environment' do
      configuration.environment = :development
      expect(configuration.api_base_url).to eq('https://api.test.sabre.com/v4')
    end

    it 'returns correct URL for test environment' do
      configuration.environment = :test
      expect(configuration.api_base_url).to eq('https://api.test.sabre.com/v4')
    end

    it 'returns correct URL for production environment' do
      configuration.environment = :production
      expect(configuration.api_base_url).to eq('https://api.sabre.com/v4')
    end
  end

  describe '#oauth_token_url' do
    it 'returns correct URL for development environment' do
      configuration.environment = :development
      expect(configuration.oauth_token_url).to eq('https://api.test.sabre.com/v2/auth/token')
    end

    it 'returns correct URL for test environment' do
      configuration.environment = :test
      expect(configuration.oauth_token_url).to eq('https://api.test.sabre.com/v2/auth/token')
    end

    it 'returns correct URL for production environment' do
      configuration.environment = :production
      expect(configuration.oauth_token_url).to eq('https://api.sabre.com/v2/auth/token')
    end
  end

  describe '#validate!' do
    context 'with valid configuration' do
      it 'does not raise error' do
        configuration.client_id = 'test_client_id'
        configuration.client_secret = 'test_client_secret'

        expect { configuration.validate! }.not_to raise_error
      end
    end

    context 'with missing client_id' do
      it 'raises ConfigurationError' do
        configuration.client_secret = 'test_client_secret'

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client ID is required'
        )
      end
    end

    context 'with missing client_secret' do
      it 'raises ConfigurationError' do
        configuration.client_id = 'test_client_id'

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client Secret is required'
        )
      end
    end

    context 'with empty client_id' do
      it 'raises ConfigurationError' do
        configuration.client_id = ''
        configuration.client_secret = 'test_client_secret'

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client ID is required'
        )
      end
    end

    context 'with empty client_secret' do
      it 'raises ConfigurationError' do
        configuration.client_id = 'test_client_id'
        configuration.client_secret = ''

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client Secret is required'
        )
      end
    end

    context 'with blank client_id' do
      it 'raises ConfigurationError' do
        configuration.client_id = '   '
        configuration.client_secret = 'test_client_secret'

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client ID is required'
        )
      end
    end

    context 'with blank client_secret' do
      it 'raises ConfigurationError' do
        configuration.client_id = 'test_client_id'
        configuration.client_secret = '   '

        expect { configuration.validate! }.to raise_error(
          SabreApiRuby::ConfigurationError,
          'Client Secret is required'
        )
      end
    end
  end

  describe '#timeout=' do
    it 'accepts positive integers' do
      configuration.timeout = 60
      expect(configuration.timeout).to eq(60)
    end

    it 'raises error for negative values' do
      expect { configuration.timeout = -1 }.to raise_error(
        ArgumentError,
        'Timeout must be a positive integer'
      )
    end

    it 'raises error for zero' do
      expect { configuration.timeout = 0 }.to raise_error(
        ArgumentError,
        'Timeout must be a positive integer'
      )
    end

    it 'raises error for non-integers' do
      expect { configuration.timeout = '30' }.to raise_error(
        ArgumentError,
        'Timeout must be a positive integer'
      )
    end
  end

  describe '#open_timeout=' do
    it 'accepts positive integers' do
      configuration.open_timeout = 20
      expect(configuration.open_timeout).to eq(20)
    end

    it 'raises error for negative values' do
      expect { configuration.open_timeout = -1 }.to raise_error(
        ArgumentError,
        'Open timeout must be a positive integer'
      )
    end

    it 'raises error for zero' do
      expect { configuration.open_timeout = 0 }.to raise_error(
        ArgumentError,
        'Open timeout must be a positive integer'
      )
    end

    it 'raises error for non-integers' do
      expect { configuration.open_timeout = '10' }.to raise_error(
        ArgumentError,
        'Open timeout must be a positive integer'
      )
    end
  end
end
