// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./CircularSavingsCircle.sol";
import "./FixedSavingsCircle.sol";

contract CircleFactory {
    address[] private deployedCircles;
    IERC20 public stableToken;
    AggregatorV3Interface public ethUsdPriceFeed;

    event CircularSavingsCircleCreated(address indexed creator, address indexed circleAddress);
    event FixedSavingsCircleCreated(address indexed creator, address indexed circleAddress);

    constructor(address _stableTokenAddress, address _ethUsdPriceFeed) {
        stableToken = IERC20(_stableTokenAddress);
        ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
    }

    function getEthUsdPrice() public view returns (uint256) {
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        return uint256(price) * 10 ** (18 - 8); // Chainlink price feeds use 8 decimals
    }

    function getOneDollarEthAmount() public view returns (uint256) {
        uint256 ethPrice = getEthUsdPrice();
        return (1e18 * 1e18) / ethPrice; // 1 dollar worth of ETH in wei
    }

    function createCircularSavingsCircle(uint256 roundDuration, uint256 contributionAmount, uint256 fee)
        public
        payable
        returns (address)
    {
        uint256 gasFee = getOneDollarEthAmount();
        require(msg.value >= gasFee, "Not enough ETH for gas fee");

        address newCircle = address(
            new CircularSavingsCircle{value: gasFee}(
                msg.sender, roundDuration, contributionAmount, fee, address(stableToken)
            )
        );
        deployedCircles.push(newCircle);

        if (msg.value > gasFee) {
            payable(msg.sender).transfer(msg.value - gasFee);
        }

        emit CircularSavingsCircleCreated(msg.sender, newCircle);
        return newCircle;
    }

    function createFixedSavingsCircle(uint256 totalRounds, uint256 contributionAmount)
        public
        payable
        returns (address)
    {
        uint256 gasFee = getOneDollarEthAmount();
        require(msg.value >= gasFee, "Not enough ETH for gas fee");

        address newCircle = address(
            new FixedSavingsCircle{value: gasFee}(msg.sender, totalRounds, contributionAmount, address(stableToken))
        );
        deployedCircles.push(newCircle);

        if (msg.value > gasFee) {
            payable(msg.sender).transfer(msg.value - gasFee);
        }

        emit FixedSavingsCircleCreated(msg.sender, newCircle);
        return newCircle;
    }

    function getDeployedCircles() public view returns (address[] memory) {
        return deployedCircles;
    }

    function getDeployedCirclesCount() public view returns (uint256) {
        return deployedCircles.length;
    }
}