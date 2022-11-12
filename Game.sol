// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Game {

    constructor(){
        gameOn = false;
    }

    bool gameOn;

    enum Move {Stone, Paper, Rock, Mistake}

    mapping(address => Move) public moves;

    mapping(address => bytes32) public decisions;

    address host;
    
    event hostChange(address _host);

    modifier isHost(){
        require(msg.sender == host);
        _;
    }
    modifier gameStarted(){
        require(gameOn == true);
        _;
    }
    modifier gameEnded(){
        require(gameOn == false);
        _;
    }

    modifier hasMoved(address _player){
        require(decisions[_player] == bytes32(0));
        _;
    }

    function setHost() external gameEnded {
        host = msg.sender;
        emit hostChange(host);
    }

    function start() external isHost {
        gameOn = true;
    }

    function end() external isHost {
        gameOn = false;
    }

    function moveCommit(bytes32 _move) external gameStarted hasMoved(msg.sender) {
        decisions[msg.sender] = _move;
    }

    function moveReveal(int _move, bytes32 _code) external gameEnded{
        bytes32 move = keccak256(abi.encodePacked(_move, _code, msg.sender));
        require(decisions[msg.sender]==move);
        delete decisions[msg.sender];
        if (_move == 0){
            moves[msg.sender] = Move.Stone;
        } else if (_move == 1) {
            moves[msg.sender] = Move.Paper;
        } else if (_move == 2) {
            moves[msg.sender] = Move.Rock;
        } else {
            moves[msg.sender] = Move.Mistake;
        }
    }
}