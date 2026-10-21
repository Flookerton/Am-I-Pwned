# Am I Pwned?

**PHP just broke. Your old accounts are the blast radius.**

PHP2Shell (CVE-2026-109618 / CVE-2026-109619) lets attackers run code on a PHP server and read its memory. The fix shipped October 21, 2026, but only for PHP 8.2 and up. Everything older stays broken for good.

This agent skill finds which of *your* accounts sit on PHP sites, ranks the risk, and tells you what to delete first.

## What it does
1. Pulls every service out of your inbox (sign-up and security emails)
2. Makes one normal page visit per site and reads only public headers
3. Spots PHP versions, WordPress, Drupal, Laravel
4. Ranks each account: **act now**, **watch**, **low risk**, **gone**

## What it never does
- Probe, scan or attack anyone's server: no exploit payloads, no admin paths
- Read your email bodies
- Touch your passwords
- Delete anything for you

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
Needs bash and curl. Runs as-is on macOS, Linux and WSL.

> **Windows (Git Bash):** if every site comes back `000 unreachable`, your `curl` is the native Windows build, which can't see Git Bash's `/tmp`. Point the temp folder somewhere Windows can read and rerun:
> ```bash
> TMPDIR="$(cygpath -m "$USERPROFILE")/AppData/Local/Temp" bash skills/breach-exposure-check/scripts/php-exposure-check.sh domains.txt > results.tsv
> ```

## From one real inbox
144 accounts. 141 sites checked. 3 confirmed on PHP. 1 on PHP 7.4, which will never get the fix. 1 one patch behind. 2 companies already gone.

## Coming soon
**anonymize-me**: delete the accounts it finds, get off people-search sites, kill spam calls.

## License
MIT. Not affiliated with Have I Been Pwned (haveibeenpwned.com). Sign up for their breach alerts too.
