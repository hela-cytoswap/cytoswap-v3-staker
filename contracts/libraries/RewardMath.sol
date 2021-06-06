// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@openzeppelin/contracts/math/Math.sol';

/// @title Math for computing rewards
/// @notice Allows computing rewards given some parameters of stakes and incentives
library RewardMath {
    /// @notice Compute the amount of rewards owed given parameters of the incentive and stake
    /// @param totalRewardUnclaimed The total amount of unclaimed rewards left for an incentive
    /// @param totalSecondsClaimedX128 How many full liquidity-seconds have been already claimed for the incentive
    /// @param startTime When the incentive rewards began in epoch seconds
    /// @param endTime When rewards are no longer being dripped out in epoch seconds
    /// @param liquidity The amount of liquidity, assumed to be constant over the period over which the snapshots are measured
    /// @param secondsPerLiquidityInsideInitialX128 The seconds per liquidity of the liquidity tick range as of the beginning of the period
    /// @param secondsPerLiquidityInsideX128 The seconds per liquidity of the liquidity tick range as of the current block timestamp
    function computeRewardAmount(
        uint256 totalRewardUnclaimed,
        uint160 totalSecondsClaimedX128,
        uint256 startTime,
        uint256 endTime,
        uint128 liquidity,
        uint160 secondsPerLiquidityInsideInitialX128,
        uint160 secondsPerLiquidityInsideX128
    ) internal view returns (uint256 reward, uint160 secondsInsideX128) {
        assert(block.timestamp >= startTime);
        assert(endTime - startTime <= type(uint32).max);

        // this operation is safe, as the difference cannot be greater than 1/stake.liquidity
        secondsInsideX128 =
            (secondsPerLiquidityInsideX128 -
                secondsPerLiquidityInsideInitialX128) *
            liquidity;

        uint256 totalSecondsUnclaimedX128 =
            ((Math.max(endTime, block.timestamp) - startTime) << 128) -
                totalSecondsClaimedX128;

        reward = FullMath.mulDiv(
            totalRewardUnclaimed,
            secondsInsideX128,
            totalSecondsUnclaimedX128
        );
    }
}
