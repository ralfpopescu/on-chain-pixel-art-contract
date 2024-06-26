// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract Renderer {
    uint8 constant colorMask = 0xFF;

    struct RenderTracker {
        uint256 colorCompression;
        uint256 packetsPerLayer;
        uint256 pixel;
        uint256 iterator;
        uint256 pixelsUsed;
        uint256 x;
        uint256 y;
        uint256 blockSize;
    }

    function toString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function getColor(uint256[2] memory pallette, uint256 index)
        internal
        pure
        returns (uint256[3] memory rgb)
    {
        uint256 palletteIndex = index / 8;
        uint256 shift = index % 8;
        uint256 r = (pallette[palletteIndex] >> shift) & colorMask;
        uint256 g = (pallette[palletteIndex] >> (shift + 8)) & colorMask;
        uint256 b = (pallette[palletteIndex] >> (shift + 16)) & colorMask;
        return [r, g, b];
    }

    function bitsToMask(uint256 bits) internal pure returns (uint256 mask) {
        return 2**bits - 1;
    }

    function getColorCompression(uint256 colorCount)
        internal
        pure
        returns (uint256 comp)
    {
        uint256 compression = 1;
        while (colorCount >= 2**compression) {
            compression = compression + 1;
        }

        return compression;
    }

    function encodeColorArray(
        uint256[] memory colors,
        uint256 pixelCompression,
        uint256 colorCount
    ) public pure returns (uint256[] memory encoded) {
        uint256 colorCompression = getColorCompression(colorCount);
        uint256 layer;
        // total pixels divided by max packets per layer is worst case, add 1 for 0 case
        uint256[] memory layers = new uint256[](
            colors.length / (256 / pixelCompression + colorCompression) + 1
        );
        uint256 color;
        uint256 packet;
        uint256 numberOfConsecutiveColors;
        uint256 layerIndex;

        while (color < colors.length) {
            // find number of colors in a row
            while (
                color + numberOfConsecutiveColors < colors.length &&
                colors[color + numberOfConsecutiveColors] == colors[color] &&
                numberOfConsecutiveColors < 2**pixelCompression - 1
            ) {
                numberOfConsecutiveColors += 1;
            }

            // add packet to layer
            layer =
                layer +
                ((
                    // make packet
                    ((colors[color] << pixelCompression) +
                        numberOfConsecutiveColors)
                ) <<
                    // shift new packet over to new spot
                    ((pixelCompression + colorCompression) * packet));

            // if we've reached the max number of packets in a 256, push and move to next layer. 10 packets is 0 - 9, hence -1
            if (packet == (256 / (pixelCompression + colorCompression) - 1)) {
                layers[layerIndex] = layer;
                layerIndex += 1;
                layer = 0;
                packet = 0;
            } else {
                // only progress packet if we on the same layer, otherwise we need to carry over to 0
                packet += 1;
            }

            // update color to the next color
            color = color + numberOfConsecutiveColors;
            numberOfConsecutiveColors = 0;
        }

        // we only added layers if they were full, we now need to add the last "incomplete" layer
        layers[layerIndex] = layer;

        // shave off the unused indices, add 1 to index to get array size
        uint256[] memory reducedLayers = new uint256[](layerIndex + 1);

        for (uint256 i; i <= layerIndex; i += 1) {
            reducedLayers[i] = layers[i];
        }

        return reducedLayers;
    }

    function composePalettes(
        uint256[] memory palette1,
        uint256[] memory palette2,
        uint256 colorCount1,
        uint256 colorCount2
    ) public view returns (uint256[] memory composedPalette) {
        uint256 color;
        uint256 layer;
        uint256[] memory colors = new uint256[](colorCount1 + colorCount2);
        // calculate how many palette layers we'll need, 10 colors fit in one layer
        uint256[] memory composed = new uint256[](
            ((colorCount1 + colorCount2) / 10) + 1
        );
        uint256 layerIndex;

        // fill with colors from first palette
        while (color < colorCount1) {
            colors[color] =
                (palette1[color / 10] >> ((color % 10) * 24)) &
                0xFFFFFF;

            color += 1;
        }

        // fill with colors from second palette, don't reset layer or color for continuity
        while (color < colorCount1 + colorCount2) {
            colors[color] =
                (palette2[(color - colorCount1) / 10] >>
                    (((color - colorCount1) % 10) * 24)) &
                0xFFFFFF;

            color += 1;
        }

        for (uint256 c; c < colors.length; c += 1) {
            layer = layer + (colors[c] << ((c % 10) * 24));
            console.log(colors[c], layer, c, colors.length);

            // we've put 10 colors in, 0 - 9
            if (c % 10 == 9) {
                composed[layerIndex] = layer;
                layerIndex += 1;
                layer = 0;
            }
        }

        // we need to push the last incomplete layer
        composed[layerIndex] = layer;

        return composed;
    }

    function composeLayers(
        uint256[] memory layer1,
        uint256[] memory layer2,
        uint256 colorCount1,
        uint256 colorCount2,
        uint256 totalPixels,
        uint256 pixelCompression
    ) public pure returns (uint256[] memory comp) {
        uint256[] memory colors = new uint256[](totalPixels);
        uint256 colorCompression = getColorCompression(colorCount1);

        uint256 packetsPerLayer = 256 / (pixelCompression + colorCompression);

        uint256 iterator;
        uint256 numberOfPixels;
        uint256 pixel;

        while (pixel < totalPixels) {
            numberOfPixels =
                (layer1[(iterator / packetsPerLayer)] >>
                    ((iterator % packetsPerLayer) *
                        (pixelCompression + colorCompression))) &
                bitsToMask(pixelCompression);

            uint256 colorIndex = (layer1[(iterator / packetsPerLayer)] >>
                ((iterator % packetsPerLayer) *
                    (pixelCompression + colorCompression) +
                    pixelCompression)) & bitsToMask(colorCompression);

            if (colorIndex > 0) {
                for (uint256 i; i < numberOfPixels; i += 1) {
                    colors[pixel + i] = colorIndex;
                }
            }
            pixel += numberOfPixels;
            iterator += 1;
        }

        // reset counters for second layer
        pixel = 0;
        iterator = 0;
        // update color compression to be for new color count
        colorCompression = getColorCompression(colorCount2);
        packetsPerLayer = 256 / (pixelCompression + colorCompression);

        while (pixel < totalPixels) {
            numberOfPixels =
                (layer2[uint8(iterator / packetsPerLayer)] >>
                    ((iterator % packetsPerLayer) *
                        (pixelCompression + colorCompression))) &
                bitsToMask(pixelCompression);

            uint256 colorIndex = (layer2[uint8(iterator / packetsPerLayer)] >>
                ((iterator % packetsPerLayer) *
                    (pixelCompression + colorCompression) +
                    pixelCompression)) & bitsToMask(colorCompression);

            if (colorIndex > 0) {
                for (uint256 i; i < numberOfPixels; i += 1) {
                    // we need to add the color count of the first color set to offset correctly
                    colors[pixel + i] = (colorCount1 + colorIndex);
                }
            }

            pixel += numberOfPixels;
            iterator += 1;
        }

        return
            encodeColorArray(
                colors,
                pixelCompression,
                colorCount1 + colorCount2
            );
    }

    function render(
        uint256[] memory pixels,
        uint256[] memory pallette,
        uint256 xDim,
        uint256 yDim,
        uint256 colorCount,
        uint256 pixelCompression
    ) external pure returns (string memory svg) {
        RenderTracker memory tracker = RenderTracker(
            getColorCompression(colorCount),
            256 / (pixelCompression + getColorCompression(colorCount)),
            0,
            0,
            0,
            0,
            0,
            0
        );

        svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" version="1.2" viewBox="0 0 ',
                toString(xDim),
                " ",
                toString(yDim),
                '">'
            )
        );
        // 2 ^ compression is how many colors, times 3 for r g b
        uint8[] memory colors = new uint8[](2**tracker.colorCompression * 3);

        // iterate each color, 2 ** compression colors
        for (uint8 i = 0; i < colorCount; i += 1) {
            // 24 bits for each color, so 10 total (240 bits) in each 256
            uint256 palletteIndex = i / 10;

            colors[i * 3] = uint8(
                (pallette[palletteIndex] >> ((i % 10) * 24)) & colorMask
            );
            colors[i * 3 + 1] = uint8(
                (pallette[palletteIndex] >> ((((i % 10) * 24)) + 8)) & colorMask
            );
            colors[i * 3 + 2] = uint8(
                (pallette[palletteIndex] >> ((((i % 10) * 24)) + 16)) &
                    colorMask
            );
        }

        while (tracker.pixel < yDim * xDim) {
            // 32 points for every layer of pixel groups
            // 8 bits, 4 bits for color index and 4 bits for up to 16 repetitions

            uint256 numberOfPixels = (pixels[
                uint8(tracker.iterator / tracker.packetsPerLayer)
            ] >>
                ((tracker.iterator % tracker.packetsPerLayer) *
                    (pixelCompression + tracker.colorCompression))) &
                bitsToMask(pixelCompression);

            uint256 colorIndex = (pixels[
                uint8(tracker.iterator / tracker.packetsPerLayer)
            ] >>
                ((tracker.iterator % tracker.packetsPerLayer) *
                    (pixelCompression + tracker.colorCompression) +
                    pixelCompression)) & bitsToMask(tracker.colorCompression);

            // colorIndex 1 corresponds to color array index 0
            if (colorIndex > 0) {
                uint256 x = tracker.pixel % yDim;
                uint256 y = tracker.pixel / yDim;
                tracker.pixelsUsed = 0;

                // calculate how many blocks of pixels we'll need to make
                tracker.blockSize = ((x + numberOfPixels) / xDim) + 1;
                // if we fit the row snuggly, we'll want to remove the 1 we added
                if ((x + numberOfPixels) % xDim == 0) {
                    tracker.blockSize = tracker.blockSize - 1;
                }
                uint256[] memory blocks = new uint256[](tracker.blockSize);

                for (
                    uint8 blockCounter;
                    blockCounter < blocks.length;
                    blockCounter += 1
                ) {
                    x = tracker.pixel % yDim;
                    y = tracker.pixel / yDim;
                    // find out how many pixels we need in the block
                    uint256 width = numberOfPixels - tracker.pixelsUsed;
                    // check that the block overflows into the next row
                    if (width > xDim - x) {
                        width = xDim - x;
                    }
                    // remove the number of blocks we used
                    tracker.pixelsUsed = tracker.pixelsUsed + width;
                    tracker.pixel = tracker.pixel + width;

                    svg = string(
                        abi.encodePacked(
                            svg,
                            '<rect x="',
                            toString(x),
                            '" y="',
                            toString(y),
                            '" width="',
                            toString(width),
                            '" height="1" shape-rendering="crispEdges" fill="rgb(',
                            toString(colors[(colorIndex - 1) * 3 + 2]),
                            ",",
                            toString(colors[(colorIndex - 1) * 3 + 1]),
                            ",",
                            toString(colors[(colorIndex - 1) * 3]),
                            ')" />'
                        )
                    );
                }
            } else {
                // we still need to account for the empty pixels
                tracker.pixel = tracker.pixel + numberOfPixels;
            }

            tracker.iterator += 1;
        }

        svg = string(abi.encodePacked(svg, "</svg>"));

        return svg;
    }
}
