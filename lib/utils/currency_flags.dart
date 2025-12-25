String getFlag(String currencyCode) {
  const map = {
    'USD': 'US',
    'EUR': 'EU',
    'GBP': 'GB',
    'JPY': 'JP',
    'INR': 'IN',
    'CAD': 'CA',
    'AUD': 'AU',
    'CNY': 'CN',
    'TRY': 'TR',
    'RUB': 'RU',
    'AED': 'AE',
  };

  final countryCode = map[currencyCode] ?? 'UN';

  return countryCode
      .toUpperCase()
      .runes
      .map((c) => String.fromCharCode(127397 + c))
      .join();
}
