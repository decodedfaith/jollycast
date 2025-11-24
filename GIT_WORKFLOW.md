# Git Workflow Guide

## Branching Strategy

### Main Branches

- **`main`** - Production-ready code only
- **`develop`** - Integration branch for features

### Feature Branches

Create feature branches from `develop`:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/feature-name
```

## Implemented Features and Branches

### 1. Feature: Authentication System
**Branch**: `feature/authentication`

**Commits**:
```
feat(auth): implement secure token-based authentication
feat(auth): add token storage with shared preferences
feat(auth): implement session management
feat(auth): add persistent login state
```

**Files Changed**:
- `lib/services/auth_service.dart`
- `lib/viewmodels/auth_viewmodel.dart`
- `lib/views/login_screen.dart`
- `lib/views/onboarding_screen.dart`

---

### 2. Feature: Search Functionality
**Branch**: `feature/search`

**Commits**:
```
feat(search): implement debounced search with 300ms delay
feat(search): add search history with max 10 items
feat(search): create search screen with results display
feat(search): add multi-field search (title, description, author)
feat(search): integrate search in discover and library tabs
```

**Files Changed**:
- `lib/services/search_service.dart`
- `lib/viewmodels/search_viewmodel.dart`
- `lib/views/search_screen.dart`
- `lib/views/podcast_list_screen.dart`
- `lib/views/tabs/library_tab.dart`

---

### 3. Feature: Category System
**Branch**: `feature/categories`

**Commits**:
```
feat(categories): implement keyword-based categorization
feat(categories): add 12 predefined categories
feat(categories): create dynamic category grouping
feat(categories): update categories tab with real data
feat(categories): add category filtering
```

**Files Changed**:
- `lib/services/search_service.dart`
- `lib/viewmodels/search_viewmodel.dart`
- `lib/views/tabs/categories_tab.dart`
- `lib/views/category_screen.dart`

---

### 4. Feature: User Preferences
**Branch**: `feature/user-preferences`

**Commits**:
```
feat(preferences): implement favorites functionality
feat(preferences): add follow podcasts feature
feat(preferences): implement recently played tracking
feat(preferences): create library tab with user data
feat(preferences): integrate preferences across app
```

**Files Changed**:
- `lib/services/user_preferences_service.dart`
- `lib/viewmodels/user_preferences_viewmodel.dart`
- `lib/views/tabs/library_tab.dart`
- `lib/views/podcast_list_screen.dart`

---

### 5. Feature: Player Redesign
**Branch**: `feature/player-redesign`

**Commits**:
```
feat(player): redesign with green gradient background
feat(player): add large artwork with shadow
feat(player): implement scale animation on play/pause
feat(player): add modern playback controls
feat(player): integrate action buttons (queue, save, share)
```

**Files Changed**:
- `lib/views/player_screen.dart`

---

### 6. Feature: Episode List Redesign
**Branch**: `feature/episode-list-redesign`

**Commits**:
```
feat(episodes): add hero header with artwork
feat(episodes): implement action buttons (play, follow, queue)
feat(episodes): create about podcast section
feat(episodes): add sort/filter controls
feat(episodes): implement show more pagination
```

**Files Changed**:
- `lib/views/episode_list_screen.dart`

---

### 7. Feature: UI Polish
**Branch**: `feature/ui-polish`

**Commits**:
```
feat(ui): update header with rounded container
feat(ui): fix mini player positioning
feat(ui): add hero animations
feat(ui): implement smooth transitions
```

**Files Changed**:
- `lib/views/podcast_list_screen.dart`
- `lib/widgets/mini_player.dart`

---

## Atomic Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Code style (formatting, missing semicolons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests
- **chore**: Changes to build process or auxiliary tools

### Examples

#### Good Commits:
```
feat(search): implement debounced search with history

- Added SearchService with 300ms debouncing
- Implemented search history using SharedPreferences
- Created SearchScreen with results display
- Integrated search in discover and library tabs

Closes #123
```

```
fix(player): resolve icon errors for replay_15 and forward_15

Changed Icons.replay_15 to Icons.replay_10 and Icons.forward_15 
to Icons.forward_10 as these icons don't exist in Material Icons.

Fixes #124
```

```
refactor(viewmodels): migrate from StateNotifier to Notifier

Updated all viewmodels to use Riverpod 2.0 Notifier pattern for 
better performance and cleaner code.
```

#### Bad Commits:
```
❌ update files
❌ fix bug
❌ WIP
❌ changes
```

---

## Git Commands Cheat Sheet

### Starting New Feature

```bash
# Update develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/feature-name

# Work on feature...
# Stage changes
git add lib/services/new_service.dart

# Commit with meaningful message
git commit -m "feat(service): add new service"

# Push to remote
git push origin feature/feature-name
```

### Creating Pull Request

```bash
# Ensure branch is up to date
git checkout develop
git pull origin develop
git checkout feature/feature-name
git rebase develop

# Resolve conflicts if any
# Push changes
git push origin feature/feature-name --force-with-lease
```

### Merging to Develop

```bash
# After PR approval
git checkout develop
git pull origin develop
git merge --no-ff feature/feature-name
git push origin develop
```

### Hotfix

```bash
# For urgent production fixes
git checkout main
git checkout -b hotfix/issue-description

# Make fix
git add .
git commit -m "fix(critical): description of fix"

# Merge to main
git checkout main
git merge --no-ff hotfix/issue-description
git tag -a v1.0.1 -m "Hotfix: issue description"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff hotfix/issue-description
git push origin develop
```

---

## Pull Request Template

```markdown
## Description
Brief description of changes made

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related Issue
Closes #(issue number)

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Manual testing completed
- [ ] All test cases passing
- [ ] No regression issues

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] No new warnings generated
- [ ] Documentation updated
```

---

## Release Process

### Version Numbering

Follow Semantic Versioning (SemVer):
- **Major**: Breaking changes (v2.0.0)
- **Minor**: New features, backward compatible (v1.1.0)
- **Patch**: Bug fixes, backward compatible (v1.0.1)

### Creating Release

```bash
# Update version in pubspec.yaml
# Update CHANGELOG.md

# Commit version bump
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.1.0"

# Merge to main
git checkout main
git merge --no-ff develop

# Tag release
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge main
git push origin develop
```

---

## Best Practices

1. **Commit Often**: Make small, focused commits
2. **Write Good Messages**: Clear, descriptive commit messages
3. **Rebase Before Merge**: Keep history clean
4. **Review Before Push**: Double-check changes
5. **Use Branches**: Never commit directly to main/develop
6. **Tag Releases**: Use semantic versioning
7. **Update Docs**: Keep README and CHANGELOG current

---

## Troubleshooting

### Undo Last Commit (not pushed)
```bash
git reset --soft HEAD~1
```

### Undo Last Commit (pushed)
```bash
git revert HEAD
git push origin feature/branch-name
```

### Resolve Merge Conflicts
```bash
# During rebase
git status  # See conflicting files
# Edit files to resolve conflicts
git add .
git rebase --continue
```

### Clean Untracked Files
```bash
git clean -fd
```
