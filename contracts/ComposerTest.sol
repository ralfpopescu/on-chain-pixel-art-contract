// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

import "./IRenderer.sol";
import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract ComposerTest {
    // struct Asset {
    //     uint256[] layers;
    //     uint256[] palette;
    //     uint256 colorCount;
    //     uint256 compression;
    // }
    IRenderer private renderer;

    uint256[][4] private assets;
    uint256[][4] private palettes;
    uint256[4] private colorCounts;
    uint256 private constant COMPRESSION = 4;
    uint256 private constant X = 20;
    uint256 private constant Y = 20;

    // Asset[1] public assets;

    constructor(address _renderer) {
        renderer = IRenderer(_renderer);
        assets[0] = [0x55f7df7df96fbefbefbefbefbefbefbefbefbefbef];
        palettes[0] = [0x2244bb11ee11];
        colorCounts[0] = 2;

        assets[1] = [
            0x0b3cf3cf3d38933138933183183182fa3363f40cf3cf3cf3cf3cf3cf
        ];
        palettes[1] = [0x998811000000771122];
        colorCounts[1] = 3;

        assets[2] = [
            0x047bdef7bdef7bdefa9267a9e65a15ef7be637d0b1144f33502f919ef
        ];
        palettes[2] = [0xffffee];
        colorCounts[2] = 1;

        assets[3] = [
            0x3def7bdef7be4f89a2e88a2f886418b621a0a2a88a818b6219062f88a2e89a2a,
            0x1ef7bdef
        ];
        palettes[3] = [0xffff00];
        colorCounts[3] = 1;
    }

    function renderLayers(uint256[] memory layerIds)
        external
        view
        returns (string memory svg)
    {
        uint256[] memory composedLayers = assets[layerIds[0]];
        uint256[] memory composedPalettes = palettes[layerIds[0]];
        uint256 colorCount = colorCounts[layerIds[0]];
        uint256 nextLayer;

        for (uint256 i; i < layerIds.length - 1; i += 1) {
            nextLayer = layerIds[i + 1];
            composedLayers = renderer.composeLayers(
                composedLayers,
                assets[nextLayer],
                colorCount,
                colorCounts[nextLayer],
                X * Y,
                COMPRESSION
            );

            composedPalettes = renderer.composePalettes(
                composedPalettes,
                palettes[nextLayer],
                colorCount,
                colorCounts[nextLayer]
            );

            colorCount = colorCount + colorCounts[nextLayer];
        }

        return
            renderer.render(
                composedLayers,
                composedPalettes,
                X,
                Y,
                colorCount,
                COMPRESSION
            );
    }
}
