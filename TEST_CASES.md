# Test Cases - Jollycast App

## Manual Testing Checklist

### 1. Authentication Tests

#### TC-001: Successful Login
**Preconditions**: Valid credentials available
**Steps**:
1. Launch app
2. Enter valid email and password
3. Tap "Sign In" button

**Expected Result**: 
- User logged in successfully
- Redirected to podcast list screen
- Token stored in SharedPreferences

**Status**: ✅ PASS

---

#### TC-002: Invalid Credentials
**Preconditions**: None
**Steps**:
1. Launch app
2. Enter invalid email/password
3. Tap "Sign In"

**Expected Result**:
- Error message displayed
- User remains on login screen
- No token stored

**Status**: ✅ PASS

---

#### TC-003: Token Persistence
**Preconditions**: User previously logged in
**Steps**:
1. Close app completely
2. Reopen app

**Expected Result**:
- App skips login screen
- Directly shows podcast list
- Previous session restored

**Status**: ✅ PASS

---

### 2. Podcast Discovery Tests

#### TC-004: Load Trending Podcasts
**Preconditions**: API available
**Steps**:
1. Login successfully
2. View discover tab

**Expected Result**:
- Trending section shows podcasts
- Images load correctly
- Titles and authors display

**Status**: ✅ PASS

---

#### TC-005: Navigate to Episode List
**Preconditions**: Podcasts loaded
**Steps**:
1. Tap any podcast card
2. Wait for episode list

**Expected Result**:
- Episode list screen opens
- Hero animation plays smoothly
- Episodes load and display

**Status**: ✅ PASS

---

### 3. Search Tests

#### TC-006: Search with Debouncing
**Preconditions**: Podcasts loaded
**Steps**:
1. Tap search icon
2. Type search query quickly
3. Observe behavior

**Expected Result**:
- Search waits 300ms before executing
- No lag during typing
- Results update after pause

**Status**: ✅ PASS

---

#### TC-007: Search History
**Preconditions**: None
**Steps**:
1. Open search screen
2. Search for "tech"
3. Search for "news"
4. Close search
5. Reopen search

**Expected Result**:
- Recent searches display
- "tech" and "news" shown
- Tap reuses search

**Status**: ✅ PASS

---

#### TC-008: Clear History
**Preconditions**: Search history exists
**Steps**:
1. Open search
2. Tap "Clear All"

**Expected Result**:
- All history items removed
- Empty state shown

**Status**: ✅ PASS

---

### 4. Category Tests

#### TC-009: View Categories
**Preconditions**: Podcasts loaded
**Steps**:
1. Navigate to Categories tab

**Expected Result**:
- Categories display in grid
- Podcast counts accurate
- Category images show

**Status**: ✅ PASS

---

#### TC-010: Filter Categories
**Preconditions**: Multiple categories exist
**Steps**:
1. Open categories tab
2. Type in search bar
3. Enter "tech"

**Expected Result**:
- Only Technology category shows
- Other categories filtered out
- Count remains accurate

**Status**: ✅ PASS

---

#### TC-011: Category Navigation
**Preconditions**: None
**Steps**:
1. Tap Technology category

**Expected Result**:
- Opens category screen
- Shows only tech podcasts
- Podcast count matches

**Status**: ✅ PASS

---

### 5. User Preferences Tests

#### TC-012: Favorite Episode
**Preconditions**: Episode list visible
**Steps**:
1. Tap favorite icon on episode
2. Navigate to Library
3. Check Liked Episodes

**Expected Result**:
- Icon changes to filled
- Episode appears in library
- Persists after app restart

**Status**: ✅ PASS

---

#### TC-013: Follow Podcast
**Preconditions**: On episode list screen
**Steps**:
1. Tap Follow button
2. Navigate to Library
3. Check Followed Podcasts

**Expected Result**:
- Button shows "Following"
- Podcast in library
- Persists locally

**Status**: ✅ PASS

---

#### TC-014: Recently Played
**Preconditions**: None
**Steps**:
1. Play an episode
2. Wait 3 seconds
3. Navigate to Library

**Expected Result**:
- Episode in Recently Played
- Timestamp recorded
- Shows in chronological order

**Status**: ✅ PASS

---

### 6. Player Tests

#### TC-015: Play/Pause
**Preconditions**: Episode selected
**Steps**:
1. Open player
2. Tap play button
3. Tap pause button

**Expected Result**:
- Audio starts playing
- Icon changes to pause
- Artwork pulse animation
- Audio stops on pause

**Status**: ✅ PASS

---

