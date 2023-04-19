pragma solidity ^0.8.0;

contract GameWager {
    address public player1;
    address public player2;
    uint public wagerAmount;
    bool public player1Result;
    bool public player2Result;
    bool public gameEnded;
    bool public player2Joined; // Added variable to track if player2 has joined

    // Events
    event GameStarted(address indexed _player1, address indexed _player2, uint _wagerAmount);
    event GameEnded(address indexed _winner, uint _wagerAmount);
    
    constructor(address _player2, uint _wagerAmount) payable {
        require(msg.value == _wagerAmount, "Player1 must send the wager amount.");
        player1 = msg.sender;
        player2 = _player2;
        wagerAmount = _wagerAmount;
        gameEnded = false;
        player2Joined = false; // Initialize player2Joined to false
        emit GameStarted(player1, player2, wagerAmount);
    }
    
    function player2Join() external payable {
        require(msg.sender == player2, "Only player2 can join the game.");
        require(msg.value == wagerAmount, "Player2 must send the wager amount.");
        player2Joined = true; // Set player2Joined to true when player2 joins
    }
    
    function submitResult(bool _playerResult) external {
        require(player2Joined, "Player2 must join before submitting results."); // Added requirement
        require(msg.sender == player1 || msg.sender == player2, "Only players can submit the result.");
        require(!gameEnded, "Game has already ended.");
        
        if (msg.sender == player1) {
            player1Result = _playerResult;
        } else {
            player2Result = _playerResult;
        }

        // If both players have submitted their results, determine the winner and payout
        if (player1Result != player2Result) {
            gameEnded = true;
            address winner = player1Result ? player1 : player2;
            uint payout = address(this).balance;
            payable(winner).transfer(payout);
            emit GameEnded(winner, payout);
        }
    }

    // This function allows players to withdraw their wager in case of a tie
    function withdraw() external {
        require(gameEnded, "Game has not ended yet.");
        require(player1Result == player2Result, "There is a winner in the game.");
        require(msg.sender == player1 || msg.sender == player2, "Only players can withdraw.");

        uint refund = wagerAmount;
        if (msg.sender == player1) {
            payable(player1).transfer(refund);
        } else {
            payable(player2).transfer(refund);
        }
    }
}
