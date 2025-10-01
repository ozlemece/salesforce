import { createElement } from 'lwc';
import TicTacToe from 'c/ticTacToe';

describe('c-tic-tac-toe', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays the game board', () => {
        const element = createElement('c-tic-tac-toe', {
            is: TicTacToe
        });
        document.body.appendChild(element);

        // Verify the game board is displayed
        const gameBoard = element.shadowRoot.querySelector('.game-board');
        expect(gameBoard).toBeTruthy();
    });

    it('initializes with empty board', () => {
        const element = createElement('c-tic-tac-toe', {
            is: TicTacToe
        });
        document.body.appendChild(element);

        // Verify initial state
        expect(element.board).toEqual(['', '', '', '', '', '', '', '', '']);
        expect(element.currentPlayer).toBe('X');
        expect(element.gameOver).toBeFalsy();
    });

    it('starts new game correctly', () => {
        const element = createElement('c-tic-tac-toe', {
            is: TicTacToe
        });
        document.body.appendChild(element);

        // Start a new game
        element.startNewGame();

        // Verify game state is reset
        expect(element.board).toEqual(['', '', '', '', '', '', '', '', '']);
        expect(element.currentPlayer).toBe('X');
        expect(element.gameOver).toBeFalsy();
    });
});
