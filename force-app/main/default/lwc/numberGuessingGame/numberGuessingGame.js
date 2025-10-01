import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NumberGuessingGame extends LightningElement {
    @track gameStatus = "Choose difficulty and start a new game!";
    @track gameActive = false;
    @track attempts = 0;
    @track maxAttempts = 10;
    @track userGuess = '';
    @track guessHistory = [];
    @track difficulty = 'Medium';
    @track maxNumber = 100;
    @track secretNumber = 0;
    @track showHints = false;
    @track availableHints = [];
    @track hintIdCounter = 0;

    get isGuessDisabled() {
        return !this.userGuess || this.userGuess < 1 || this.userGuess > this.maxNumber;
    }

    get hasGuesses() {
        return this.guessHistory.length > 0;
    }

    startNewGame() {
        this.secretNumber = Math.floor(Math.random() * this.maxNumber) + 1;
        this.gameActive = true;
        this.attempts = 0;
        this.userGuess = '';
        this.guessHistory = [];
        this.gameStatus = `Guess a number between 1 and ${this.maxNumber}!`;
        this.initializeHints();
        this.showHints = true;
    }

    setDifficulty(event) {
        const difficulty = event.currentTarget.dataset.difficulty;
        
        switch (difficulty) {
            case 'easy':
                this.difficulty = 'Easy';
                this.maxNumber = 50;
                this.maxAttempts = 8;
                break;
            case 'medium':
                this.difficulty = 'Medium';
                this.maxNumber = 100;
                this.maxAttempts = 10;
                break;
            case 'hard':
                this.difficulty = 'Hard';
                this.maxNumber = 200;
                this.maxAttempts = 12;
                break;
        }
        
        this.startNewGame();
        this.showToast('Difficulty Changed', `Switched to ${this.difficulty} mode (1-${this.maxNumber})`, 'info');
    }

    handleGuessChange(event) {
        this.userGuess = event.target.value;
    }

    makeGuess() {
        if (!this.gameActive || this.isGuessDisabled) return;

        const guess = parseInt(this.userGuess, 10);
        this.attempts++;
        
        let feedback = '';
        let result = '';
        
        if (guess === this.secretNumber) {
            feedback = 'Correct! 🎉';
            result = 'correct';
            this.gameActive = false;
            this.gameStatus = `Congratulations! You guessed it in ${this.attempts} attempts!`;
            this.showToast('You Win!', `You guessed the number in ${this.attempts} attempts!`, 'success');
        } else if (this.attempts >= this.maxAttempts) {
            feedback = 'Game Over! No more attempts.';
            result = 'game-over';
            this.gameActive = false;
            this.gameStatus = `Game Over! The secret number was ${this.secretNumber}.`;
            this.showToast('Game Over', `The secret number was ${this.secretNumber}. Better luck next time!`, 'error');
        } else {
            if (guess < this.secretNumber) {
                feedback = 'Too low! Try a higher number.';
                result = 'too-low';
            } else {
                feedback = 'Too high! Try a lower number.';
                result = 'too-high';
            }
            this.gameStatus = `Attempt ${this.attempts}/${this.maxAttempts}. ${feedback}`;
        }

        // Add to history
        this.guessHistory = [...this.guessHistory, {
            id: `guess-${Date.now()}`,
            value: guess,
            feedback: feedback,
            result: result,
            attemptNumber: this.attempts
        }];

        this.userGuess = '';
    }

    initializeHints() {
        this.availableHints = [
            {
                id: 'hint-even-odd',
                text: 'Is it even or odd?',
                used: false,
                type: 'even-odd'
            },
            {
                id: 'hint-range',
                text: 'Is it in the first half?',
                used: false,
                type: 'range'
            },
            {
                id: 'hint-divisible',
                text: 'Is it divisible by 5?',
                used: false,
                type: 'divisible'
            },
            {
                id: 'hint-prime',
                text: 'Is it a prime number?',
                used: false,
                type: 'prime'
            }
        ];
        this.hintIdCounter = 0;
    }

    useHint(event) {
        const hintId = event.currentTarget.dataset.hintId;
        const hint = this.availableHints.find(h => h.id === hintId);
        
        if (!hint || hint.used) return;

        hint.used = true;
        this.availableHints = [...this.availableHints];

        let hintResult = '';
        
        switch (hint.type) {
            case 'even-odd':
                hintResult = this.secretNumber % 2 === 0 ? 'The number is even.' : 'The number is odd.';
                break;
            case 'range':
                hintResult = this.secretNumber <= this.maxNumber / 2 ? 
                    'The number is in the first half (1-' + Math.floor(this.maxNumber / 2) + ').' : 
                    'The number is in the second half (' + (Math.floor(this.maxNumber / 2) + 1) + '-' + this.maxNumber + ').';
                break;
            case 'divisible':
                hintResult = this.secretNumber % 5 === 0 ? 'The number is divisible by 5.' : 'The number is not divisible by 5.';
                break;
            case 'prime':
                hintResult = this.isPrime(this.secretNumber) ? 'The number is prime.' : 'The number is not prime.';
                break;
        }

        this.showToast('Hint Used', hintResult, 'info');
    }

    isPrime(num) {
        if (num < 2) return false;
        if (num === 2) return true;
        if (num % 2 === 0) return false;
        
        for (let i = 3; i <= Math.sqrt(num); i += 2) {
            if (num % i === 0) return false;
        }
        return true;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
