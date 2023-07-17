// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract voting {
    address public owner;
    uint256 public participationFee;
    uint256 public bettingLimit;
    uint256 public totalBets;
    uint256 public gameBalance;
    uint public noofodd;
    uint public noofeven;
    bool public gameActive;
    uint noOfGames;
    struct Bet {
        address payable player;
        uint256 amount;
        bool isOdd;
    }

    mapping(uint256 => Bet[]) public bets;

    event NewBet(address indexed player, uint256 amount, bool isOdd);
    event GameResult(uint256 number, bool isOdd, uint256 totalWinning);

    constructor(uint256 _participationFee, uint256 _bettingLimit) payable {
        owner = msg.sender;
        participationFee = _participationFee;
        bettingLimit = _bettingLimit;
    }

    function startGame()external{
        require(msg.sender == owner,"You are not the owner");
        gameActive=true;
    }
    function placeBet(bool _isOdd) external payable {
        require(gameActive, "Game is not active");
        require(msg.value == bettingLimit, "Invalid bet amount");


        if(_isOdd){
            noofodd++;
        }
        else{
            noofeven++;
        }
        bets[noOfGames].push(Bet(payable(msg.sender), msg.value, _isOdd));
        noOfGames++;
        totalBets++;
        gameBalance += msg.value;
        emit NewBet(msg.sender, msg.value, _isOdd);
    }

    function generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, totalBets)));
    }

    function resolveGame() external {
        require(msg.sender == owner, "Only the owner can resolve the game");
        require(totalBets > 0, "No bets placed");
        
        uint256 randomNumber = generateRandomNumber();
        bool isOdd = (randomNumber % 2 == 1);
        uint256 totalWinning = 0;
        uint256 balance = address(this).balance;
        uint winningAmount = balance/noofodd;
        for (uint256 i = 0; i < bets[noOfGames].length; i++) {
            Bet storage bet = bets[noOfGames][i];
            if (bet.isOdd == isOdd) {
                totalWinning += winningAmount;
                (bool sent,) = payable(bet.player).call{value: winningAmount}("");
                require(sent, "Failed to send Ether");
            }
        }
        emit GameResult(randomNumber, isOdd, totalWinning);
        totalBets = 0;
        gameBalance = 0;
        gameActive = false;
        noofodd=0;
        noofeven=0;
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        payable(owner).transfer(address(this).balance);
    }
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;

    }
    receive() external payable {}
    fallback() external payable {}
}
