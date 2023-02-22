// SPDX-License-Identifier:GPl-3.0

pragma solidity ^0.8.0;

import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IFlashLoanSimpleReceiver} from "@aave/core-v3/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {SafeMath} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract FlashLoanAAVE is IFlashLoanSimpleReceiver, IERC721Receiver {
    using SafeMath for uint256;

    event CurrentBalance(uint256 balance);

    IPoolAddressesProvider public ADRESSES_PROVIDER = IPoolAddressesProvider(0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e);
    IPool public POOL;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public seller = <Your wallet>;

    constructor () {
        POOL = IPool(ADRESSES_PROVIDER.getPool());
    }

    function ADDRESSES_PROVIDER() external view returns(IPoolAddressesProvider){
        return ADRESSES_PROVIDER;
    }

    function executeFlashLoan(address asset, uint256 amount, bytes calldata params) public {
        // perform a flashLoanSimple() on the pool contract
        uint16 referralCode = 0;
        POOL.flashLoanSimple(address(this), asset, amount, params, referralCode);
    }

    function callProxy(
        address _exchange,
        bytes calldata _calldata
    ) public {
        (bool success, ) = _exchange.call(_calldata);
        require(success);
    }

    function executeOperation(address asset, uint256 amount, uint256 premium, address initiator, bytes calldata params) external override returns(bool) { //this will be called by Pool

        emit CurrentBalance(IERC20(weth).balanceOf(address(this)));
        callProxy(address(0x00000000006c3852cbEf3e08E8dF289169EdE581),params);
        IERC20(weth).transferFrom(seller, address(this), IERC20(weth).balanceOf(seller));
        return true;
    }

    function approvalWeth(address _token) public {
        IERC20(_token).approve(address(0x1E0049783F008A0085193E00003D00cd54003c71), 10000 ether); // opensea 
        IERC20(_token).approve(address(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2), 10000 ether); // aave
    }
    
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override returns (bytes4) {
        // IERC20(weth).transferFrom(seller, address(this), IERC20(weth).balanceOf(seller));
        emit CurrentBalance(IERC20(weth).balanceOf(address(this)));
        return 0x150b7a02;
    }
}

// deployed on goerli using hardhat and the address is 0x6dc85a986Fbad7A60a2130D806F5bdF327BbD8f9