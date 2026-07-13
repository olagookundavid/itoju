# Itoju — Tester's Guide

*Written for a non-technical tester. No jargon required — if anything in here
doesn't make sense, that's a bug in this document, tell us!*

---

## 1. What changed, in plain English

Itoju used to require an internet connection and an account before you could do
anything. That has been completely reworked. Here's the new world:

**1. The app now works fully offline, no account needed.**
Everything you track — symptoms, food, sleep, exercise, period, medications,
mood — is saved **on your phone**. You can install the app, skip sign-up
entirely, and use every feature with no internet at all. Your data is yours,
on your device.

**2. Signing in is only for cloud backup.**
An account now exists for exactly one reason: backing your data up to the
cloud (so you can recover it if you lose your phone, or use two devices).
You choose when that happens, from Settings. During this testing phase, cloud
backup is **free for everyone** — there is no payment screen anywhere.

**3. The app locks itself like WhatsApp.**
When you open the app (or come back to it after more than 15 minutes), it asks
for your fingerprint / Face ID, falling back to your phone's PIN. This is on by
default and can be turned off in Settings. It protects your health data even
if someone else picks up your phone.

**4. Softer onboarding.**
On first launch the app just asks what to call you — no email, no password, no
date of birth. If you later decide to create an account, your name is already
filled in.

**5. Smart syncing (for when you're signed in).**
You can back up manually ("Back up now" in Settings) or pick a rhythm: daily,
weekly, or monthly. The app checks whether a backup is due whenever you open
it — it does *not* wake itself up at an exact time in the background (phones
don't reliably allow that), so a "daily" backup happens the first time you
open the app that day.

**Why it was built this way (the two big decisions):**
- *Your phone is the source of truth.* The cloud is a copy of your phone, not
  the other way round. That's what makes offline work everywhere.
- *If you use two devices, the newest edit wins.* If the same entry is changed
  on two phones, the most recent change is the one that's kept.

---

## 2. What we need you to test

Work through these scenarios in order if you can. For each one, the **bold
line** is what should happen — if reality differs, that's a bug, please report
it using the template in section 4.

### A. First launch (fresh install)
1. Install the app on a phone that never had it (or delete + reinstall).
2. Open it. You should see intro slides, then a "What should we call you?"
   screen. You can skip the name.
3. **You land in the app, fully usable, without ever being asked for an email
   or password.**

### B. Offline tracking (the big one)
1. Put your phone in **airplane mode**.
2. Use the app normally for a while: log symptoms, food, sleep, water, a
   period day, medications — everything you'd normally track. Browse your
   analytics/history.
3. Force-close the app, reopen it (still in airplane mode).
4. **Everything works and nothing is lost. No error messages about "no
   connection", no spinners that never finish.**
5. Stay offline for a day or two of normal use if you can — that's the real
   test.

### C. App lock (biometrics)
1. Close the app fully, reopen it. **You're asked for fingerprint / Face ID.**
2. Fail the biometric on purpose (wrong finger). **It offers your phone
   PIN/passcode as a fallback.**
3. Send the app to the background briefly (under 15 min), come back.
   **No lock — it lets you straight in.**
4. Leave it in the background for more than 15 minutes, come back.
   **It asks you to unlock again.**
5. Turn the lock off in Settings, restart the app. **No lock prompt.**
   Turn it back on.

### D. Creating an account / signing in
1. In Settings, find the cloud sync/backup section. Since you're not signed
   in, **it invites you to sign in to back up — the rest of the app never
   nagged you about it.**
2. Sign up (or use "Continue with Google"). **If you gave a name during
   onboarding, it's pre-filled on the sign-up form.**
3. **After signing in you land back in the app and all the data you tracked
   offline is still there** — signing in must never wipe or reset anything.

### E. Cloud backup
1. Once signed in, go to Settings → cloud sync. Tap **"Back up now"** with
   internet on. **It completes and shows when the last backup happened.**
2. Try "Back up now" in airplane mode. **You get a clear, polite message that
   it couldn't back up — not a crash, not a permanent spinner.**
3. Set the backup rhythm to Daily, close the app, reopen it later.
   **No visible disruption — backups happen quietly in the background when
   due.**

### F. Restore (if you have time / a second device)
1. With data backed up, delete the app and reinstall (or sign in on a second
   phone).
2. Sign in with the same account and give it a moment.
3. **Your history comes back.** *Known exception: your choices of which
   metrics/conditions to track don't transfer yet — you'll need to re-select
   them once. Your actual data does come back. (See quirk #3.)*

### G. Switching accounts on one phone (edge case)
1. If you have two test accounts: sign out, then sign in as the *other*
   account.
2. **The app notices the phone's data belongs to a different account and asks
   whether to keep or erase it — it never silently mixes two people's health
   data.**

---

## 3. Known quirks — please DON'T report these

These are known and intentional (or known and already on the list). Reporting
them again just creates noise:

1. **"Daily" backup doesn't happen at an exact time.** It runs the next time
   you open the app after it's due. This is a deliberate design choice —
   phones don't reliably run apps in the background at exact times.
2. **Backup requires being signed in.** Everything else works signed-out;
   only cloud backup/restore needs an account. That's by design.
3. **After a restore, your tracked-metric selections are reset.** Your data
   is all there, but which metrics you'd chosen to track needs re-selecting
   once. Known limitation of this version.
4. **No payment/premium screens anywhere.** Correct for this phase — sync is
   free during testing. If you *do* see anything about payment, that IS a bug.
5. **First backup after signing in can take noticeably longer** — it's
   uploading your whole history once. After that, backups are quick.

---

## 4. How to report a bug

One message per bug, please — five small reports are far more useful than one
long voice note covering five things. Copy this template:

```
BUG REPORT
Title:        (one line — what went wrong)
Where:        (which screen were you on?)
What I did:   (step by step — what did you tap/do just before it happened?
               1. ...
               2. ...
               3. ...)
What I expected: (what should have happened?)
What happened:   (what actually happened? exact wording of any error message)
How often:    (every time? once? sometimes?)
Internet:     (online / airplane mode / bad connection?)
Signed in:    (yes / no)
Phone:        (e.g. Samsung A54, iPhone 13)
Date & time:  (when it happened — helps us find it in the logs)
Screenshot:   (attach one if you can — screen-record if it's hard to capture)
```

### Example of a great report

```
BUG REPORT
Title:        "Back up now" spinner never stops in airplane mode
Where:        Settings → Cloud sync
What I did:   1. Put phone in airplane mode
              2. Opened Settings → Cloud sync
              3. Tapped "Back up now"
What I expected: A message saying backup failed because I'm offline
What happened:   The button shows a spinner that never stops. No error.
                 Still spinning after 5 minutes.
How often:    Every time (tried 3 times)
Internet:     Airplane mode
Signed in:    Yes
Phone:        iPhone 13, iOS 18
Date & time:  Tue 14 July, ~2:30pm
Screenshot:   attached
```

**Rules of thumb:**
- *Crashes, lost data, being locked out, or seeing someone else's data* —
  report immediately, top priority.
- Not sure if it's a bug or a quirk? Check section 3 first; if it's not
  there, report it — better a duplicate than a miss.
- "It feels slow/confusing/ugly" is valuable feedback too! Send it the same
  way, just write "FEEDBACK" instead of "BUG REPORT" on the first line.

Thank you! 💛
