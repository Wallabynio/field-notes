# Field Notes — standalone app setup

The app is a small website (hosted free on GitHub Pages) that you install on your iPhone from Safari with **Share → Add to Home Screen**. It opens full screen with the rings logo. Your data lives in a private Supabase database behind your own email and password, so phone and laptop stay in sync.

## Your one-time steps
1. **Connect GitHub to Claude** in claude.ai settings, so Claude can publish and update the app's code.
2. **Create an empty GitHub repository** called `field-notes` (Public, no README). Public is needed for free GitHub Pages: only the app's code is public, never your data.
3. **Create a Supabase project:** sign up at supabase.com (Continue with GitHub is easiest) → New project → name `field-notes`, region **Sydney**, choose a database password and keep it in your password manager.
4. **Create the tables:** Supabase → SQL Editor → New query → paste everything from `setup.sql` → Run.
5. **Copy two values for Claude:** Project Settings → API: the **Project URL** and the **anon public** key.

## Claude then
- Puts the two values into `config.js`, publishes the code to the repository and switches on GitHub Pages.
- Gives you the app's address.

## Then you
- Open the address in Safari, tap **First time? Create my account** (email + password).
- Safari → Share → **Add to Home Screen** → the rings icon appears; it opens full screen.
- In Supabase → Authentication → Sign In / Providers, turn off **Allow new users to sign up**, so nobody else can create an account.

## Good to know
- Supabase's free plan pauses a project after 7 days without any use; daily use keeps it awake. Data is kept while paused, and you can restore it from the Supabase dashboard.
- The free plan has no automatic backups, so the app will get an export button that saves a backup file to this folder.

## Update for version 0.3 (BAS, income tax, logbook)

Run once: Supabase → SQL Editor → New query → paste `update-v0.3.sql` → Run. Until then the app works as before and shows a notice; the new fields (gross fares, Uber fees, business share, GST, invoice kept, logbook) are not saved.

## Update for version 0.4 (weigh-ins)

Run once: Supabase → SQL Editor → New query → paste `update-v0.4.sql` → Run (accept the "destructive operations" warning — it only refers to the privacy rule on the new table).

## Update for app version 0.7 (course, assessments and study plans)

Run once: Supabase → SQL Editor → New query → paste `update-v0.5.sql` → Run (accept the "destructive operations" warning — it only refers to the privacy rules on the new tables). Until then the Study tab shows Urban Project Part A read-only with a notice. On the first load after the update, the three Part A assessments are added automatically, with study plans.

## Update for versions 1.1–1.2 (driving stints, Uber balance, statements, bills, food prices, bank accounts, gym, walks, check-in, offline)

Run once: Supabase → SQL Editor → New query → paste `update-v1.1.sql` → Run. One script covers versions 1.1 to 1.2. Until then the app shows a notice and the new entries are not saved. After it runs: Money → Bank accounts → Start, once for each account, with the balance at the start of the first day. Older shifts stay and keep counting. The app now also keeps a copy on the phone (`sw.js`), so it opens and saves without signal and syncs later.
