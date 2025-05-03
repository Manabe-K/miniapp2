require "net/http"
require "uri"
require "json"

class TextConverter
  def self.convert(input_text)
    uri = URI("https://api-inference.huggingface.co/models/rinna/japanese-gpt-1b")

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV["HUGGINGFACE_API_KEY"]}"
    request["Content-Type"] = "application/json"
    request.body = { inputs: prompt_for(input_text) }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code.to_i != 200
      Rails.logger.warn("❗ HuggingFace APIエラー #{response.code}: #{response.body}")
      return "【変換失敗：#{response.code}】"
    end

    parsed = JSON.parse(response.body)
    if parsed.is_a?(Array) && parsed[0]["generated_text"]
      parsed[0]["generated_text"]
    else
      "【変換失敗】"
    end

  rescue JSON::ParserError => e
    Rails.logger.error("⚠️ JSONパースエラー: #{e.message}")
    "【変換失敗：レスポンス不正】"
  rescue StandardError => e
    Rails.logger.error("⚠️ API通信エラー: #{e.message}")
    "【変換失敗：通信エラー】"
  end

  def self.prompt_for(input_text)
    <<~PROMPT
      以下の日本語を鹿児島の西諸弁に変換し、さらにフランス語っぽく聞こえるカタカナに変換してください。
      フランス語風の響きを意識してカタカナをアレンジしてください。

      例：「今日はいい天気ですね」→「キョワ ヨカテンキ ジャドゥ」

      本文：
      #{input_text}
    PROMPT
  end
end