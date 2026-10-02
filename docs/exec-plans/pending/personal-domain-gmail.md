# Personal domain, GitHub Pages, and existing Gmail

Status: Implementation in progress; website HTTPS and remaining validation pending.
Created: 2026-09-26.
Repository: /home/jd/workspace/jdatta.github.io
Owner: Joydip Datta (GitHub: JDatta).

## Authority and intended outcome

This document is the authoritative execution handoff for this task. Follow its decisions rather than reopening the domain/provider design discussion. Revalidate time-sensitive prices, availability, and provider instructions at execution time. Record implementation results and any necessary deviations here.

The user requested a good personal domain, an inexpensive reliable registrar, continued hosting through jdatta.github.io, and jdatta@<domain> in their existing Gmail. The user explicitly selected sending AND receiving through the existing Gmail inbox using an external SMTP service. This handoff authorizes planning and preparation; it does not record a completed purchase or completed configuration. Before committing a purchase, present the exact available domain, registration term, checkout total, and renewal price for purchase approval unless the execution session already provides that authorization.

Success means https://jdatta.me serves the existing site with HTTPS, existing paths remain functional, and the user can receive and reply as jdatta@jdatta.me from their existing Gmail.

## Fixed decisions and budget

- Primary domain: jdatta.me. It is short and suited to a personal website and email identity.
- Registrar and authoritative DNS: Porkbun, retaining its default nameservers.
- Website host: existing GitHub Pages repository JDatta/jdatta.github.io. Preserve the existing publishing source and workflow.
- Canonical website hostname: jdatta.me; www.jdatta.me redirects to the apex.
- Incoming email: Porkbun free forwarding to the user's existing Gmail.
- Outgoing email: SMTP2GO free plan through Gmail's Send mail as feature.
- Do not create a separate Google Workspace mailbox, purchase website hosting, or introduce Cloudflare as another managed account.
- Initial registration term: one year. Enable auto-renewal, domain lock, account two-factor authentication, and available WHOIS privacy.
- Keep the existing Gmail as registrar contact/recovery and as the default sender for new messages. Reply using the address to which the message was sent; the custom address remains selectable for new messages.

Standard non-premium prices observed September 26, 2026:

| Candidate | Listed cost | Decision |
| --- | --- | --- |
| jdatta.me | USD 17.27 registration/annual renewal | Primary choice |
| jdatta.name | USD 7.31 annually | Budget fallback to revisit if primary cannot be bought at standard pricing |
| jdatta.dev | USD 8.75 introductory; USD 12.87 renewal | Considered, not selected |

Expected recurring service cost is USD 17.27/year at the observed rates, plus any applicable taxes/currency conversion. Hosting, forwarding, and SMTP are free within provider limits. Prices are not guaranteed. Exact-domain availability and premium status were NOT verified: attempted RDAP lookups were inaccessible, which is not evidence of availability. If jdatta.me is registered, premium-priced, or materially above the quoted standard price, stop before purchase and present the concrete alternative and price to the user. Do not silently buy a fallback.

