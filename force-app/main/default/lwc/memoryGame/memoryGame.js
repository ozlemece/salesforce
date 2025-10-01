import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MemoryGame extends LightningElement {
    @track cards = [];
    @track flippedCards = [];
    @track moves = 0;
    @track matches = 0;
    @track gameStatus = "Click cards to start!";
    @track gameOver = false;
    @track timeElapsed = 0;
    @track difficulty = 'medium';
    
    gameTimer;
    totalPairs = 8; // Default for medium difficulty

    // Available icons for the cards
    icons = [
        'utility:animal_and_nature',
        'utility:apps',
        'utility:approval',
        'utility:avatar',
        'utility:bookmark',
        'utility:calendar',
        'utility:call',
        'utility:chat',
        'utility:check',
        'utility:clock',
        'utility:close',
        'utility:email',
        'utility:event',
        'utility:file',
        'utility:home',
        'utility:like',
        'utility:link',
        'utility:location',
        'utility:phone_portrait',
        'utility:photo',
        'utility:search',
        'utility:settings',
        'utility:star',
        'utility:success',
        'utility:task',
        'utility:user',
        'utility:video',
        'utility:world'
    ];

    connectedCallback() {
        this.startNewGame();
    }

    disconnectedCallback() {
        if (this.gameTimer) {
            clearInterval(this.gameTimer);
        }
    }

    get formattedTime() {
        const minutes = Math.floor(this.timeElapsed / 60);
        const seconds = this.timeElapsed % 60;
        return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }

    startNewGame() {
        this.initializeGame();
        this.createCards();
        this.shuffleCards();
        this.moves = 0;
        this.matches = 0;
        this.timeElapsed = 0;
        this.gameOver = false;
        this.gameStatus = "Click cards to start!";
        this.startTimer();
    }

    initializeGame() {
        if (this.gameTimer) {
            clearInterval(this.gameTimer);
        }
    }

    createCards() {
        const cardPairs = this.totalPairs;
        const selectedIcons = this.icons.slice(0, cardPairs);
        this.cards = [];
        
        // Create pairs
        for (let i = 0; i < cardPairs; i++) {
            this.cards.push({
                id: `card-${i}-1`,
                icon: selectedIcons[i],
                isFlipped: false,
                isMatched: false
            });
            this.cards.push({
                id: `card-${i}-2`,
                icon: selectedIcons[i],
                isFlipped: false,
                isMatched: false
            });
        }
    }

    shuffleCards() {
        for (let i = this.cards.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
        }
    }

    handleCardClick(event) {
        if (this.gameOver) return;

        const cardId = event.currentTarget.dataset.cardId;
        const card = this.cards.find(c => c.id === cardId);
        
        if (!card || card.isFlipped || card.isMatched) return;

        // Flip the card
        card.isFlipped = true;
        this.cards = [...this.cards];

        // Add to flipped cards
        this.flippedCards.push(card);

        // Check for match when 2 cards are flipped
        if (this.flippedCards.length === 2) {
            this.moves++;
            this.checkForMatch();
        }

        // Update game status
        this.updateGameStatus();
    }

    checkForMatch() {
        const [card1, card2] = this.flippedCards;
        
        if (card1.icon === card2.icon) {
            // Match found
            card1.isMatched = true;
            card2.isMatched = true;
            this.matches++;
            
            this.flippedCards = [];
            this.cards = [...this.cards];
            
            if (this.matches === this.totalPairs) {
                this.gameOver = true;
                this.gameStatus = "Congratulations! You won!";
                this.stopTimer();
                this.showToast('Game Complete!', `You completed the game in ${this.moves} moves and ${this.formattedTime}!`, 'success');
            }
        } else {
            // No match, flip cards back after delay
            setTimeout(() => {
                card1.isFlipped = false;
                card2.isFlipped = false;
                this.flippedCards = [];
                this.cards = [...this.cards];
            }, 1000);
        }
    }

    updateGameStatus() {
        if (this.gameOver) return;
        
        if (this.flippedCards.length === 0) {
            this.gameStatus = "Click cards to find matches!";
        } else if (this.flippedCards.length === 1) {
            this.gameStatus = "Click another card to match!";
        } else {
            this.gameStatus = "Checking for match...";
        }
    }

    setDifficulty(event) {
        const difficulty = event.currentTarget.dataset.difficulty;
        this.difficulty = difficulty;
        
        switch (difficulty) {
            case 'easy':
                this.totalPairs = 6; // 4x3 grid
                break;
            case 'medium':
                this.totalPairs = 8; // 4x4 grid
                break;
            case 'hard':
                this.totalPairs = 10; // 5x4 grid
                break;
        }
        
        this.startNewGame();
        this.showToast('Difficulty Changed', `Switched to ${difficulty} mode`, 'info');
    }

    startTimer() {
        this.gameTimer = setInterval(() => {
            this.timeElapsed++;
        }, 1000);
    }

    stopTimer() {
        if (this.gameTimer) {
            clearInterval(this.gameTimer);
            this.gameTimer = null;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
