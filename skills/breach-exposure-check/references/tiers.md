# Risk Tiers

| Tier | When | Recommended action |
|---|---|---|
| 🔴 **Act now** | The version shown is on a branch that gets **no official fix** (upstream won't patch it, and the host may not have either); **or** a supported version still behind the fix **more than a week** after the release | Delete the account or send a deletion request. Remove saved cards. Change reused passwords. |
| 🟡 **Watch: behind the fix** | A supported version older than the fixed release, within the first week. *A fix exists, and this site hasn't shown it yet.* Hosts often update within days. | Recheck after a week. Move to 🔴 if it's still behind. Unique password + 2FA meanwhile. |
| 🟡 **Watch** | Technology confirmed (cookie or header) but the version is hidden; **or** a likely match (CMS markers) on an account already marked for deletion | Unique password + 2FA. Move deletion up the list. |
| 🟢 **Lower risk** | Technology appears only on the public marketing site (WordPress/Drupal homepage), and the account system is likely separate (e.g. a `login.` or `app.` subdomain) | No urgent action. Normal hygiene. |
| ⚪ **Gone** | **Confirmed** dead: the name doesn't resolve on two independent resolvers **and** the registry (RDAP/WHOIS) shows the domain unregistered or expired | No one left to ask for deletion. Change that password anywhere it was reused. |
| ❔ **Unknown** | `unreachable`, `dns-missing` with the domain still registered, or a site that blocks automated requests | Not a risk signal, and not proof the company is gone. Retry later, or open it in a browser. |
| — **No signal** | Nothing detected | **Not proof of safety.** Headers are often hidden. Expect most results to land here. |

## Why a version string isn't proof
A header like `X-Powered-By: PHP/7.4.33` shows which branch the server runs, not whether it's patched. Linux distributions and LTS vendors (RHEL, Ubuntu ESM, Debian and others) backport security fixes and keep reporting the old version number. The upstream PHP project also published source-only patches for some end-of-life branches. An end-of-life version still belongs in **Act now**: nobody upstream is shipping a release for it, and you can't tell from outside whether the host applied a backport. Say it that way to the user: *upstream won't patch it, and the host may not have either.*

## Confirming "Gone"
1. The script reports `dns-missing` when the name doesn't resolve. That's a **candidate**, not a verdict.
2. Resolve the name again on two public resolvers (e.g. `1.1.1.1` and `8.8.8.8`). A local DNS or network hiccup can look exactly like a dead domain.
3. Look the domain up in its registry: RDAP (e.g. `https://rdap.verisign.com/com/v1/domain/<name>` for .com/.net) or WHOIS.
   - **Not registered or expired** → ⚪ Gone.
   - **Still registered, but no website address** (common when a company shuts down a product but keeps the name) → ❔ Unknown.
4. `unreachable` (resolves but doesn't answer) is always ❔ Unknown. Never call it Gone.

Treat **Important** accounts (finance, health, identity) one tier higher than their score suggests when deciding what to tell the user first.
