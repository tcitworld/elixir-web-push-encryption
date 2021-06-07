defmodule WebPushEncryption.Vapid do
  # aes128gcm not yet supported in push.ex
  @supported_encodings ~w(aesgcm)

  def get_headers(audience, content_encoding, expiration \\ 12 * 3600, vapid \\ nil)
      when content_encoding in @supported_encodings do
    expiration_timestamp = DateTime.to_unix(DateTime.utc_now()) + expiration

    vapid = vapid || Application.fetch_env!(:web_push_encryption, :vapid_details)

    public_key = Base.url_decode64!(vapid[:public_key], padding: false)
    private_key = Base.url_decode64!(vapid[:private_key], padding: false)

    payload =
      %{
        aud: audience,
        exp: expiration_timestamp,
        sub: vapid[:subject]
      }
      |> JOSE.JWT.from_map()

    otp_version =
      :erlang.system_info(:otp_release) |> String.Chars.to_string() |> String.to_integer()

    jwk =
      if otp_version < 24 do
        {:ECPrivateKey, 1, private_key, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, public_key}
      else
        {:ECPrivateKey, 1, private_key, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, public_key,
         nil}
      end
      |> JOSE.JWK.from_key()

    {_, jwt} = JOSE.JWS.compact(JOSE.JWT.sign(jwk, %{"alg" => "ES256"}, payload))
    headers(content_encoding, jwt, vapid[:public_key])
  end

  defp headers("aesgcm", jwt, pub) do
    %{"Authorization" => "WebPush " <> jwt, "Crypto-Key" => "p256ecdsa=" <> pub}
  end

  defp headers("aes128gcm", jwt, pub) do
    %{"Authorization" => "vapid t=#{jwt}, p=#{pub}"}
  end
end
