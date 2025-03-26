#!/bin/zsh

CHANNEL="crypto-alerts"
NTFY_URL="https://ntfy.sh/$CHANNEL"
API_URL="https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=3&page=1&sparkline=false&price_change_percentage=24h"

# Pobierz dane z CoinGecko
response=$(curl -s "$API_URL")

# Sprawdź, czy odpowiedź nie jest pusta
if [ -z "$response" ]; then
  echo "Brak odpowiedzi z API"
  exit 1
fi

# Parsuj dane (z pomocą jq)
notification="💰 Top 3 kryptowaluty:\n"

for i in 0 1 2; do
  name=$(echo "$response" | jq -r ".[$i].name")
  symbol=$(echo "$response" | jq -r ".[$i].symbol" | tr '[:lower:]' '[:upper:]')
  price=$(echo "$response" | jq -r ".[$i].current_price")
  change=$(echo "$response" | jq -r ".[$i].price_change_percentage_24h")

  notification+="• $name ($symbol): \$$(printf "%.2f" "$price"), 24h: $(printf "%.2f" "$change")%\n"
done

# Wyślij powiadomienie push
curl -s -X POST "$NTFY_URL" -d "$notification"