#### TC-016: Progress Bar
**Preconditions**: Audio playing
**Steps**:
1. Start playing episode
2. Drag progress slider
3. Observe playback

**Expected Result**:
- Slider follows playback
- Dragging seeks correctly
- Time labels update

**Status**: ✅ PASS

---

#### TC-017: Skip Forward/Backward
**Preconditions**: Audio playing
**Steps**:
1. Tap +10s button
2. Tap -10s button

**Expected Result**:
- Position jumps 10s forward
- Position jumps 10s backward
- Updates reflect immediately

**Status**: ✅ PASS

---

#### TC-018: Next/Previous Episode
**Preconditions**: Playlist with multiple episodes
**Steps**:
1. Play first episode
2. Tap next button
3. Tap previous button

**Expected Result**:
- Plays next episode
- Returns to previous
- Buttons disabled at boundaries

**Status**: ✅ PASS

---

### 7. UI/Animation Tests

#### TC-019: Hero Animation  
**Preconditions**: None
**Steps**:
1. Tap podcast card
2. Observe transition

**Expected Result**:
- Artwork smoothly transitions
- No jarring jumps
- Animation duration ~400ms

**Status**: ✅ PASS

---

#### TC-020: Scale Animation
**Preconditions**: Player open
**Steps**:
1. Tap play button
2. Watch artwork

**Expected Result**:
- Artwork pulses slightly
- Returns to original size
- Smooth animation

**Status**: ✅ PASS

---

#### TC-021: Header Design
**Preconditions**: On discover screen
**Steps**:
1. Observe top-right icons

**Expected Result**:
- Profile, notification, search in rounded container
- Dark background (0xFF1E2929)
- Proper spacing
- Icons size 20px

**Status**: ✅ PASS

---

### 8. Edge Case Tests

#### TC-022: No Internet Connection
**Preconditions**: Disable network
**Steps**:
1. Try to load podcasts

**Expected Result**:
- Error message displays
- Retry button available
- No app crash

**Status**: ✅ PASS

---

#### TC-023: Empty Search Results
**Preconditions**: None
**Steps**:
1. Search for "xyzabc123"

**Expected Result**:
- Empty state message
- Suggestion to try different term
- No crash

**Status**: ✅ PASS

---

#### TC-024: Session Expiry
**Preconditions**: Expired token
**Steps**:
1. Wait for token expiry (or mock)
2. Try to fetch data

**Expected Result**:
- Redirect to login
- Error message shown
- Token cleared

**Status**: ✅ PASS

---

## Regression Testing

### Areas to Test After Changes

1. **Authentication Changes**
   - Login flow
   - Token persistence
   - Session management

2. **UI Changes**
   - All screens render correctly
   - No overflow errors
   - Animations still work

3. **Feature Changes**
   - Related features still function
   - No side effects
   - Performance maintained

---

## Performance Testing

### Load Time Benchmarks

- **App Launch**: < 2 seconds
- **Podcast List Load**: < 1 second
- **Episode List Load**: < 1 second
- **Search Response**: < 300ms after debounce
- **Player Open**: < 100ms

### Memory Usage

- **Idle**: ~50-70 MB
- **Playing**: ~80-100 MB
- **Browsing**: ~60-80 MB

---

## Accessibility Testing

### Screen Reader Support
- [ ] All buttons have labels
- [ ] Images have descriptions
- [ ] Navigation clear

### Touch Targets
- [ ] Minimum 48x48 points
- [ ] Adequate spacing
- [ ] No overlapping hitboxes

### Color Contrast
- [ ] Text readable on backgrounds
- [ ] WCAG AAA compliance where possible
- [ ] Dark theme consistent

---

## Platform-Specific Tests

### iOS
- [ ] Works on iOS 12+
- [ ] Safe area handling
- [ ] Status bar styling
- [ ] Orientation support

### Android
- [ ] Works on Android 5.0+
- [ ] Navigation bar handling
- [ ] Back button behavior
- [ ] Permission handling

---

## Test Execution Summary

**Total Test Cases**: 24
**Passed**: 24
**Failed**: 0
**Blocked**: 0
**Pass Rate**: 100%

**Last Updated**: November 24, 2025
**Tested By**: Development Team
**Platform**: iOS Simulator (iPhone 16 Plus)
**Flutter Version**: 3.0+

---

## Notes

- All critical paths tested and passing
- No breaking bugs identified
- Performance within acceptable ranges
- Ready for production deployment

---

## Future Test Cases

### Planned Features
- [ ] Offline playback tests
- [ ] Download management tests
- [ ] Playlist creation tests
- [ ] Social sharing tests
- [ ] Push notification tests
