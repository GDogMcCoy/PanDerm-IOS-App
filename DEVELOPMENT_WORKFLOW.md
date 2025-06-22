# Development Workflow Guide

## Simultaneous Cursor + Xcode Development

### Setup
1. **Open in Cursor**: Use Cursor for code editing and AI assistance
2. **Open in Xcode**: Use Xcode for building, testing, and debugging
3. **File Watching**: Both editors will detect changes automatically

### Recommended Workflow

#### Code Editing (Cursor)
- Write new features and refactor code
- Use AI assistance for code generation
- Edit multiple files simultaneously
- Use Cursor's advanced search and replace

#### Building & Testing (Xcode)
- Build and run the application
- Use Xcode's debugging tools
- Run unit and UI tests
- Use Interface Builder (if needed)
- Manage project settings and capabilities

### File Organization

#### Cursor Tasks
- [ ] Write new Swift files
- [ ] Refactor existing code
- [ ] Add documentation
- [ ] Create unit tests
- [ ] Update README files

#### Xcode Tasks
- [ ] Build and run app
- [ ] Debug issues
- [ ] Test on simulator/device
- [ ] Manage signing and capabilities
- [ ] Create app icons and assets

### Best Practices

#### Code Synchronization
```bash
# Before switching between editors
git add .
git commit -m "WIP: [brief description]"
git push origin main
```

#### File Conflicts
- Save files before switching editors
- Use `Cmd+S` frequently
- Check git status before committing
- Resolve conflicts immediately

#### Project Structure
- Keep Xcode project file updated
- Add new files through Xcode when possible
- Update folder references in project navigator
- Maintain proper target membership

### Development Phases

#### Phase 1: Setup & Foundation
- [x] Project structure created
- [x] Basic app skeleton
- [x] Git repository initialized
- [ ] Core Data model setup
- [ ] Basic networking layer
- [ ] Authentication service

#### Phase 2: Core Features
- [ ] Patient management views
- [ ] Skin analysis functionality
- [ ] Treatment plan creation
- [ ] Appointment scheduling
- [ ] Data persistence

#### Phase 3: Advanced Features
- [ ] AI integration
- [ ] Image processing
- [ ] HealthKit integration
- [ ] Push notifications
- [ ] Offline support

#### Phase 4: Polish & Testing
- [ ] UI/UX refinement
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] App Store preparation

### Daily Routine

#### Morning
1. Pull latest changes: `git pull origin main`
2. Open project in both editors
3. Review any merge conflicts
4. Plan day's tasks

#### During Development
1. Code in Cursor
2. Test in Xcode
3. Commit frequently
4. Push changes regularly

#### End of Day
1. Final commit and push
2. Update task tracking
3. Plan next day's priorities

### Troubleshooting

#### Common Issues
- **Build errors**: Check Xcode for missing files
- **Git conflicts**: Resolve in terminal or Git client
- **File not found**: Verify target membership in Xcode
- **Performance issues**: Check for large files or memory leaks

#### Recovery Steps
```bash
# Reset to clean state
git reset --hard HEAD
git clean -fd

# Rebuild project
# Delete DerivedData folder
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Tools & Extensions

#### Cursor Extensions
- Swift language support
- Git integration
- Code formatting
- Linting tools

#### Xcode Extensions
- SwiftLint
- Code formatting
- Git integration
- Performance profiling

### Communication

#### Team Collaboration
- Use feature branches
- Create pull requests
- Code review process
- Regular standups

#### Documentation
- Update README files
- Document API changes
- Maintain changelog
- Create user guides 