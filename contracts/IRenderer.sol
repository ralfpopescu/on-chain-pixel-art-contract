// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

interface IRenderer {
    function render(
        uint256[] memory pixels,
        uint256[] memory pallette,
        uint256 xDim,
        uint256 yDim,
        uint256 colorCount,
        uint256 pixelCompression
    ) external view returns (string memory svg);

    function encodeColorArray(
        uint256[] memory colors,
        uint256 pixelCompression,
        uint256 colorCount
    ) external pure returns (uint256[] memory encoded);

    function composePalettes(
        uint256[] memory palette1,
        uint256[] memory palette2,
        uint256 colorCount1,
        uint256 colorCount2
    ) external view returns (uint256[] memory composedPalette);

    function composeLayers(
        uint256[] memory layer1,
        uint256[] memory layer2,
        uint256 colorCount1,
        uint256 colorCount2,
        uint256 totalPixels,
        uint256 pixelCompression
    ) external pure returns (uint256[] memory comp);
}
