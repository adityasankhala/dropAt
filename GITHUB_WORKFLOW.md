# 📘 DropAt — GitHub Workflow Rulebook

> **Team:** Anshika + Aditya
> **Repo:** `adityasankhala/lifeproject`
> **Last Updated:** September 6, 2026

---

## 🚫 The #1 Rule

> **NEVER push directly to `main`.**

`main` is the **production-ready** branch. It should only ever be updated through **Pull Requests (PRs)** that have been reviewed by the other teammate.

---

## 🌳 Branch Structure

```
main                    ← Production-ready code (PROTECTED)
├── feature/anshika     ← Anshika's working branch
├── feature/aditya      ← Aditya's working branch
└── feature/<name>      ← Temporary feature branches (optional)
```

### Branch Naming Convention

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/<short-description>` | `feature/google-login` |
| Bug fix | `fix/<short-description>` | `fix/otp-crash` |
| Hotfix | `hotfix/<short-description>` | `hotfix/production-auth-fix` |
| Personal dev | `feature/<your-name>` | `feature/anshika` |

---

## 🔄 Daily Workflow

### Starting Work

```bash
# 1. Switch to your branch
git checkout feature/anshika      # or feature/aditya

# 2. Pull latest changes from main FIRST
git pull origin main

# 3. Now do your work...
```

### Saving Your Work

```bash
# 1. Stage your changes
git add -A

# 2. Write a clear commit message (see format below)
git commit -m "feat: add phone OTP verification screen"

# 3. Push to YOUR branch (never to main!)
git push origin feature/anshika
```

### Getting Your Code Into Main

```
1. Push your branch to GitHub
2. Go to GitHub → Pull Requests → "New Pull Request"
3. Set: base = main, compare = feature/anshika
4. Write a clear title and description
5. Request review from your teammate
6. Teammate reviews + approves
7. Click "Merge Pull Request"
8. Done! ✅
```

---

## ✍️ Commit Message Format

Use clear, consistent commit messages:

```
<type>: <short description>

Types:
  feat:     New feature or screen
  fix:      Bug fix
  style:    UI/styling changes (no logic change)
  refactor: Code restructure (no feature change)
  docs:     Documentation only
  config:   Config/env/build changes
  chore:    Maintenance (dependencies, cleanup)
```

**Good examples:**
```
feat: add ride history screen with fare breakdown
fix: Google Sign-In crash on macOS due to missing URL scheme
config: update firebase_options.dart with real web credentials
style: redesign login screen with gradient background
docs: add Firebase production checklist for team
```

**Bad examples:**
```
updated stuff
fix
asdkfjasdf
changes
final final final v2
```

---

## 🔀 Pull Request (PR) Rules

### Before Creating a PR
- [ ] Code compiles without errors (`flutter analyze`)
- [ ] App runs without crashing
- [ ] You've tested the specific feature you changed
- [ ] No API keys, passwords, or secrets in the code
- [ ] Commit messages are clean and descriptive

### PR Description Template
When creating a PR, include:
```markdown
## What Changed
- Brief description of changes

## How to Test
1. Run the app
2. Go to [screen]
3. Expected behavior: [what should happen]

## Screenshots (if UI change)
[Attach before/after screenshots]
```

### Review Process
- The **other teammate** must review and approve before merging
- Reviewer should actually pull the branch and test it locally if it's a big change
- Use GitHub comments for feedback
- Don't merge your own PR unless it's an emergency hotfix

---

## ⚠️ Handling Merge Conflicts

When you get a merge conflict:

```bash
# 1. Make sure you're on your branch
git checkout feature/anshika

# 2. Pull latest main
git pull origin main

# 3. If conflicts appear, open the conflicted files
#    Look for these markers:
#    <<<<<<< HEAD
#    (your code)
#    =======
#    (their code)
#    >>>>>>> main

# 4. Manually pick the correct code, remove the markers

# 5. Stage and commit the resolution
git add -A
git commit -m "fix: resolve merge conflicts with main"

# 6. Push
git push origin feature/anshika
```

**Golden rule:** If unsure, ask your teammate before resolving a conflict in their code.

---

## 🛡️ Protecting Main Branch (Aditya — Do This!)

Go to GitHub → **Settings → Branches → Branch protection rules → Add rule**:

1. Branch name pattern: `main`
2. Enable:
   - [x] **Require a pull request before merging**
   - [x] **Require approvals** (set to 1)
   - [x] **Do not allow bypassing the above settings**
3. Click **Save changes**

This physically prevents anyone (including Aditya) from pushing directly to main.

---

## 📁 Files That Should NEVER Be Committed

These are already in `.gitignore` but double-check:

```
# Secrets
.env
*.p8
*.keystore
**/google-services.json     ← debatable, some teams include it
**/GoogleService-Info.plist  ← debatable, some teams include it

# Build artifacts
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
*.iml
.vscode/

# OS
.DS_Store
Thumbs.db
```

---

## 🤖 Instructions for AI Coding Agents

When an AI agent (Antigravity, Copilot, etc.) is performing git operations:

1. **Always work on the user's feature branch**, never on `main`
2. **Check the current branch** before committing: `git branch --show-current`
3. **Never force push** (`git push --force`) unless explicitly asked
4. **Write descriptive commit messages** following the format above
5. **Don't commit secrets** — check for API keys, passwords, tokens before staging
6. **Pull before pushing** — always `git pull origin <branch>` before pushing to avoid conflicts
7. **Don't merge branches** — leave merging to the humans via Pull Requests
8. **Atomic commits** — group related changes into one commit, don't mix unrelated changes

---

## 📋 Quick Reference

| Action | Command |
|--------|---------|
| Check current branch | `git branch --show-current` |
| Switch branch | `git checkout feature/anshika` |
| Create new branch | `git checkout -b feature/new-thing` |
| Pull latest main | `git pull origin main` |
| Push your branch | `git push origin feature/anshika` |
| See what changed | `git status` |
| See commit history | `git log --oneline -10` |
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| Stash work temporarily | `git stash` |
| Restore stashed work | `git stash pop` |

---

## 🚀 Getting Started Checklist

### Aditya (one-time setup):
- [ ] Enable branch protection on `main` (see section above)
- [ ] Move any uncommitted work to `feature/aditya`
- [ ] Stop pushing directly to `main`

### Anshika (one-time setup):
- [ ] Sync your branch: `git pull origin main`
- [ ] Continue working on `feature/anshika`

### Both:
- [ ] Read this document
- [ ] Agree to follow the PR workflow
- [ ] Start creating PRs instead of direct pushes
