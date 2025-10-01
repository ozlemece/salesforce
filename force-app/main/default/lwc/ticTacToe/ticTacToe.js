import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TicTacToe extends LightningElement {
    @track board = ['', '', '', '', '', '', '', '', ''];
    @track currentPlayer = 'X';
    @track gameStatus = "Player X's turn";
    @track gameOver = false;
    @track playerXScore = 0;
    @track playerOScore = 0;
    @track drawScore = 0;

    // Winning combinations
    winningCombinations = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
        [0, 4, 8], [2, 4, 6] // Diagonals
    ];

    handleCellClick(event) {
        if (this.gameOver) return;

        const cellIndex = parseInt(event.target.dataset.index);
        
        if (this.board[cellIndex] !== '') return; // Cell already occupied

        // Make the move
        this.board[cellIndex] = this.currentPlayer;
        this.board = [...this.board]; // Trigger reactivity

        // Check for win or draw
        if (this.checkWin()) {
            this.gameOver = true;
            this.gameStatus = `Player ${this.currentPlayer} wins!`;
            this.updateScore(this.currentPlayer);
            this.showToast('Congratulations!', `Player ${this.currentPlayer} wins!`, 'success');
        } else if (this.checkDraw()) {
            this.gameOver = true;
            this.gameStatus = "It's a draw!";
            this.drawScore++;
            this.showToast('Game Over', "It's a draw!", 'info');
        } else {
            // Switch players
            this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
            this.gameStatus = `Player ${this.currentPlayer}'s turn`;
        }
    }

    checkWin() {
        return this.winningCombinations.some(combination => {
            const [a, b, c] = combination;
            return this.board[a] && 
                   this.board[a] === this.board[b] && 
                   this.board[a] === this.board[c];
        });
    }

    checkDraw() {
        return this.board.every(cell => cell !== '');
    }

    updateScore(winner) {
        if (winner === 'X') {
            this.playerXScore++;
        } else {
            this.playerOScore++;
        }
    }

    startNewGame() {
        this.board = ['', '', '', '', '', '', '', '', ''];
        this.currentPlayer = 'X';
        this.gameStatus = "Player X's turn";
        this.gameOver = false;
    }

    resetScores() {
        this.playerXScore = 0;
        this.playerOScore = 0;
        this.drawScore = 0;
        this.startNewGame();
        this.showToast('Scores Reset', 'All scores have been reset to zero', 'info');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}
