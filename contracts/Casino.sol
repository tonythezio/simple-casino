// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Casino {

    address public owner;

    uint256 public minimumBet = 0.5 ether;
    uint256 public numberOfBets;
    uint256 public constant maxNumberOfBets = 10;
    uint256 public totalAmountStaked;

    address[] public players;

    // Each Number has an Array of Players who selected that Number
    mapping(uint => address[]) numberBetPlayers;

    // The Number that each Player has placed Bet
    mapping(address => uint) playerBetsNumber;

   // Modifier to only allow the execution of selectWinner() when the Bets are Completed
    modifier onBetEnd() {
        if(numberOfBets >= maxNumberOfBets) _;
    }

    // List down all the Players in the current Round
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Delete all Players for each Number Array
    function resetData() internal {
        for(uint i = 1; i <= 10; i++) {
            delete numberBetPlayers[i]; // Delete Array values from Players in each Number Array
        }

        numberOfBets = 0; // total Number of Bets Placed in the current Bet Round
        totalAmountStaked = 0; // Total Amount Staked in the current Bet Round
    }
    
    // Place Bet for a Number between 1 and 10 along with Bet Amount
    function placeBet(uint256 _betNumber) public payable {
        assert(_betNumber >= 1 && _betNumber <= 10); // Bet Number must be between 1 and 10 including same
        assert(msg.value >= minimumBet); // Placing Bet Amount must be greater than or equal to Minimum Bet Amount ie; 0.5 ether
        assert(numberOfBets < maxNumberOfBets); // Number of Bets must be of the pre defined count

         // Set the Number Bet for that Player
        playerBetsNumber[msg.sender] = _betNumber;

        // The player msg.sender has placed Bet for that Number
        numberBetPlayers[_betNumber].push(msg.sender);


        numberOfBets++; // Increament total number of Bets in the current Round
        totalAmountStaked += msg.value; // Add current Bet Amount to Total Amount Staked in the current Round

        if(numberOfBets >= maxNumberOfBets) selectWinner(); // Execute selectWinner() when it reaches maximum Number of Bets of current round
    }

    // Generate a Randum Number
    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    // Select Winner and Transfer Prize Amount
    function selectWinner() public onBetEnd {
        uint256 winningNumber = getRandomNumber() % 10; // Winning Number of the current round

        // Splits Prize among all the Winners
        uint256 winnerPrize = totalAmountStaked / numberBetPlayers[winningNumber].length;

        //uint256 deservedPercentage;
        //uint256 deservedPrize;

        // Loop through all the Winners and send Prize share to each
        for(uint256 i = 0; i < numberBetPlayers[winningNumber].length; i++) {
            payable (numberBetPlayers[winningNumber][i]).transfer(winnerPrize);
        }

        resetData(); // Reset all Array values back to 0
    }

}