Sources: [Porkbun pricing](https://porkbun.com/products/domains), [.name pricing and included features](https://porkbun.com/tld/name). Cloudflare was considered for at-cost registration, but is not required for the selected setup: [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/).

## Current repository observations

Read-only inspection found:

- Root CNAME contains only a newline.
- _config.yml has an empty url, baseurl: "", and CNAME in its exclude list.
- Site uses Jekyll with blog source under blog/ and permalink /blogs/:title/.
- Root index.html contains absolute links to https://jdatta.github.io/number-garden/ and https://jdatta.github.io/dugga-elo.
- No .github workflow or .openai/hosting.json surfaced in the targeted file inventory. Actual remote Pages configuration was not inspected and must be checked before changes.
- Worktree was clean at inspection. Recheck before editing and preserve unrelated work.

Read applicable AGENTS.md files before editing, including nested instructions if touching project directories. There is no need to redesign the site or modify project internals for this task.

## Execution sequence

### 1. Preflight and registration

1. Inspect current repo state and remote Pages publishing configuration. Save existing relevant settings and DNS values for rollback.
2. Search jdatta.me at Porkbun and confirm availability, non-premium status, one-year total, and renewal cost. Obtain purchase authorization as described above; never treat this document as a payment receipt.
3. Register the domain in the user's account, configure security and renewal settings, and complete registrant email verification.
4. Use the existing Gmail address for recovery. Obtain the destination address privately from the user/session; do not infer it from unrelated addresses or commit it to the repository.

### 2. GitHub ownership and repository configuration

1. Under GitHub account Settings > Pages, add jdatta.me for domain verification. Publish the exact TXT host/value GitHub generates in Porkbun DNS, verify it, and retain it permanently.
2. Set repository Settings > Pages > Custom domain to jdatta.me, preserving the existing publishing source. Configure GitHub before pointing website DNS to it.
3. Populate the root CNAME file with exactly jdatta.me and a trailing newline. Reconcile any commit GitHub creates automatically rather than overwriting concurrent changes.
4. Set _config.yml url to "https://jdatta.me", retain baseurl: "", and remove CNAME from the exclude list.
5. Review same-site absolute links. Convert them to root-relative paths only after confirming the corresponding project destinations are served under the new domain. Check both embedded project directories and other GitHub Pages project repositories that inherit the user-site domain. Preserve all existing page paths.
6. Validate and publish using the existing repository deployment process. Do not introduce a new build system.

### 3. Website DNS and HTTPS

Replace conflicting parking/website records with the following. Preserve email and verification records. Use a 600-second TTL where supported.

| Type | Host | Value |
| --- | --- | --- |
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |
| CNAME | www | jdatta.github.io |

Recheck these values against GitHub's current documentation before applying. Start with IPv4 only; remove conflicting apex/www AAAA records. Do not create wildcard DNS or an apex CNAME, and do not use registrar URL forwarding for the main site. The apex must support website records alongside email MX/TXT records.

Wait for DNS checks and GitHub's certificate provisioning, then enable Enforce HTTPS. Confirm www redirects to the canonical apex and the original GitHub Pages URLs redirect appropriately. Allow for DNS/certificate propagation; diagnose persistent errors rather than repeatedly changing records.

References: [GitHub domain verification](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/verifying-your-custom-domain-for-github-pages), [GitHub custom-domain DNS and HTTPS setup](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site).

### 4. Incoming email

1. Create Porkbun forwarding: jdatta@jdatta.me -> the existing Gmail destination.
2. Install/retain exactly the forwarding MX and associated DNS records Porkbun currently requires. Do not point MX to Google or SMTP2GO; SMTP2GO is only the outbound service in this design.
3. Confirm incoming delivery before setting up SMTP2GO, since its signup verification will use the custom address.
4. Do not enable catch-all forwarding. Only the requested address is needed.

Reference: [Porkbun forwarding setup](https://kb.porkbun.com/article/10-how-to-set-up-email-forwarding). Porkbun currently includes up to 20 forwarding addresses.

### 5. Outgoing email and Gmail integration

1. Sign up for SMTP2GO's free plan using the now-working custom address. Complete required account/phone verification and provider approval. Do not purchase a paid tier automatically if signup or activation fails; report the concrete blocker.
2. Verify jdatta.me as a whole sender domain, not merely a single sender address. Publish the exact DNS records generated by SMTP2GO for domain verification, DKIM, and return-path authentication.
3. Preserve Porkbun forwarding records. Avoid duplicate SPF records at any hostname. SMTP2GO's default return-path CNAME manages SPF at its return-path subdomain; do not invent unnecessary apex SPF additions.
4. Create dedicated SMTP credentials. In Gmail Settings > Accounts and Import > Send mail as, add jdatta@jdatta.me with Treat as an alias enabled, SMTP host mail.smtp2go.com, port 587, and TLS. Use SMTP2GO credentials, not the Gmail password.
5. Complete Gmail's verification email through the forwarding route. Configure replies to use the address the message was sent to. Preserve the existing Gmail address as the default for new messages.
6. Disable outbound open/click tracking for personal correspondence where available.
7. Publish _dmarc TXT initially as "v=DMARC1; p=none". After the outbound authentication and reply tests below pass, change it to "v=DMARC1; p=reject". Use default relaxed alignment with SMTP2GO's return-path subdomain. No report mailbox is required for this initial setup.
8. Store credentials in the user's password manager or provider settings, never the repository or handoff document.

Free SMTP2GO limits observed: 1,000 messages/month and 200/day. Monthly exhaustion rejects further sends; this plan assumes low-volume personal correspondence. Recheck limits at implementation and explain them in the completion handoff.

Do not use Gmail POP fetching for incoming mail: Google is retiring that integration. This design uses forwarding plus external SMTP, keeping the existing Gmail inbox and interface without creating a Google-hosted custom-domain mailbox.

References: [SMTP2GO Gmail setup](https://www.smtp2go.com/setupguide/gmail/), [SMTP2GO free limits](https://support.smtp2go.com/hc/en-gb/articles/223087947-Free-Plan), [SMTP2GO authentication](https://support.smtp2go.com/hc/en-gb/articles/28543815517209-SPF-DKIM-and-DMARC-Overview), [Google Send mail as](https://support.google.com/mail/answer/22370?hl=en), [Google POP changes](https://support.google.com/mail/answer/16604719?hl=en).

## Validation and completion criteria

Use targeted build checks and live acceptance checks; no new test framework is needed.

- DNS: apex A records, www CNAME, GitHub ownership TXT, email MX, SMTP2GO verification/DKIM/return-path records, and a single valid DMARC record resolve correctly.
- GitHub: ownership verification and repository DNS checks succeed; existing publishing mechanism builds successfully and retains the custom-domain configuration.
- Website: https://jdatta.me and https://www.jdatta.me have valid certificates; www and HTTP requests redirect to the canonical HTTPS site without loops.
- Compatibility: original GitHub Pages links and representative existing blog/project deep links work; inspect Number Garden and Dugga Elo specifically. Check assets, sitemap, feed, and generated canonical links for stale hostnames or broken paths.
- Inbound mail: send from a different account than the forwarding destination and confirm arrival in the existing Gmail. Testing from the destination itself can cause misleading loop/deduplication behavior.
- Outbound mail: send and reply as jdatta@jdatta.me to independent Gmail and Outlook test accounts controlled by the user or explicitly designated for testing. Obtain authorization before sending test messages if not already provided in the execution session; do not contact arbitrary recipients.
- Inspect received headers for SPF, domain-aligned DKIM, and DMARC pass. Confirm visible From and reply behavior, Gmail Sent storage, and delivery/spam placement. Do not claim guaranteed inbox delivery from a single successful test.
- After authentication tests pass, enforce the planned DMARC reject policy and recheck delivery.
- Do not publish the new email address on the website until mail validation passes. Adding a public contact link is not required by the original scope.

Completion handoff must state the purchased domain, actual initial/renewal costs, configured services, working website/email behavior, validation evidence, renewal settings, and any remaining limits. Record completion date and non-secret operational details here. Do not mark complete if a purchase, deployment, or email test remains unresolved.

## Recovery

If website cutover fails, restore the saved Pages settings and repository configuration, remove the new website DNS records pointing to GitHub, and verify the original jdatta.github.io site works. Retain email and ownership-verification records. Do not leave a domain pointing at an unclaimed GitHub Pages configuration.

If outgoing email fails, keep working incoming forwarding, use the original Gmail identity temporarily, and diagnose SMTP2GO/Gmail authentication. Do not change inbound MX as an attempted outbound fix. If enforcing DMARC introduces a verified legitimate-mail failure, return temporarily to p=none while correcting authentication, then retest before enforcing reject again.

No domain has been purchased, no DNS/GitHub/Gmail settings changed, and no implementation edits made as part of producing this plan.

## Implementation log — 2026-09-30

- Porkbun live search showed `jdatta.me` available as a standard registration. The one-year cart total was USD 17.27, with estimated renewal USD 17.27. No hosting add-ons were selected. Registration/payment is pending the owner's checkout.
- The local repository started at `0631360` on `master`. `docs/` was already untracked; no existing tracked changes were present. The GitHub Pages settings could not be inspected because the browser was signed out of GitHub. The publishing source is therefore still unconfirmed.
- Prepared local, unpublished edits: root `CNAME` contains `jdatta.me`; Jekyll `url` is `https://jdatta.me` and `CNAME` is no longer excluded; homepage project links and the `/c/` favicon link are root-relative. Both project destinations exist in the user-site repository. `git diff --check` passed.
- GitHub's current documentation still lists the four planned IPv4 addresses and recommends configuring the repository custom domain before website DNS. No registrar, DNS, GitHub, Gmail, or SMTP2GO settings have been changed in this implementation session.
- Next: owner completes the one-year Porkbun purchase and signs in to GitHub; then inspect actual Pages settings, verify domain ownership, configure the repository, publish the local edits, and proceed with DNS and mail setup. Obtain the private Gmail forwarding destination in the session without writing it here.

### Follow-up on 2026-09-30

- Owner reported completing the purchase. Purchase receipt, final charge, and Porkbun account settings have not yet been independently inspected.
- GitHub connector confirms the connected account is `JDatta`, has admin access to `JDatta/jdatta.github.io`, and the remote `master` remains at `0631360`; its root `CNAME` is still blank. The local edits remain unpublished.
- Existing `https://jdatta.github.io/number-garden/` and `https://jdatta.github.io/dugga-elo/` returned HTTP 200 (the latter via a trailing-slash redirect).
- Public resolvers 8.8.8.8 and 1.1.1.1 returned NXDOMAIN for `jdatta.me` when checked shortly after the reported purchase. This could be registration/delegation propagation; recheck against the Porkbun account and authoritative DNS before applying website records.
- The browser connection became unavailable after the tabs were closed. Account-level Porkbun and GitHub Pages configuration awaits restored browser access.
- A subsequent direct query to the authoritative `.me` nameserver (`199.253.59.1`) also returned NXDOMAIN for `jdatta.me`; this confirms the registry had not yet delegated the domain at that check. Investigate the Porkbun order/domain status and registrant verification before cutover.
- Owner supplied screenshots showing `jdatta.me` in Porkbun Domain Management, expiring 2027-09-30, and the Porkbun parking page. A later query to 1.1.1.1 returned Porkbun nameservers and the parking A records `207.207.210.229` and `207.207.210.107`; `http://jdatta.me` returned HTTP 200. Registration/delegation is now established. Actual checkout charge remains unverified.
- A new Google support notice says third-party Gmail "Send as" will be removed in January 2027, with possible restrictions on new configurations before then: https://support.google.com/mail/answer/17101213 . Forwarding remains supported. This materially affects the planned long-term outgoing-mail outcome; obtain the owner's choice of temporary setup or durable alternative before completing SMTP/Gmail integration.
- DNS pre-cutover snapshot: apex A `207.207.210.229` and `207.207.210.107`; `www` CNAME `pixie.porkbun.com`; no apex AAAA, MX, or TXT observed through 1.1.1.1. HTTP serves Porkbun parking (200); HTTPS handshake fails. Replace only the website records after GitHub ownership and custom-domain settings are established.
- Direct Chrome automation continued to report that no browser surface was enabled even after the owner reopened Chrome and supplied the Porkbun Domain Management URL. Continue with a manually provided GitHub verification TXT record or a restored browser connection; do not publish the prepared CNAME or replace parking records prematurely.

## Session checkpoint — paused 2026-09-30

The owner is restarting Codex and Chrome. Resume from this checkpoint; the domain has been purchased and is publicly delegated to Porkbun, but GitHub Pages and email are not yet configured. The current public site at `jdatta.me` is Porkbun's HTTP parking page. Do not purchase web hosting.

First action in the next session: try browser control again and inspect Porkbun Domain Management plus GitHub profile Settings > Pages. Confirm the domain's actual paid amount, auto-renewal, lock, WHOIS privacy, and registrant verification. Then add `jdatta.me` to GitHub's profile-level verified domains, place the exact generated TXT record in Porkbun DNS, and complete GitHub verification. Inspect the repository Pages publishing source before changing its custom domain. Only then publish the prepared local edits and replace the parking A/`www` records with the GitHub Pages records in this plan.

Local files currently changed but **not committed or pushed**: `CNAME`, `_config.yml`, `index.html`, and `c/index.html`. `docs/` (including this plan) was already untracked at the start and remains untracked. Preserve this worktree. GitHub `master` was last confirmed at `0631360`; recheck for concurrent changes before publishing. `git diff --check` passes. No GitHub Pages, Porkbun DNS, forwarding, SMTP2GO, or Gmail configuration has been changed by the agent.

Still needed from the owner: the private destination Gmail address for forwarding and a decision on outgoing email after Google's newly announced January 2027 removal of third-party Gmail "Send as". The original SMTP2GO/Gmail approach can only be temporary if Google follows its published schedule. Do not infer the forwarding address from the GitHub profile or commit it to this repository. Test-message recipients must be controlled by or explicitly designated by the owner.

## Continuation — 2026-09-30

- Browser control was retried immediately, but the runtime returned `CUA_REPL_ENABLED_SURFACES is required`; no browser or signed-in account surface was available. The owner was asked to connect signed-in Chrome tabs or provide the exact GitHub verification TXT host/value and account-setting screenshots.
- The GitHub connector confirmed `JDatta/jdatta.github.io` remains on `master` commit `06313602c7c29b70321ac3aeef3de1f6448bbf75` and the connected account has repository admin access. The connector does not expose the Pages settings endpoint, so the actual publishing source and custom-domain state remain unverified.
- The local edits remain unpublished and pass `git diff --check`. `gh` is not installed; direct shell DNS queries are blocked by the session's network sandbox. No additional account or DNS changes were made.
- GitHub's current custom-domain documentation still instructs setting the repository custom domain before DNS and lists the four planned A records. Google's current support notice confirms third-party Gmail "Send as" ends in January 2027 and forwarding remains supported. The owner was asked for the forwarding destination and a choice between a temporary SMTP2GO/Gmail setup and a durable outgoing-mail alternative.
- Continue with account inspection and GitHub ownership verification once account access is available. Do not publish the staged CNAME or replace parking DNS before the repository custom domain is set.

## Manual continuation — 2026-10-02

- Owner requested small manual steps; do not retry Chrome computer use.
- Porkbun screenshot confirms auto-renewal and domain lock ON, contact privacy enabled, Porkbun nameservers retained, expiration 2027-09-30, and estimated renewal USD 17.27. Actual registration charge, account 2FA, and registrant verification remain unconfirmed. Private contact information from the screenshot is not recorded here.
- Owner added the GitHub ownership TXT record and reported GitHub now shows Verified. Retain the record permanently.
- Repository Pages screenshot confirms Deploy from a branch, master, /(root). Owner saved custom domain jdatta.me; subsequent screenshot confirms it is configured, with NotServedByPagesError while DNS still points at parking.
- Current Porkbun screenshot shows apex ALIAS to pixie.porkbun.com, wildcard CNAME to pixie.porkbun.com, and the ownership TXT. This supersedes the earlier inferred www parking CNAME snapshot.
- Next manual step: delete the two parking records, retain ownership TXT, add the four GitHub apex A records and explicit www CNAME with TTL 600, then recheck Pages DNS and certificate provisioning. GitHub documentation revalidated on 2026-10-02.
- Local prepared site changes have not been published by this continuation. GitHub may have created its own CNAME commit when the owner saved the custom domain; reconcile before publishing local changes.

### Owner update and repository reconciliation — 2026-10-02

- Owner confirmed incoming email works. Replies currently use the existing personal Gmail identity, which the owner accepts for now. Outgoing SMTP2GO/custom-address sending is deferred; do not mark it configured. The chosen primary email identity is contact@jdatta.me; additional aliases are optional.
- Owner will finish Enforce HTTPS tomorrow. Latest GitHub screenshot shows DNS check successful and Certificate Active, with Enforce HTTPS still unavailable at that time. HTTPS redirects and live compatibility validation remain pending.
- Porkbun screenshot confirms all four GitHub apex A records, www CNAME to jdatta.github.io, ownership TXT retained, TTL 600, and parking records removed.
- Fetched origin/master and inspected GitHub's automatic e8e4fff (Update CNAME) commit. It changes only CNAME to jdatta.me. Fast-forwarded the local branch to that commit before creating the requested local implementation commit; retained a trailing newline in CNAME.
- Commit scope: CNAME, _config.yml, homepage project links, /c/ favicon link, and this plan. Other untracked docs are excluded. Owner requested a local commit to push themselves; no push performed. No build or live path checks run in this commit-only step.
- After the owner pushes, check the existing Pages deployment succeeds, blog/project paths and canonical metadata work, finish HTTPS, and record remaining account/cost checks. Incoming mail is owner-confirmed; outgoing custom-address authentication and DMARC enforcement are deferred.
