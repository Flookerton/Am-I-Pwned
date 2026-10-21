# Am I Pwned?

**PHP just broke. Your old accounts are the blast radius.**

PHP2Shell (CVE-2026-109618 / CVE-2026-109619) is two critical bugs that let attackers run code on a PHP server. PHP fixed them on October 21, 2026, in 8.2 and up. PHP 8.1 and older get no official release, only source patches and whatever your host's vendor backports.

**Sources:** [php.net advisory](https://www.php.net/archive/2026.php#2026-10-21-5) · [GHSA-w8hw-w9fx-j79w](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) (CVE-2026-109618) · [GHSA-6wmf-4rv5-p3rp](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) (CVE-2026-109619)

This agent skill finds which of *your* accounts sit on PHP sites, ranks the risk, and tells you what to delete first.

## What it does
1. Searches your inbox for sign-up and security emails, reading only the **sender, subject and date** in the results list
2. Makes one normal page visit per site and reads only public headers
3. Spots PHP versions, WordPress, Drupal, Laravel
4. Ranks each account: **act now**, **watch**, **low risk**, **gone**, **unknown**

**Expect mostly "no signal".** Most sites hide what they run. No signal isn't an all-clear.

## What it needs
Search access to your email: a Gmail connector, or your own signed-in browser via an extension such as Claude in Chrome.

## What it never does
- Open or read your emails
- Probe, scan or attack anyone's server: no exploit payloads, no admin paths
- Touch your passwords
- Delete anything for you
- Call a company "gone" unless the domain is confirmed unregistered

## How to read the results
- **Act now:** the site shows a PHP version with no official fix, or one older than the fix. A version number doesn't prove the server is unpatched, since distributions backport fixes without changing it. *Upstream won't patch it, and the host may not have either.*
- **Gone:** confirmed by DNS **and** a registry lookup. A site that just didn't answer is **Unknown**, never Gone.

## Install
**Claude Code**
```
/plugin marketplace add Flookerton/Am-I-Pwned
/plugin install am-i-pwned@am-i-pwned
```
**Any agent with Agent Skills:** copy `skills/breach-exposure-check/` into its skills folder.

**Just the scanner**
```bash
bash skills/breach-exposure-check/scripts/php-exposure-check.sh domains.txt > results.tsv
```
Needs bash and curl. Works on macOS, Linux, WSL and Git Bash on Windows. It checks your connection first and stops if a known-good site can't be reached, so a network problem can't make every site look dead.

## From one real inbox
144 accounts. 141 sites checked. 3 confirmed on PHP. 1 showing PHP 7.4 (no official fix). 1 a patch behind. 1 company confirmed gone, 1 unknown. The other 126: no signal or not PHP.

## Coming soon
**anonymize-me**: delete the accounts it finds, get off people-search sites, kill spam calls.

## License
MIT. Not affiliated with Have I Been Pwned (haveibeenpwned.com). Sign up for their breach alerts too.
