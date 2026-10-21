# Passive Technology Signals

Read these from one normal homepage response. To support a new technology, add its signals to a copy of the script.

## PHP
| Strength | Signal |
|---|---|
| Confirmed | `X-Powered-By: PHP/x.y.z` (often includes the exact version) |
| Confirmed | `Set-Cookie: PHPSESSID=` |
| Confirmed | `Set-Cookie: laravel_session=` (Laravel) |
| Confirmed | `X-Drupal-*` headers (Drupal) |
| Confirmed | `X-Magento-*` headers or `mage-*` cookies (Magento) |
| Likely | `/wp-content/` or `/wp-includes/` in the HTML, a WordPress generator meta tag, or a `Link: <…/wp-json/>` header |
| Likely | Drupal (`/sites/default/files/`) or Joomla generator markers |
| Likely | WooCommerce markers |
| Likely | `href="….php"` links |

## Platforms that don't run PHP
Shopify (`x-shopify-*`, `server: shopify`), Squarespace, Vercel (`x-vercel-*`), Netlify (`x-nf-request-id`), Wix (`x-wix-*`), Webflow.

## Other technologies (starting points)
| Technology | Signals |
|---|---|
| ASP.NET | `X-AspNet-Version`, `X-Powered-By: ASP.NET`, `ASP.NET_SessionId` cookie |
| Java / Tomcat | `JSESSIONID` cookie, `Server: Apache-Coyote` |
| Express / Node | `X-Powered-By: Express` |
| Ruby on Rails | `_session_id` / `_<app>_session` cookies, `X-Runtime` |
| nginx / Apache versions | `Server:` header (often hidden) |

## Script implementation notes
- Lowercase headers and HTML before matching, and match evidence strings case-insensitively.
- Remove null bytes from the HTML before grepping (`tr -d '\000'`).
- Follow up to 5 redirects. Time out after 20 seconds. Use a normal browser user-agent.
