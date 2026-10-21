# Find Your Accounts

The domain list for the exposure check comes from the user's own inbox: every service that ever sent them a sign-up or security email.

**Tell the user up front:** you need search access to their email. You see only the sender, subject line and date that appear in search results, and you never open a message.

## Tool access (preflight)
Try these in order:
1. **Gmail connector**, using `search_threads` with a metadata or minimal view. If calls fail with "connection invalidated", the user reconnects it in their connector settings. A session that's already running may not pick up the reconnect, so start a new session.
2. **The user's own signed-in browser** through a browser extension (for example Claude in Chrome). This is the most reliable route.
3. **A built-in browser** where the user signs in to Gmail themselves. Some providers block sign-ins from embedded browsers.

Never take the user's password to sign in for them.

## Search queries
Sign-ups:
```
subject:(welcome OR "verify your email" OR "confirm your email" OR "confirm your account" OR "activate your account" OR "thanks for signing up" OR "account created")
```
Security emails (these reveal accounts the sign-up search misses):
```
subject:("password reset" OR "reset your password" OR "new sign-in" OR "new login" OR "verification code" OR "security alert")
```

## Extracting results in the browser (Gmail web)
1. Open `https://mail.google.com/mail/u/0/#search/<url-encoded query>`.
2. Run one async JavaScript loop that pages by setting `location.hash = '#search/<q>/pN'`, waiting about 2.5 seconds per page. Stop when a page is empty or shows the same row IDs as the last page.
3. For each visible `tr.zA` row, read the sender: the `span[email]` element's `email` attribute (the display `name` is optional). Read the last-seen date from the `title` attribute of `td.xW span`. Those two values are all this skill needs from a row.
4. Group by root domain, keeping the website domain and the last date. That grouping is the domain list.
5. Store the result in a page variable (`window.__inv`). Tool output gets cut off around 1–2 KB, so read it back about 25 rows at a time.
6. If a loop will run longer than about 40 seconds, start it without waiting for it, then check `window.__done` with short calls.

Gmail's class names (`zA`, `zE`, `xW`) change occasionally. If nothing matches, inspect a row and update the selectors.

Typical result: 100–150 services from about 5 minutes of paging.

## Privacy rules
- Read only the sender, subject and date from the results list. Don't open messages. Skip personal mail.
- Keep the list out of long-term memory and out of anything published or committed. `domains.txt` is private.
- Never take the user's password, and never read an email body unless the user asks for it.

## Caveat
The last sign-up or security email isn't the last login. A service can look dormant in the inbox and still be active.
