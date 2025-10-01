import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SnakeGame extends LightningElement {
    @track score = 0;
    @track highScore = 0;
    @track gameStatus = "Press Start to begin!";
    @track gameRunning = false;
    @track gameSpeed = "Normal";
    
    canvas;
    ctx;
    gameLoop;
    
    // Game variables
    gridSize = 20;
    tileCount = 20;
    snake = [{ x: 10, y: 10 }];
    food = { x: 15, y: 15 };
    dx = 0;
    dy = 0;
    speed = 150; // milliseconds

    connectedCallback() {
        this.initializeCanvas();
        this.setupKeyboardControls();
        this.loadHighScore();
    }

    disconnectedCallback() {
        if (this.gameLoop) {
            clearInterval(this.gameLoop);
        }
        this.removeKeyboardControls();
    }

    initializeCanvas() {
        this.canvas = this.template.querySelector('[data-canvas="snake-canvas"]');
        this.ctx = this.canvas.getContext('2d');
        this.drawGame();
    }

    setupKeyboardControls() {
        this.handleKeyPress = this.handleKeyPress.bind(this);
        document.addEventListener('keydown', this.handleKeyPress);
    }

    removeKeyboardControls() {
        document.removeEventListener('keydown', this.handleKeyPress);
    }

    handleKeyPress(event) {
        if (!this.gameRunning) return;

        const key = event.key;
        const goingUp = this.dy === -1;
        const goingDown = this.dy === 1;
        const goingRight = this.dx === 1;
        const goingLeft = this.dx === -1;

        switch (key) {
            case 'ArrowUp':
                if (!goingDown) {
                    this.dx = 0;
                    this.dy = -1;
                }
                break;
            case 'ArrowDown':
                if (!goingUp) {
                    this.dx = 0;
                    this.dy = 1;
                }
                break;
            case 'ArrowLeft':
                if (!goingRight) {
                    this.dx = -1;
                    this.dy = 0;
                }
                break;
            case 'ArrowRight':
                if (!goingLeft) {
                    this.dx = 1;
                    this.dy = 0;
                }
                break;
        }
    }

    startGame() {
        if (this.gameRunning) return;
        
        this.gameRunning = true;
        this.gameStatus = "Game Running - Use arrow keys to control!";
        this.dx = 1;
        this.dy = 0;
        
        this.gameLoop = setInterval(() => {
            this.updateGame();
        }, this.speed);
    }

    pauseGame() {
        if (!this.gameRunning) return;
        
        this.gameRunning = false;
        this.gameStatus = "Game Paused - Press Start to resume!";
        clearInterval(this.gameLoop);
    }

    resetGame() {
        this.gameRunning = false;
        this.gameStatus = "Press Start to begin!";
        this.score = 0;
        this.snake = [{ x: 10, y: 10 }];
        this.food = this.generateFood();
        this.dx = 0;
        this.dy = 0;
        
        if (this.gameLoop) {
            clearInterval(this.gameLoop);
        }
        
        this.drawGame();
    }

    updateGame() {
        if (!this.gameRunning) return;

        const head = { x: this.snake[0].x + this.dx, y: this.snake[0].y + this.dy };

        // Check wall collision
        if (head.x < 0 || head.x >= this.tileCount || head.y < 0 || head.y >= this.tileCount) {
            this.gameOver();
            return;
        }

        // Check self collision
        for (let segment of this.snake) {
            if (head.x === segment.x && head.y === segment.y) {
                this.gameOver();
                return;
            }
        }

        this.snake.unshift(head);

        // Check food collision
        if (head.x === this.food.x && head.y === this.food.y) {
            this.score += 10;
            this.food = this.generateFood();
            this.updateHighScore();
        } else {
            this.snake.pop();
        }

        this.drawGame();
    }

    generateFood() {
        let newFood;
        do {
            newFood = {
                x: Math.floor(Math.random() * this.tileCount),
                y: Math.floor(Math.random() * this.tileCount)
            };
        } while (this.snake.some(segment => segment.x === newFood.x && segment.y === newFood.y));
        
        return newFood;
    }

    drawGame() {
        // Clear canvas
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

        // Draw snake
        this.ctx.fillStyle = '#0f0';
        for (let segment of this.snake) {
            this.ctx.fillRect(segment.x * this.gridSize, segment.y * this.gridSize, this.gridSize - 2, this.gridSize - 2);
        }

        // Draw food
        this.ctx.fillStyle = '#f00';
        this.ctx.fillRect(this.food.x * this.gridSize, this.food.y * this.gridSize, this.gridSize - 2, this.gridSize - 2);

        // Draw grid
        this.ctx.strokeStyle = '#333';
        this.ctx.lineWidth = 1;
        for (let i = 0; i <= this.tileCount; i++) {
            this.ctx.beginPath();
            this.ctx.moveTo(i * this.gridSize, 0);
            this.ctx.lineTo(i * this.gridSize, this.canvas.height);
            this.ctx.stroke();
            
            this.ctx.beginPath();
            this.ctx.moveTo(0, i * this.gridSize);
            this.ctx.lineTo(this.canvas.width, i * this.gridSize);
            this.ctx.stroke();
        }
    }

    gameOver() {
        this.gameRunning = false;
        this.gameStatus = "Game Over! Press Reset to play again.";
        clearInterval(this.gameLoop);
        this.showToast('Game Over!', `Final Score: ${this.score}`, 'error');
    }

    setSpeed(event) {
        const speed = event.currentTarget.dataset.speed;
        
        switch (speed) {
            case 'slow':
                this.speed = 200;
                this.gameSpeed = "Slow";
                break;
            case 'normal':
                this.speed = 150;
                this.gameSpeed = "Normal";
                break;
            case 'fast':
                this.speed = 100;
                this.gameSpeed = "Fast";
                break;
        }

        // Restart game loop with new speed if game is running
        if (this.gameRunning) {
            clearInterval(this.gameLoop);
            this.gameLoop = setInterval(() => {
                this.updateGame();
            }, this.speed);
        }

        this.showToast('Speed Changed', `Game speed set to ${this.gameSpeed}`, 'info');
    }

    updateHighScore() {
        if (this.score > this.highScore) {
            this.highScore = this.score;
            this.saveHighScore();
        }
    }

    saveHighScore() {
        localStorage.setItem('snakeGameHighScore', this.highScore.toString());
    }

    loadHighScore() {
        const saved = localStorage.getItem('snakeGameHighScore');
        if (saved) {
            this.highScore = parseInt(saved, 10);
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
