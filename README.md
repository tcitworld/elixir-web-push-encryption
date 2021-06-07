# WebPushEncryption

![CI workflow badge](https://github.com/github/docs/actions/workflows/ci.yml/badge.svg)

Elixir implementation of [Web Push Payload encryption](https://developers.google.com/web/updates/2016/03/web-push-encryption?hl=en).

## Installation

1. Add `web_push_encryption` and a json library for jose to your list of dependencies in `mix.exs`.

  ```elixir
  def deps do
    [
      {:poison, "~> 0.4"}, # see jose docs for more options here
      {:web_push_encryption, "~> 0.3"}
    ]
  end
  ```

2. Generate a web push Vapid keypair on the CLI and put it in your `config.exs` file:

```
 $ mix do deps.get, compile
 $ mix web_push.gen.keypair
```

## Usage

`WebPushEncryption` has two public API:

* `WebPushEncryption.encrypt/3`: Takes a body, a subscription, and an optional padding and returns a map containing `ciphertext`, `server_public_key` and `salt`.

* `WebPushEncryption.send_web_push/3`: Takes a body, a subcription, and a GCM secret key and sends a push notification with the given payload.

```elixir
body = ~s({"hello": "elixir"})
subscription = %{keys: %{p256dh: "P256DH", auth: "AUTH" }, endpoint: "ENDPOINT"}
gcm_api_key = "API_KEY"

# encrypt the body
encrypted_body = WebPushEncryption.encrypt(body, subscription)
# or just send the push
{:ok, response} = WebPushEncryption.send_web_push(body, subscription, gcm_api_key)
```

See [the docs](https://hexdocs.pm/web_push_encryption) for more info.

## Client Sample

You can find the strict minimum client code to try the library under [client-sample](./client-sample/).
You will need Chrome >= 50 or Firefox >= 44.

## Credits

The implementation is ported from [googlechrome/web-push-encryption](https://github.com/GoogleChrome/web-push-encryption)
