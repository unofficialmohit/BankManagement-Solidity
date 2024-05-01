//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

contract bank {
    address owner;

    constructor() {
        owner = msg.sender;
        createAccount();
    }

    uint256 loanFund = 0; // it is used to store Amount of loan bank can provide
    uint256 userIdCount = 1; //this will keep track of userId and number of bank accounts in contract
    enum LoanType {
        home,
        car,
        education
    }
    //userData is userdefined struct datatype
    struct userData {
        uint256 userId; //user's id
        uint256 balances; //user's balance
    }

    //loanBank struct will handle all loan functionality
    struct loanBank {
        uint256 loanAmount;
        uint256 emiCount;
        uint256 emiCost;
        bool isLoanPending;
        uint256 loanTimestamp;
    }

    //userBase will store data of users
    mapping(address => userData) userBase;
    mapping(address => loanBank[3]) loanBase;
    uint256 totalCount = 0;

    //payable function will be called whenever ether will be send to contract
    receive() external payable {
        require(msg.value > 0, "Invalid Amount Entered");
    }

    //display loan fund
    function getLoanFund() public view returns (uint256) {
        return loanFund;
    }

    //get owner address
        function getOwner() public view returns(address){
        return( owner);
    }


    function accountExists() public view returns(bool){
        return userBase[msg.sender].userId!=0;
    }

    //this modifer will check whether user exists or not
    modifier userExist() {
        require(userBase[msg.sender].userId != 0, "Account Doesn't Exist");
        _;
    }

    // this function will add ether to contract in loanFund
    function addLoanFund() public payable {
        require(msg.sender == owner, "Only owner can add Fund");
        payable(address(this)).transfer(msg.value);
        loanFund += msg.value;
    }

    //this function will create an new account of user according to his address
    function createAccount() public returns (string memory) {
        require(userBase[msg.sender].userId == 0, "ACCOUNT ALREADY EXISTS");

        totalCount++;
        userData memory userdata;
        userdata.userId = userIdCount;
        userIdCount++;
        userBase[msg.sender] = userdata;
        return "Account Created Successfully";
    }

    //this will display count of accounts in contract
    function totalAccounts() public view returns (uint256) {
        return totalCount;
    }

    //this function will transfer ether from user account to contract
    function deposit() public payable userExist {
        userBase[msg.sender].balances += msg.value;
        payable(address(this)).transfer(msg.value);
    }

    //this function will display user's current balance
    function getBalance() public view userExist returns (uint256) {
        return userBase[msg.sender].balances;
    }

    //this function will transfer ether from  contract to useraccount
    function withdraw(uint256 money) public userExist {
        require(
            userBase[msg.sender].balances >= money,
            "Your Account Don't Have Enough Funds"
        );
        userBase[msg.sender].balances -= money;
        payable(msg.sender).transfer(money);
    }

    //this function will transfer ether from current user account to any other user account
    function transferMoney(uint256 amount, address username) public userExist {
        require(
            amount <= userBase[msg.sender].balances,
            "YOUR ACCOUNT DONT HAVE ENOUGHT FUNDS"
        );
        require(userBase[username].userId > 0, "USER DOESNT EXIST");
        userBase[msg.sender].balances -= amount;
        userBase[username].balances += amount;
    }

    //this function will add loan amount to user's bank account on contract
    function getHomeLoan(uint256 amount, uint256 month) public userExist {
        require(
            !loanBase[msg.sender][uint256(LoanType.home)].isLoanPending,
            "Your Previous Loan is Still Pending"
        );
        require(amount < loanFund, "Loan Processing Unsuccessful");
        require(amount > 1, "INVALID AMOUNT ENTERED");
        require(month > 1, "INVALID MONTH PERIOD ENTERED");
        loanBank memory temp = loanBase[msg.sender][uint256(LoanType.home)];
        uint256 interest = 0;
        userBase[msg.sender].balances += amount;
        loanFund -= amount;
        interest += 8; //home loan

        if (month <= 3) {
            interest += 10;
        } else if (month <= 6) {
            interest += 12;
        } else if (month <= 12) {
            interest += 15;
        } else {
            interest += 20;
        }
        temp.loanAmount =
            amount +
            uint256(((amount * interest * month) / 100) / 12);
        temp.emiCost = temp.loanAmount / month;
        temp.emiCount = month;
        temp.isLoanPending = true;
        loanBase[msg.sender][uint256(LoanType.home)] = temp;
    }

    function getCarLoan(uint256 amount, uint256 month) public userExist {
        require(
            !loanBase[msg.sender][uint256(LoanType.car)].isLoanPending,
            "Your Previous Loan is Still Pending"
        );
        require(amount < loanFund, "Loan Processing Unsuccessful");
        require(amount > 1, "INVALID AMOUNT ENTERED");
        require(month > 1, "INVALID MONTH PERIOD ENTERED");
        uint256 interest = 0;
        loanBank memory temp = loanBase[msg.sender][uint256(LoanType.car)];
        userBase[msg.sender].balances += amount;
        loanFund -= amount;
        interest += 5; // car loan
        if (month <= 3) {
            interest += 10;
        } else if (month <= 6) {
            interest += 12;
        } else if (month <= 12) {
            interest += 15;
        } else {
            interest += 20;
        }

        temp.loanAmount =
            amount +
            uint256(((amount * interest * month) / 100) / 12);
        temp.emiCost = temp.loanAmount / month;
        temp.emiCount = month;
        temp.isLoanPending = true;
        loanBase[msg.sender][uint256(LoanType.car)] = temp;
    }

    function getEducationLoan(uint256 amount, uint256 month) public userExist {
        require(
            !loanBase[msg.sender][uint256(LoanType.education)].isLoanPending,
            "Your Previous Loan is Still Pending"
        );
        require(amount < loanFund, "Loan Processing Unsuccessful");
        require(amount > 1, "INVALID AMOUNT ENTERED");
        require(month > 1, "INVALID MONTH PERIOD ENTERED");
        loanBank memory temp = loanBase[msg.sender][
            uint256(LoanType.education)
        ];
        uint256 interest = 0;
        userBase[msg.sender].balances += amount;
        loanFund -= amount;
        interest += 2; //education loan
        if (month <= 3) {
            interest += 10;
        } else if (month <= 6) {
            interest += 12;
        } else if (month <= 12) {
            interest += 15;
        } else {
            interest += 20;
        }
        temp.loanAmount =
            amount +
            uint256(((amount * interest * month) / 100) / 12);
        temp.emiCost = temp.loanAmount / month;
        temp.emiCount = month;
        temp.isLoanPending = true;
        loanBase[msg.sender][uint256(LoanType.education)] = temp;
    }

    //this function will reduce ether from user account and add it back to loanFund account
    function payHomeEmi() public userExist {
        if (loanBase[msg.sender][uint256(LoanType.home)].loanTimestamp == 0) {
            loanBase[msg.sender][uint256(LoanType.home)].loanTimestamp = block
                .timestamp;
        } else {
            require(
                (block.timestamp -
                    loanBase[msg.sender][uint256(LoanType.home)]
                        .loanTimestamp) > 60,
                "Please wait for sometime to pay again"
            );
        }

        require(
            loanBase[msg.sender][uint256(LoanType.home)].emiCount > 0,
            "YOU DONT HAVE ANY LOAN PENDING"
        );
        require(
            userBase[msg.sender].balances >=
                loanBase[msg.sender][uint256(LoanType.home)].emiCost,
            "YOUR ACCOUNT DONT HAVE ENOUGH FUNDS TO PAY THIS EMI"
        );
        loanBank memory temp = loanBase[msg.sender][uint256(LoanType.home)];
        temp.loanTimestamp = block.timestamp;
        temp.emiCount--;
        temp.loanAmount -= temp.emiCost;
        userBase[msg.sender].balances -= temp.emiCost;
        loanFund += temp.emiCost;
        if (temp.emiCount == 0) {
            temp.isLoanPending = false;
            temp.loanAmount = 0;
            temp.emiCost = 0;
        }
        loanBase[msg.sender][uint256(LoanType.home)] = temp;
    }

    function payCarEmi() public userExist {
        if (loanBase[msg.sender][uint256(LoanType.car)].loanTimestamp == 0) {
            loanBase[msg.sender][uint256(LoanType.car)].loanTimestamp = block
                .timestamp;
        } else {
            require(
                (block.timestamp -
                    loanBase[msg.sender][uint256(LoanType.car)].loanTimestamp) >
                    10,
                "Please wait for sometime to pay again"
            );
        }
        require(
            loanBase[msg.sender][uint256(LoanType.car)].emiCount > 0,
            "YOU DONT HAVE ANY LOAN PENDING"
        );
        require(
            userBase[msg.sender].balances >=
                loanBase[msg.sender][uint256(LoanType.car)].emiCost,
            "YOUR ACCOUNT DONT HAVE ENOUGH FUNDS TO PAY THIS EMI"
        );
        loanBank memory temp = loanBase[msg.sender][uint256(LoanType.car)];
        temp.loanTimestamp = block.timestamp;
        temp.emiCount--;
        temp.loanAmount -= temp.emiCost;
        userBase[msg.sender].balances -= temp.emiCost;
        loanFund += temp.emiCost;
        if (temp.emiCount == 0) {
            temp.isLoanPending = false;
            temp.loanAmount = 0;
            temp.emiCost = 0;
        }
        loanBase[msg.sender][uint256(LoanType.car)] = temp;
    }

    function payEducationEmi() public userExist {
        if (
            loanBase[msg.sender][uint256(LoanType.education)].loanTimestamp == 0
        ) {
            loanBase[msg.sender][uint256(LoanType.education)]
                .loanTimestamp = block.timestamp;
        } else {
            require(
                (block.timestamp -
                    loanBase[msg.sender][uint256(LoanType.education)]
                        .loanTimestamp) > 60,
                "Please wait for sometime to pay again"
            );
        }
        require(
            loanBase[msg.sender][uint256(LoanType.education)].emiCount > 0,
            "YOU DONT HAVE ANY LOAN PENDING"
        );
        require(
            userBase[msg.sender].balances >=
                loanBase[msg.sender][uint256(LoanType.education)].emiCost,
            "YOUR ACCOUNT DONT HAVE ENOUGH FUNDS TO PAY THIS EMI"
        );
        loanBank memory temp = loanBase[msg.sender][
            uint256(LoanType.education)
        ];
        temp.loanTimestamp = block.timestamp;
        temp.emiCount--;
        temp.loanAmount -= temp.emiCost;
        userBase[msg.sender].balances -= temp.emiCost;
        loanFund += temp.emiCost;
        if (temp.emiCount == 0) {
            temp.isLoanPending = false;
            temp.loanAmount = 0;
            temp.emiCost = 0;
        }
        loanBase[msg.sender][uint256(LoanType.education)] = temp;
    }

    //this will display details of the current user
    function displayUserDetails() public view userExist  returns ( uint256 UserID, uint256 Accountbalance,
            uint256 HomeLoan,uint256 HomeEmiCost,uint256 HomeEmiLeft,uint256 CarLoan,uint256 CarEmiCost,
            uint256 CarEmiLeft,uint256 EducationLoan,uint256 EducationEmiCost,uint256 EducationEmiLeft)
{
        return( userBase[msg.sender].userId, userBase[msg.sender].balances,
            loanBase[msg.sender][uint256(LoanType.home)].loanAmount,loanBase[msg.sender][uint256(LoanType.home)].emiCost,
            loanBase[msg.sender][uint256(LoanType.home)].emiCount,loanBase[msg.sender][uint256(LoanType.car)].loanAmount,
            loanBase[msg.sender][uint256(LoanType.car)].emiCost,loanBase[msg.sender][uint256(LoanType.car)].emiCount,
            loanBase[msg.sender][uint256(LoanType.education)].loanAmount,loanBase[msg.sender][uint256(LoanType.education)].emiCost,
            loanBase[msg.sender][uint256(LoanType.education)].emiCount);
    }

    function withdrawLoanFund(uint256 money) public {
        require(userBase[msg.sender].balances > 0, "Funds not Avaialable");
        require(loanFund > money, "Enter valid amount");
        require(msg.sender == owner, "Only owner can withdraw funds");
        loanFund -= money;
        payable(owner).transfer(money);
    }

 
}
