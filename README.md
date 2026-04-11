# Icarus — BzTracker embed fork

This repository is a **fork** of **[Icarus: Valorant Strategies & Lineups](https://github.com/SunkenInTime/icarus)** by Dara A. It exists to ship a **Flutter web embed** that runs inside a parent web app (**[BzTracker](https://github.com/raulb1zkit/bztracker-refactor)**) using an `iframe` and `postMessage`, without rewriting the editor in another stack.

> **Upstream:** [github.com/SunkenInTime/icarus](https://github.com/SunkenInTime/icarus)  
> **Desktop app (Microsoft Store):** [Icarus on the Microsoft Store](https://apps.microsoft.com/detail/9PBWHHZRQFW6?hl=en-us&gl=US&ocid=pdpshare)

If you only want the original desktop-focused tool, use **upstream** directly.

---

## What this fork adds

These changes focus on **embedding** the same `lib/` canvas experience in a browser shell:

| Feature | Description |
|--------|-------------|
| **Embed mode** | Load the web app with `?embed=1` (see `lib/const/embed_mode.dart`). |
| **Parent bridge** | `postMessage` handlers for loading/saving strategy JSON (`lib/embed/`). |
| **Protocol** | `ICARUS_READY`, `ICARUS_LOAD` (payload = strategy JSON), `ICARUS_SAVE` (after save), `ICARUS_ERROR`. |
| **Import/export JSON** | `StrategyProvider.importFromEmbedJsonString` and `buildEmbedPayloadJson` align with the JSON inside a single-strategy `.ica` export. |
| **UX in embed** | Skips the one-off web “demo” dialog when embedded (`FolderNavigator` + embed flag). |

Web parity with Windows (e.g. embedded images in exports) may still differ; see upstream and Flutter `kIsWeb` behavior.

---

## Requirements

- **Flutter SDK** with Dart `>=3.4.3` (see `pubspec.yaml`).

---

## Local development

```bash
flutter pub get
flutter run -d chrome
```

For embed testing, open the web build with **`?embed=1`** on the URL.

---

## Web build (static bundle)

Upstream uses non-constant `IconData` in a few places, so **icon tree shaking must be disabled** for web release builds:

```bash
flutter build web --base-href /kanvas-embed/ --no-tree-shake-icons
```

Serve the contents of `build/web/` under the same path you passed to `--base-href` (for example `public/kanvas-embed/` in a Next.js app). In BzTracker, run `scripts/sync-kanvas-embed.sh` after building.

---

## Keeping up with upstream

```bash
git remote add upstream https://github.com/SunkenInTime/icarus.git   # if not already added
git fetch upstream
git merge upstream/main    # or: git rebase upstream/main
```

Resolve conflicts if any, then rebuild web.

---

## Architecture (inherited from upstream)

- **Flutter + Riverpod + Hive** — strategy state lives in Riverpod; persistence uses Hive.
- `lib/main.dart` bootstraps the app and registers the embed bridge on web.
- Core workflow: `lib/providers/strategy_provider.dart`.

---

## License

Same as **upstream** — see [LICENSE](./LICENSE).

---

## Credits

- **Original Icarus** — Dara A. and contributors: [SunkenInTime/icarus](https://github.com/SunkenInTime/icarus).  
- **Embed patches** — maintained for [BzTracker](https://github.com/raulb1zkit/bztracker-refactor).

Support the original author: [Buy Me a Coffee](https://www.buymeacoffee.com/daradoescode).
