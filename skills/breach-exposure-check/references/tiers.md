# Risk Tiers

| Tier | When | Recommended action |
|---|---|---|
| 🔴 **Act now** | The version shown is end-of-life (will never be fixed), **or** a supported version older than the fixed release | Delete the account or send a deletion request. Remove saved cards. Change reused passwords. Rerun in a few days to see if a supported version gets upgraded. |
| 🟡 **Watch** | Technology confirmed (cookie or header) but the version is hidden; **or** a likely match (CMS markers) on an account already marked for deletion | Unique password + 2FA. Move deletion up the list. |
| 🟢 **Lower risk** | Technology appears only on the public marketing site (WordPress/Drupal homepage), and the account system is likely separate (e.g. a `login.` or `app.` subdomain) | No urgent action. Normal hygiene. |
| ⚪ **Gone** | DNS doesn't resolve, or the site doesn't respond | No one left to ask for deletion. Change that password anywhere it was reused. |
| — **Blocked** | The site blocks automated requests (common for big retailers) | Not a risk signal. Big companies patch quickly. |
| — **No signal** | Nothing detected | **Not proof of safety.** Headers are often hidden. |

Treat **Important** accounts (finance, health, identity) one tier higher than their score suggests when deciding what to tell the user first.
