# GitHub Setup Guide

## Creating GitHub Repository

1. **Create New Repository**
   - Go to GitHub.com and sign in
   - Click "New repository"
   - Repository name: `PanDerm-iOS`
   - Description: "Dermatology iOS application for patient management and skin analysis"
   - Make it Private (recommended for healthcare apps)
   - Don't initialize with README (we already have one)

2. **Connect Local Repository**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/PanDerm-iOS.git
   git branch -M main
   git push -u origin main
   ```

## Backup Strategy

### Daily Development
- Commit frequently with descriptive messages
- Push to main branch at least once per day
- Use feature branches for major changes

### Feature Development
```bash
# Create feature branch
git checkout -b feature/patient-management

# Make changes and commit
git add .
git commit -m "Add patient management functionality"

# Push feature branch
git push origin feature/patient-management

# Create pull request on GitHub
# Merge after review
```

### Release Management
```bash
# Create release branch
git checkout -b release/v1.0.0

# Tag releases
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Branch Protection Rules

Set up on GitHub:
1. Go to repository Settings > Branches
2. Add rule for `main` branch
3. Enable:
   - Require pull request reviews
   - Require status checks to pass
   - Require branches to be up to date
   - Include administrators

## Automated Backups

### GitHub Actions (Optional)
Create `.github/workflows/backup.yml`:
```yaml
name: Daily Backup
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create backup
        run: |
          echo "Backup completed at $(date)" >> backup.log
          git add backup.log
          git commit -m "Daily backup $(date)" || exit 0
          git push
```

## Security Considerations

1. **Sensitive Data**
   - Never commit API keys or secrets
   - Use environment variables
   - Add `.env` files to `.gitignore`

2. **Healthcare Data**
   - Ensure HIPAA compliance
   - Use encrypted storage
   - Implement proper access controls

3. **Code Review**
   - Require reviews for all changes
   - Use automated security scanning
   - Regular dependency updates

## Collaboration Workflow

1. **Fork Repository** (if external contributors)
2. **Create Feature Branch**
3. **Make Changes**
4. **Write Tests**
5. **Create Pull Request**
6. **Code Review**
7. **Merge to Main**

## Emergency Recovery

### Local Recovery
```bash
# Reset to last known good state
git reset --hard HEAD~1

# Recover specific file
git checkout HEAD~1 -- path/to/file
```

### Remote Recovery
```bash
# Fetch latest
git fetch origin

# Reset to remote main
git reset --hard origin/main
```

## Monitoring

- Set up repository notifications
- Monitor for security alerts
- Regular backup verification
- Performance monitoring for large files 