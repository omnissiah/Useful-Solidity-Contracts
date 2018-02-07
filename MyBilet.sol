pragma solidity ^0.4.11;

contract MyBilet { 
  address public cinemaOwner; // wallet of the cinemaOwner (owner) 
  mapping (address => uint) public customerPaid; // how much each customer -accAddr-has paid. customerPaid[] works but mapping has smaller footprint
  uint public numCustomers;
  uint public seatingLimit;
  // so you can log these events - keeping track of txs
  event Deposit(address _from, uint _amount);  //pars must be indexed for event filter
  event Refund(address _to, uint _amount);

  function MyBilet(uint _seatingLimitInput, address _cinemaOwnerInput) public { // Constructor
    require(_seatingLimitInput>0); // force this value or error
    cinemaOwner = _cinemaOwnerInput;
    seatingLimit = _seatingLimitInput; //seating limit
    numCustomers = 0; // number of viewers
  }

  function changeSeatingLimit(uint _newseatingLimit) public {
    if (msg.sender != cinemaOwner) { return; } 
    seatingLimit = _newseatingLimit;
  }

  function buyTicket() public payable returns (bool success) {  //transaction
    if (numCustomers >= seatingLimit) { return false; }  // Assert, Require, Revert or return?

    customerPaid[msg.sender] = msg.value; //wei, finney, szabo and ether
    numCustomers++;
    Deposit(msg.sender, msg.value);
    return true;
  }

  function refundTicket(address _cucstomerAddr, uint _amount) public {
    //if (msg.sender != cinemaOwner) { return; } 
    require (msg.sender == cinemaOwner); 

    if (customerPaid[_cucstomerAddr] == _amount) {
      address myAddress = this;
      if (myAddress.balance >= _amount) {
        _cucstomerAddr.transfer(_amount); // try to send.  safe against reentrency: THİS İS NOT: x.call.value()()
          //revert; no need to revert - x.transfer(y) same as if (!x.send(y)) throw; 

        customerPaid[_cucstomerAddr] = 0;
        numCustomers--;
        Refund(_cucstomerAddr, _amount);
      }
    }
  }

  function destroy() public{ // so funds not locked in contract forever
    if (msg.sender == cinemaOwner) {
      selfdestruct(cinemaOwner); // send funds to cinemaOwner - EVM level operation. Sends all funds to address
    }
  }
}



/*
    'wei':          '1', wei dai b-money idea
    'kwei':         '1000',
    'ada':          '1000',
    'femtoether':   '1000',
    'mwei':         '1000000',
    'babbage':      '1000000',
    'picoether':    '1000000',
    'gwei':         '1000000000',
    'shannon':      '1000000000',
    'nanoether':    '1000000000',
    'nano':         '1000000000',
    'szabo':        '1000000000000', Nick Szabo smart contract idea owner
    'microether':   '1000000000000',
    'micro':        '1000000000000',
    'finney':       '1000000000000000', hal finney: first tx after satoshi
    'milliether':   '1000000000000000',
    'milli':        '1000000000000000',
    'ether':        '1000000000000000000',
    'kether':       '1000000000000000000000',
    'grand':        '1000000000000000000000',
    'einstein':     '1000000000000000000000',
    'mether':       '1000000000000000000000000',
    'gether':       '1000000000000000000000000000',
    'tether':       '1000000000000000000000000000000'
*/
