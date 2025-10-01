# Salesforce LWC Games Collection

This directory contains 4 interactive games built using Salesforce Lightning Web Components (LWC). All games are fully functional and ready to be deployed to your Salesforce org.

## 🎮 Games Overview

### 1. Tic-Tac-Toe Game (`ticTacToe`)
**Location:** `force-app/main/default/lwc/ticTacToe/`

**Features:**
- Interactive 3x3 game board
- Two-player gameplay (X and O)
- Score tracking for both players and draws
- Win detection with visual feedback
- New game and reset score functionality
- Responsive design for mobile and desktop

**How to Play:**
- Click on any empty cell to make your move
- Player X goes first
- Get three in a row (horizontally, vertically, or diagonally) to win
- Use "New Game" to start fresh or "Reset Scores" to clear all scores

### 2. Memory Card Game (`memoryGame`)
**Location:** `force-app/main/default/lwc/memoryGame/`

**Features:**
- Card flipping animation with 3D effects
- Multiple difficulty levels (Easy 4x3, Medium 4x4, Hard 5x4)
- Move counter and timer
- Match tracking system
- Visual feedback for matches
- Responsive grid layout

**How to Play:**
- Click cards to flip them and reveal icons
- Find matching pairs to remove them from the board
- Complete all matches to win
- Try to finish in as few moves as possible
- Use difficulty buttons to change challenge level

### 3. Snake Game (`snakeGame`)
**Location:** `force-app/main/default/lwc/snakeGame/`

**Features:**
- HTML5 Canvas-based gameplay
- Keyboard controls (arrow keys)
- Score tracking with high score persistence
- Multiple speed settings (Slow, Normal, Fast)
- Game pause/resume functionality
- Collision detection for walls and self

**How to Play:**
- Use arrow keys to control the snake
- Eat red food to grow and increase score
- Avoid hitting walls or your own tail
- Adjust speed settings for different challenge levels
- High score is automatically saved

### 4. Number Guessing Game (`numberGuessingGame`)
**Location:** `force-app/main/default/lwc/numberGuessingGame/`

**Features:**
- Multiple difficulty levels (Easy 1-50, Medium 1-100, Hard 1-200)
- Hint system with 4 different hint types
- Guess history with visual feedback
- Attempt tracking and limits
- Smart feedback system (too high/too low)

**How to Play:**
- Choose a difficulty level
- Guess the secret number within the given range
- Use hints to help narrow down possibilities
- Track your progress with the guess history
- Win by guessing correctly within the attempt limit

## 🚀 Deployment Instructions

1. **Deploy to Salesforce:**
   ```bash
   sfdx force:source:deploy -p force-app/main/default/lwc/
   ```

2. **Add to Lightning Pages:**
   - Go to Setup → Lightning App Builder
   - Create a new App Page or Home Page
   - Drag any of the game components to the page
   - Save and activate

3. **Component Names:**
   - `c-tic-tac-toe`
   - `c-memory-game`
   - `c-snake-game`
   - `c-number-guessing-game`

## 🎯 Key Features Across All Games

- **Responsive Design:** All games work on desktop, tablet, and mobile
- **Salesforce Integration:** Built with Lightning Design System
- **Toast Notifications:** User feedback for game events
- **Accessibility:** Keyboard navigation and screen reader support
- **Performance:** Optimized for Salesforce platform
- **No External Dependencies:** Pure LWC implementation

## 🛠️ Technical Details

- **Framework:** Lightning Web Components (LWC)
- **Styling:** Lightning Design System (SLDS) tokens
- **JavaScript:** ES6+ with modern features
- **Testing:** Jest test framework included
- **Metadata:** Proper Salesforce component metadata

## 📱 Mobile Support

All games are fully responsive and optimized for mobile devices:
- Touch-friendly controls
- Adaptive layouts
- Optimized performance
- Mobile-specific styling

## 🎨 Customization

Each game can be easily customized:
- Colors and styling through CSS variables
- Game rules and parameters in JavaScript
- Component properties for different configurations
- Easy to extend with additional features

## 🔧 Development Notes

- All components follow Salesforce best practices
- Proper error handling and user feedback
- Clean, maintainable code structure
- Comprehensive comments and documentation
- Ready for production deployment

Enjoy your new collection of Salesforce games! 🎉
