---
name: breach-exposure-check
description: Check which of your own accounts sit on websites running PHP, and rank the risk, after PHP2Shell (CVE-2026-109618/109619) or any similar web-server vulnerability. Finds your accounts from your email, does one passive page visit per site, and tells you what to delete first. Use when someone asks "am I exposed to PHP2Shell?", "which of my accounts could be hacked?", or "which old sites should I delete?".
---

# Breach Exposure Check

Answers one question: *which sites holding my data run the technology that was just found vulnerable?* Then tells the user what to do about each one.

**Strictly passive.** One normal homepage visit per site, reading only public headers, cookie names and page markers, the same signals a browser extension like Wappalyzer reads. **Never** send exploit payloads, probe for the vulnerability, request admin or login paths, or scan ports. That would be testing other people's servers without authorization.

## Before you start, tell the user
- **What inbox access you need:** search access to their email (a Gmail connector, or their own signed-in browser). You read only the **sender, subject line and date** shown in search results. You never open a message or read its body.
- **What to expect:** most sites will come back **"no signal"**. That's normal, because many sites hide these headers, and it is **not an all-clear**.

## Steps

1. **Check the primary sources first.** Start with the vendor's own advisory (for PHP: the php.net security announcement and the GitHub advisories in `php/php-src`), then NVD. Use news coverage only to fill gaps. Record:
   - which versions are vulnerable and which releases fix it
   - which branches get **no official release**, and whether source patches or distribution backports exist for them
   - what the vendor says about exploitation (a demonstrated exploit isn't the same as attacks in the wild), and any interim mitigation

   Give the user the primary-source links. If the user's description doesn't match what you find, say so.

2. **Build the domain list.** Follow `references/find-your-accounts.md` to pull every service that ever sent the user a sign-up or security email, or ask the user to list their services. Map email-sending domains to website domains (e.g. `brand-mail.com` → `brand.com`). Write one domain per line to `domains.txt`. This file is private; never commit or publish it.

3. **Run the checker:**
   ```bash
   bash scripts/php-exposure-check.sh domains.txt > results.tsv
   ```
   Output columns: `domain`, `http_status`, `verdict`, `php_version`, `evidence`. About 140 sites take around 2 minutes (8 in parallel; set `PARALLEL=` to change it). The script first checks that it can reach a known-good site, and stops if it can't, so a broken connection can't mark every site as dead. It targets PHP. For another technology, copy it and swap the signal checks (see `references/signals.md`).

4. **Sort out the sites that didn't answer.** Never call a site "gone" from the scan alone.
   - `dns-missing`: confirm with two public resolvers and a registry (RDAP/WHOIS) lookup. Only an unregistered or expired domain is ⚪ **Gone**. A registered domain with no website is ❔ **Unknown**.
   - `unreachable`: retry once, then ❔ **Unknown**. Big retailers often block automated requests.

   See `references/tiers.md` → *Confirming "Gone"*.

5. **Sort into tiers** (`references/tiers.md`) and write a report for the user:
   - 🔴 **Act now:** a version whose branch gets no official fix (upstream won't patch it, and the host may not have either), or a supported version older than the fixed release.
   - 🟡 **Watch:** technology confirmed but version hidden, or a likely match on an account already marked for deletion.
   - 🟢 **Lower risk:** the technology only appears on the company's marketing site, while accounts usually live on a separate system.
   - ⚪ **Gone:** the domain is confirmed unregistered. There's no one to ask for deletion.
   - ❔ **Unknown:** couldn't be checked. Not a risk signal and not a verdict.

6. **Say what the check can't show:**
   - "No signal" doesn't mean safe, because many sites hide headers.
   - A version string doesn't prove a server is unpatched, because distributions backport fixes without changing the number.
   - Only the homepage is checked.

7. **Recommend actions:**
   - Delete dormant accounts on 🔴/🟡 sites first. Send a CCPA deletion request where there's no delete button.
   - Change any password reused from those sites. Use unique passwords and a password manager.
   - Turn on breach alerts at haveibeenpwned.com.
   - Watch for phishing that names those sites over the next few weeks.
   - Rerun the check in a few days to see which sites have upgraded.

## Worked example (PHP2Shell, October 2026)
Primary sources: [php.net security advisory](https://www.php.net/archive/2026.php#2026-10-21-5), [GHSA-w8hw-w9fx-j79w](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) (CVE-2026-109618), [GHSA-6wmf-4rv5-p3rp](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) (CVE-2026-109619).

Two remote code execution flaws in PHP core, CVSS 9.2. Fixed in 8.5.12 / 8.4.27 / 8.3.36 / 8.2.35. PHP 8.1 and older get no official release. The PHP team published source-only patches for 7.4–8.1, and distributions and LTS vendors received the fix in advance. PHP reports a demonstrated unauthenticated exploit against mod_php.

Run on 141 real accounts:
- 3 confirmed PHP: one showing **7.4.33** (no official fix, so 🔴), one on **8.4.26** (one release behind the fix, so 🔴).
- 9 using a PHP CMS, mostly WordPress marketing sites (🟢/🟡).
- 1 domain confirmed unregistered (⚪); 1 registered with no website (❔).
- 126 with no signal or a non-PHP platform. That's the majority, as expected.
