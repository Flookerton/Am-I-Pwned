---
name: breach-exposure-check
description: Check which of your own accounts sit on websites running PHP, and rank the risk, after PHP2Shell (CVE-2026-109618/109619) or any similar web-server vulnerability. Finds your accounts from your email, does one passive page visit per site, and tells you what to delete first. Use when someone asks "am I exposed to PHP2Shell?", "which of my accounts could be hacked?", or "which old sites should I delete?".
---

# Breach Exposure Check

Answers one question: *which sites holding my data run the technology that was just found vulnerable?* Then tells the user what to do about each one.

**Strictly passive.** One normal homepage visit per site, reading only public headers, cookie names and page markers, the same signals a browser extension like Wappalyzer reads. **Never** send exploit payloads, probe for the vulnerability, request admin or login paths, or scan ports. That would be testing other people's servers without authorization.

## Steps

1. **Check the news first.** Search for the CVE(s) and record:
   - which versions are vulnerable and which releases fix it
   - which old versions will **never** be fixed (end-of-life)
   - whether it's being exploited in the wild, and any interim mitigation

   Cite the sources to the user. If the user's description doesn't match what you find, say so.

2. **Build the domain list.** Follow `references/find-your-accounts.md` to pull every service that ever sent the user a sign-up or security email, or ask the user to list their services. Map email-sending domains to website domains (e.g. `brand-mail.com` → `brand.com`). Write one domain per line to `domains.txt`. This file is private; never commit or publish it.

3. **Run the checker:**
   ```bash
   bash scripts/php-exposure-check.sh domains.txt > results.tsv
   ```
   Output columns: `domain`, `http_status`, `verdict`, `php_version`, `evidence`. About 140 sites take around 2 minutes (8 in parallel; set `PARALLEL=` to change it). The script targets PHP. For another technology, copy it and swap the signal checks (see `references/signals.md`).

4. **Re-check unreachable sites** once. Exit code 6 (DNS failure) means the domain is gone. Some big retailers block curl, so mark those "blocks automated checks", not a risk.

5. **Sort into tiers** (`references/tiers.md`) and write a report for the user:
   - 🔴 **Act now:** a version that will never be fixed, or a supported version older than the fixed release.
   - 🟡 **Watch:** technology confirmed but version hidden, or a likely match on an account already marked for deletion.
   - 🟢 **Lower risk:** the technology only appears on the company's marketing site, while accounts usually live on a separate system.
   - ⚪ **Gone:** the domain is dead or unreachable. The company may be defunct, so there's no one to ask for deletion.

6. **Say what the check can't show:** "no signal" doesn't mean safe, because many sites hide headers, and only the homepage is checked.

7. **Recommend actions:**
   - Delete dormant accounts on 🔴/🟡 sites first. Send a CCPA deletion request where there's no delete button.
   - Change any password reused from those sites. Use unique passwords and a password manager.
   - Turn on breach alerts at haveibeenpwned.com.
   - Watch for phishing that names those sites over the next few weeks.
   - Rerun the check in a few days to see which sites have upgraded.

## Worked example (PHP2Shell, October 2026)
CVE-2026-109618 / CVE-2026-109619: unauthenticated remote code execution plus memory disclosure in PHP core, CVSS 9.2. Fixed in 8.5.12 / 8.4.27 / 8.3.36 / 8.2.35. Versions below 8.2 will never be fixed.

Run on 141 real accounts: 3 confirmed PHP (one on **7.4.33**, which will never be fixed → 🔴; one on **8.4.26**, one release behind the fix → 🔴), 9 using a PHP CMS (mostly WordPress marketing sites → 🟢/🟡), 2 dead domains → ⚪, 126 with no signal or a non-PHP platform.
