// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bets {

    constructor() {
        gameOn = false;
        registered = 0;
        judgeNumber = 0;
        decisionsFinal = 0;
        votes = 0;
    }

    uint public money;

    uint public players;

    uint public registered;

    bool public gameOn;

    string public condition;

    uint private startTime;

    uint public duration;

    uint private votes;

    uint decisionsFinal;

    address public host;

    struct inGame{
        bool choice;
        int enteredGame;
    }

    uint public moneyFinal;


    uint public judgeNumber;

    mapping(address => inGame) public bets;

    mapping(address => bytes32) private decisions;

    mapping(address => bool) public decisionsOpened;

    mapping(address => bool) public judges;

    address[] private judgeAddress;

    address[] private playersAddress;

    modifier gameStarted(){
        require(gameOn == true, "Game has ended");
        _;
    }

    modifier gameEnded(){
        require(gameOn == false, "Game has started");
        _;
    }

    modifier isHost(){
        require(msg.sender == host);
        _;
    }

    modifier notFull(){
        require(registered < players, "There are too many players");
        _;
    }

    modifier enoughToStart(){
        require(registered == players, "Not enough players");
        _;
    }

    modifier enoughToEnter(){
        require(msg.value >= money, "Not enough money to enter the contest");
        _;
    }

    modifier notPresent(){
        require(bets[msg.sender].enteredGame == 0, "The address has already done his bet");
        _;
    }

    modifier EnoughJudges(){
        require(judgeNumber == uint(3), "There are not enough judges");
        _;
    }

    modifier notEnoughJudges(){
        require(judgeNumber < uint(3), "There are enough judges");
        _;
    }

    modifier uniqueJudge(address jd){
        require(judges[jd] == false, "This judge has already entered");
        _;
    }

    modifier hasDecided(address voter){
        require(decisions[voter] == bytes32(0));
        _;
    }

    modifier timeHasCome(){
        require(startTime + duration * uint(81600) < block.timestamp);
        _;
    }

    modifier notAJudge(){
        require(judges[msg.sender] == false, "A judge cannot bet");
        _;
    }

    function setHost(string memory cond, uint plr, uint dur) payable external gameEnded {
        host = msg.sender;
        money = msg.value;
        condition = cond;
        duration = dur;
        players = plr;
        inGame memory g = inGame(true, 1);
        bets[host] = g;
        playersAddress.push(host);
        registered++;
    }

    function setJudge() external gameEnded notEnoughJudges uniqueJudge(msg.sender){
        judges[msg.sender] = true;
        judgeAddress.push(msg.sender);
        judgeNumber+=1;
    }

    function register(bool choice) payable external gameEnded notFull EnoughJudges notPresent enoughToEnter notAJudge{
        uint refund = msg.value - money;
        if (refund > 0){
            payable(msg.sender).transfer(refund);
        }
        inGame memory g = inGame(choice, 1);
        bets[msg.sender] = g;
        registered++;
        playersAddress.push(msg.sender);
    }

    function start() external gameEnded isHost enoughToStart EnoughJudges{
        gameOn = true;
        startTime = block.timestamp;
        moneyFinal = money * players;
    }

    function moveCommit(bytes32 _vote) external gameStarted hasDecided(msg.sender) timeHasCome {
        decisions[msg.sender] = _vote;
        votes++;
        if (votes == 3){
            gameOn = false;
        }
        
    }

    function moveReveal(bool _vote, bytes32 _code) external gameEnded{
        bytes32 vote = keccak256(abi.encodePacked(_vote, _code, msg.sender));
        require(decisions[msg.sender]==vote);
        delete decisions[msg.sender];
        decisionsOpened[msg.sender] = _vote;
        decisionsFinal += 1;
        if (decisionsFinal == 3){
            checkResult();
        }
    }

    function checkResult() private{
        uint temp = 0;
        for (uint i = 0; i < 3; i++) {
            if (decisionsOpened[judgeAddress[i]] == true){
                temp++;
            }
        }
        if (temp > 1){
            sendMoney(true);
        } else {
            sendMoney(false);
        }
    }

    function sendMoney(bool winning) private{
        uint mn = moneyFinal * 7 / 100;
        for (uint i = 0; i < 3; i++){
            payable(judgeAddress[i]).transfer(mn);
        }
        uint win = 0;
        moneyFinal -= mn * 4;
        for (uint i = 0; i < players; i++){
            if(bets[playersAddress[i]].choice == winning){
                win++;
            }
        }
        for (uint i = 0; i < players; i++){
            if(bets[playersAddress[i]].choice == winning){
                payable(playersAddress[i]).transfer(moneyFinal / win);
            }
        }
    }
}