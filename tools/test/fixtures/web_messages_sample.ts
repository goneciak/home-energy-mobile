// A small sample in the shape of apps/gi-ui/src/shared/i18n/messages.ts.
export type Locale = "pl-PL" | "en-US";
export type MessageKey = keyof (typeof messages)["en-US"];

export const messages = {
  "en-US": {
    "auth.signIn": "Sign in",
    "auth.password": 'Password',
    /* a block comment */
    "nav.devices": "Devices", // a line comment
    "dashboard.deviceDiscoveredDescription": "GI Home found \"{name}\" nearby.",
    "dashboard.deviceDiscoveredDescriptionMultiple":
      "GI Home found \"{name}\" and {count} more nearby.",
    "device.long":
      "First part, " +
      "second part.",
    "device.template": `Line one`,
    "device.computed": `Hello ${name}`,
    "device.call": "x".toUpperCase(),
    "only.en": "Only in English",
    unquoted: "Bare key",
  },
  "pl-PL": {
    "auth.signIn": "Zaloguj się",
    "auth.password": "Hasło",
    "nav.devices": "Urządzenia",
    "dashboard.deviceDiscoveredDescription": "GI Home znalazł „{name}” w pobliżu.",
    "dashboard.deviceDiscoveredDescriptionMultiple":
      "GI Home znalazł „{name}” i {count} innych w pobliżu.",
    "device.long": "Pierwsza część, " + "druga część.",
    "device.template": `Linia pierwsza`,
    "device.computed": `Cześć ${name}`,
    "device.call": "x".toUpperCase(),
    unquoted: "Klucz bez cudzysłowu ą",
  },
} as const;
