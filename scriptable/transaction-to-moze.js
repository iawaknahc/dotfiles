const KEY_CARD_OR_PASS = "Card or Pass";

const fixture_PnS = {
  Name: "Park'n Shop Lt/455 Ss",
  [KEY_CARD_OR_PASS]: "HSBC Red Credit Card滙豐Red信用卡",
  Merchant: "Park'n Shop Lt/455 Ss",
  Amount: "HK$34.90",
};

const CARD_TO_ACCOUNT = {
  "HSBC Red Credit Card滙豐Red信用卡": "Red",
  "EarnMORE UPI": "EarnMORE",
  "BEA GOAL Credit Card": "GOAL",
};

function main(shortcutParameter) {
  // Validate amount.
  const amountRegex = /^HK\$/;
  let amount = shortcutParameter.Amount;
  if (!amountRegex.test(amount)) {
    return;
  }
  // Remove non-digit and separators.
  amount = amount.replace(/[^0-9.]/g, "");

  // Validate card.
  const cardOrPass = shortcutParameter[KEY_CARD_OR_PASS];
  if (cardOrPass == null || cardOrPass === "") {
    return;
  }

  // Validate account.
  const account = CARD_TO_ACCOUNT[cardOrPass];
  if (account == null) {
    return;
  }

  const url = `moze3://new?amount=${encodeURIComponent(
    amount,
  )}&account=${encodeURIComponent(account)}`;

  return url;
}

function isPreview(shortcutParameter) {
  if (shortcutParameter == null) {
    return true;
  }
  return (
    !shortcutParameter.Name &&
    !shortcutParameter.Amount &&
    !shortcutParameter[KEY_CARD_OR_PASS] &&
    !shortcutParameter.Merchant
  );
}

const input = isPreview(args.shortcutParameter)
  ? fixture_PnS
  : args.shortcutParameter;
const output = main(input);
if (output != null) {
  return output;
} else {
  Script.complete();
}
