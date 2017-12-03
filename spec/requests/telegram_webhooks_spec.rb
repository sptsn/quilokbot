# spec/requests/telegram_webhooks_spec.rb
require 'telegram/bot/rspec/integration'

RSpec.describe TelegramController, :telegram_bot do
  # for old rspec add:
  # include_context 'telegram/bot/integration'

  describe '#start' do
    subject { -> { dispatch_command :start } }
    it { should respond_with_message 'Hi there!' }
  end

  # There is context for callback queries with related matchers.
  describe '#hey_callback_query', :callback_query do
    let(:data) { "hey:#{name}" }
    let(:name) { 'Joe' }
    it { should answer_callback_query('Hey Joe') }
    it { should edit_current_message :text, text: 'Done' }
  end
end

# For controller specs use
# require 'telegram/bot/updates_controller/rspec_helpers'
# RSpec.describe TelegramWebhooksController, type: :telegram_bot_controller do
#   # for old rspec add:
#   # include_context 'telegram/bot/updates_controller'
# end
#
# # Matchers are available for custom specs:
# include Telegram::Bot::RSpec::ClientMatchers
#
# expect(&process_update).to send_telegram_message(bot, /msg regexp/, some: :option)
# expect(&process_update).
#   to make_telegram_request(bot, :sendMessage, hash_including(text: 'msg text'))s
