import { expect } from "chai";
import { ethers } from "hardhat";

const deploy = async () => {
  const Renderer = await ethers.getContractFactory("Renderer");
  const renderer = await Renderer.deploy();
  await renderer.deployed();
  return renderer;
}

describe("Renderer", function () {
  it("Should render something", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    await renderer.render(
      ["0x22048822238881220888e2204a0e2204882223888122088881e3c78f1e3c78f", "0x061e3c78f1e3c78f1e3c78f"],
      ["0x4240588c22888800"],
      20,
      20,
      4,
      4)
  });

  it("Should render something - all edges covered", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    const render = await renderer.render(
      ["0x4443d118f98e85484e98b3cf4443d110f4454425464454443d110f4443d13d4", "0x50f4443d110f4443d115111511115110f"],
      ["0x235aaaf3df2b"],
      20,
      20,
      2,
      4);

    console.log('render', render);
  });



  it("encode color array, then render", async function () {
    const renderer = await deploy();
    const hex = ["0x48f10c431348f10c431348f10c431345110c4317448f92e237c86f90df51d874", "0xa0ec3a8df21be437c59223e2e8862189e278862189a478862189a4788666"];
    const colorArray = [1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1]
    console.log("LENGTH!", colorArray.length);
    const encoded = await renderer.encodeColorArray(colorArray, 4, 1);
    console.log('encodedencoded', encoded[0]._hex, encoded[1]._hex);
    console.log('hexhexhex', hex);

    const rendered = await renderer.render(
      encoded,
      ["0x5f3df8"],
      // x
      20,
      // y
      20,
      // color count
      1,
      // pixel compression
      4)

    console.log('encode color array - contract', rendered);

    console.log('-----------')

    const renderedHex = await renderer.render(
      hex,
      ["0x0e3c78f1e3c78f1e3c78f1e3cc891e3c78f1e3c78f1e3c78f"],
      // x
      20,
      // y
      20,
      // color count
      1,
      // pixel compression
      4)

    console.log("encode color array - hex", renderedHex);
  });

  it("Should compose two images", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    const a = await renderer.deployed();

    const composed = await renderer.composeLayers(
      // vertical line
      ["0x0a1e3c78f1e3c78f1e3c78f2210791083c8841e4470f1e3c78f1e3c78f"],
      //horizontal line
      ["0x0e3c78f1e3c78f1e3c78f1e3cc891e3c78f1e3c78f1e3c78f"],
      // color count 1
      4,
      // color count 2
      4,
      // total pixels for 20x20
      400,
      // pixel compression
      4
    );

    const rendered = await renderer.render(
      composed,
      ["0x0e3c78f1e3c78f1e3c78f1e3cc891e3c78f1e3c78f1e3c78f"],
      // x
      20,
      // y
      20,
      // color count
      8,
      // pixel compression
      4)

    console.log(rendered);
  });

  it("Should compose two color palettes", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    const composed = await renderer.composePalettes(
      ["0x232ED1BF4342"],
      ["0x7357517DDE92"],
      2,
      2
    );

    expect(composed[0]._hex).to.equal('0x7357517DDE92232ED1BF4342'.toLowerCase());
  });

  it("Should compose two large color palettes", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    const composed = await renderer.composePalettes(
      ["0x3C3744FBFFF1B4C5E43D52D5232ED1BF4342"],
      ["0x9B1D203D2B3DD0FFCECBEFB67357517DDE92"],
      6,
      6
    );

    expect(composed[0]._hex).to.equal('0xD0FFCECBEFB67357517DDE923C3744FBFFF1B4C5E43D52D5232ED1BF4342'.toLowerCase());
    expect(composed[1]._hex).to.equal('0x9B1D203D2B3D'.toLowerCase());
  });

  it("Should compose two multi-index color palettes", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    const composed = await renderer.composePalettes(
      ["0x02040FE5DADA002642E595003C3744FBFFF1B4C5E43D52D5232ED1BF4342", "0xDCD6F7B4869F985F6F8AA8A1"],
      ["0x48233C0D4E4BC96ACB740376E9B1D203D2B3DD0FFCECBEFB67357517DDE1", "0x885A89D1B490"],
      14,
      12
    );

    expect(composed[0]._hex).to.equal('0x02040FE5DADA002642E595003C3744FBFFF1B4C5E43D52D5232ED1BF4342'.toLowerCase());
    expect(composed[1]._hex).to.equal('0xE9B1D203D2B3DD0FFCECBEFB67357517DDE1DCD6F7B4869F985F6F8AA8A1'.toLowerCase());
    expect(composed[2]._hex).to.equal('0x885A89D1B49048233C0D4E4BC96ACB740376'.toLowerCase());
  });

  it("Should render an alien body composed with legs with a composed palette", async function () {
    const Renderer = await ethers.getContractFactory("Renderer");
    const renderer = await Renderer.deploy();
    const a = await renderer.deployed();

    const compression = 4;
    const x = 20;
    const y = 20;

    const canvas1 = ["0x08f4614423d308f4614423d308f4c23d185108f4614423d334f3cf3cf3cf3cf", "0x0e3cf3cf3d3"];
    const palette1 = ['0xee5511823133'] // #823133 body and #ee5511 eyes
    const colorCount1 = 2;

    const canvas2 = ["0x1cf906417c43113e21889ef891f223e447cc7323e447c88f8b1ef7bdef7bdef"];
    const palette2 = ['0xbefcca'] // #b355d8 legs
    const colorCount2 = 1;

    const composed = await renderer.composeLayers(
      // body
      canvas1,
      // arms
      canvas2,
      // color count 1
      colorCount1,
      // color count 2
      colorCount2,
      // total pixels for 20x20
      x * y,
      // pixel compression
      compression
    );

    const composedPalette = await renderer.composePalettes(
      palette1,
      palette2,
      2,
      1
    );

    // console.log('composedPalette', composedPalette);

    const rendered = await renderer.render(
      composed,
      composedPalette,
      // x
      20,
      // y
      20,
      // color count
      colorCount1 + colorCount2,
      // pixel compression
      4)

    console.log(rendered);
  });

  const landscape = ['0x55f7df7df96fbefbefbefbefbefbefbefbefbefbef'];
  const landscapeColors = ['0x2244bb11ee11']

  const house = ['0x0b3cf3cf3d38933138933183183182fa3363f40cf3cf3cf3cf3cf3cf']
  const houseColors = ['0x998811000000771122']

  const clouds = ['0x047bdef7bdef7bdefa9267a9e65a15ef7be637d0b1144f33502f919ef'];
  const cloudColors = ['0xffffee']

  const sun = ['0x3def7bdef7be4f89a2e88a2f886418b621a0a2a88a818b6219062f88a2e89a2a', '0x1ef7bdef'];
  const sunColors = ['0xffff00'];

  it("Should render a full scene", async function () {
    const renderer = await deploy();
    const rendered = await renderer.render(
      landscape,
      landscapeColors,
      // x
      20,
      // y
      20,
      // color count
      2,
      // pixel compression
      4
    );

    console.log('SCENE!', rendered);
  });

  it("Should compose a house scene", async function () {
    const renderer = await deploy();

    const compression = 4;
    const x = 20;
    const y = 20;


    let composed = await renderer.composeLayers(
      landscape,
      house,
      // color count 1
      2,
      // color count 2
      3,
      x * y,
      compression
    );

    composed = await renderer.composeLayers(
      composed,
      clouds,
      2 + 3,
      1,
      x * y,
      4
    );

    let rendered = await renderer.render(
      composed,
      ["0x9DA39ADB29555682595D2E8CFF6666CCFF66F1E8B8"],
      // x
      20,
      // y
      20,
      // color count
      2 + 3 + 1 + 1,
      // pixel compression
      4
    );

    console.log("HOUSE AND LANDSCAPE", rendered);

    console.log('composed landscape and house and clouds')

    composed = await renderer.composeLayers(
      composed,
      sun,
      2 + 3 + 1,
      1,
      x * y,
      4
    );

    console.log('composed landscape and house and clouds and sun')

    let composedPalette = await renderer.composePalettes(
      landscapeColors,
      houseColors,
      2,
      3
    );

    console.log('composing first 2 palettes', composedPalette[0]._hex)


    console.log('composed landscape and house palettes')

    composedPalette = await renderer.composePalettes(
      composedPalette,
      cloudColors,
      2 + 3,
      1
    );

    console.log('composed landscape and house and cloud palettes')

    composedPalette = await renderer.composePalettes(
      composedPalette,
      sunColors,
      2 + 3 + 1,
      1
    );

    console.log('composed palette', composedPalette[0]._hex);

    console.log('composed landscape and house and cloud and sun palettes')

    console.log('rendering...')

    rendered = await renderer.render(
      composed,
      ["0x6558ed9DA39ADB29555682595D2E8CFF6666CCFF66F1E8B8"],
      // x
      20,
      // y
      20,
      // color count
      2 + 3 + 1 + 1,
      // pixel compression
      4
    );

    console.log(rendered);
  });

  it("Gas for composer", async function () {
    const renderer = await deploy();
    const ComposerTest = await ethers.getContractFactory("ComposerTest");
    const composerTest = await ComposerTest.deploy(renderer.address);
    const contract = await composerTest.deployed();
    const gasUsed = contract.deployTransaction.gasLimit.toNumber();
    const inUSD = (gasUsed * 40 / 1000000000) * 3000;
    console.log('GAS USED:', { gasUsed, inUSD });
    // gas used 264947 208459
    const rendered = await composerTest.renderLayers([0, 1, 2, 3]);
    console.log(rendered);
  });
});
