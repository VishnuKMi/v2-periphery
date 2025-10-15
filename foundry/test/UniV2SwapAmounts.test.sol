// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IWETH} from "interfaces/IWETH.sol";
import {IUniswapV2Router02} from "interfaces/IUniswapV2Router02.sol";

import {DAI, WETH, MKR, UNI_V2_ROUTER_02} from "../Constants.sol";

contract UniV2SwapAmountsTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant mkr = IERC20(MKR);
    IUniswapV2Router02 private constant router = IUniswapV2Router02(UNI_V2_ROUTER_02);

    function setUp() public {
        // Optional: give test address some ETH for gas
        vm.deal(address(this), 100 ether);
        vm.startPrank(address(this));
        weth.deposit{value: 100 * 1 ether}();
        // weth.approve(address(router), type(uint256).max);
        IERC20(address(weth)).approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_forkedRouterExists() public {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(UNI_V2_ROUTER_02)
        }
        console2.log("Router code size:", codeSize);
        assert(codeSize > 0); // should pass on fork
    }

    function test_getAmountsOut() public {
        uint256 amountIn = 1 ether; // 1 WETH

        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256[] memory amountsOut = router.getAmountsOut(amountIn, path);

        console2.log("WETH -> DAI -> MKR");
        console2.log("DAI out:", amountsOut[1] / 1e18);
        console2.log("MKR out:", amountsOut[2] / 1e18);
    }

    function test_getAmountsIn() public {
        uint256 amountOut = 1e15; // 0.001 MKR

        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256[] memory amountsIn = router.getAmountsIn(amountOut, path);

        console2.log("WETH -> DAI -> MKR");
        console2.log("WETH needed:", amountsIn[0] / 1e18);
        console2.log("DAI needed:", amountsIn[1] / 1e18);
    }

    // Spend a fixed amount of tokens and get as many output tokens as possible
    function test_swapExactTokensForTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountIn = 1e18;
        uint256 amountOutMin = 0; // safer for fork

        uint256[] memory amounts = router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        console2.log("WETH in:", amounts[0] / 1e18);
        console2.log("DAI out:", amounts[1] / 1e18);
        console2.log("MKR out:", amounts[2] / 1e18);

        assertGt(mkr.balanceOf(address(this)), 0, "MKR balance after swap");
    }

    // Receive a fixed amount of output tokens, spending as few input tokens as necessary (up to a limit)
    function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountOut = 0.1e18; // want 0.1 MKR
        uint256 amountInMax = 10e18; // willing to spend up to 10 WETH

        uint256[] memory amounts = router.swapTokensForExactTokens({
            amountOut: amountOut,
            amountInMax: amountInMax,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        console2.log("WETH in:", amounts[0] / 1e18);
        console2.log("DAI out:", amounts[1] / 1e18);
        console2.log("MKR out:", amounts[2] / 1e18);

        assertEq(mkr.balanceOf(address(this)), amountOut, "MKR balance before swap");
    }
}
