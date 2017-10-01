pragma solidity ^0.4.15;

contract BettingContract {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() { 
	    require(msg.sender == owner);
	    _;
	}
	modifier OracleOnly() {
	    require(msg.sender == oracle);
	    _;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) public {
	    owner = msg.sender;
	    outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) public OwnerOnly() returns (address) {
	    oracle = _oracle;
	    return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) public payable returns (bool) {
	    Bet memory newBet = Bet(_outcome, msg.value, true);
	    bets[msg.sender] = newBet;
	    BetMade(msg.sender);
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) public OracleOnly() {
	    uint Abet = bets[gamblerA].outcome;
	    uint Bbet = bets[gamblerB].outcome;
	    if (Abet == Bbet){
	        winnings[gamblerA] = Abet;
	        winnings[gamblerB] = Bbet;
	    } else if(Abet == _outcome) {
	        winnings[gamblerA] = Abet + Bbet;
	    } else if(Bbet == _outcome) {
	        winnings[gamblerB] = Abet + Bbet;
	    } else {
	        winnings[oracle] = Abet + Bbet;
	    }
	    BetClosed;
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
	    if (withdrawAmount <= winnings[msg.sender]){
	        winnings[msg.sender] -= withdrawAmount;
	        msg.sender.transfer(withdrawAmount);
	        return winnings[msg.sender];
	    }
	    //add in assert
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() public constant returns (uint[]) {
	    return outcomes;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() public constant returns(uint) {
	    return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
	    delete(oracle);
	    delete(owner);
	    delete(gamblerA);
	    delete(gamblerB);
	    delete(outcomes);
	    delete(bets[gamblerA]);
	    delete(bets[gamblerB]);
	}

	/* Fallback function */
	function() public {
		revert();
	}
}


