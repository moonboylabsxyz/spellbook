{{
    config(
        schema = 'tokens_arbitrum'
        ,alias = 'erc20'
        ,tags = ['static']
        ,materialized = 'table'
    )
}}

SELECT
    contract_address
    , symbol
    , decimals
FROM (VALUES
    (0xa98c94d67d9df259bee2e7b519df75ab00e3e2a8, 'bwAJNA', 18)
    , (0xda492c29d88ffe9b7cbfa6dc068c2f9befae851b, 'CUSDCLP', 18)
    , (0x831b0afaa3b22e1435169c7585ccc1861a2c9cbc, 'fUSDC', 6)
    , (0x763e061856b3e74a6c768a859dc2543a56d299d5, 'tigETH', 18)
    , (0x753d224bcf9aafacd81558c32341416df61d3dac, 'PERP', 18)
    , (0x0d81e50bc677fa67341c44d7eaa9228dee64a4e1, 'BOND', 18)
    , (0x81c958c2cb5158e2b7d3d8a7c41ef2110c0ef98d, 'xFORTUN', 18)
    , (0xb40dbbb7931cfef8be73aeec6c67d3809bd4600b, 'PPO', 18)
    , (0x223738a747383d6f9f827d95964e4d8e8ac754ce, 'auraBAL', 18)
    , (0x2416092f143378750bb29b79ed961ab195cceea5, 'ezETH', 18)
    , (0x13780e6d5696dd91454f6d3bbc2616687fea43d0, 'USTC', 6)
    , (0x9fb9a33956351cf4fa040f65a13b835a3c8764e3, 'MULTI', 18)
    , (0xac9ac2c17cdfed4abc80a53c5553388575714d03, 'ATA', 18)
    , (0x0eab25ecb949827d675864ea7686a8a7efe41116, 'SFT', 18)
    , (0xb165a74407fe1e519d6bcbdec1ed3202b35a4140, 'stataArbUSDT', 6)
    , (0x5298060a95205be6dd4abc21910a4bb23d6dcd8b, 'ROUTE', 18)
    , (0xcf879b434fe68d3d4fe3616582d26537a220f04b, 'PLAY', 18)
    , (0x2dc5dd89a3662567b78fc3a78e1e2c81d9e4d419, 'BANANIA', 18)
    , (0x218fdee44e8e923b500895e324af6c0a2e07195d, 'vrAMM-YFX/USDC', 18)
    , (0x20151ff7fdd720b85063d02081aa5b7876adff7b, 'MASH', 6)
    , (0x5c21f4b87eb5d811c824035bde9de9791766c094, 'WSN', 18)
    , (0x88ec3bfb63f5583bb4127a8d834be87e67908e2c, 'ADAI', 18)
    , (0x7cfadfd5645b50be87d546f42699d863648251ad, 'stataArbUSDCn', 6)
    , (0x6fe14d3cc2f7bddffba5cdb3bbe7467dd81ea101, 'COTI', 18)
    , (0xe2b4179dc78206e98ee3130ff64fc152923f6d23, 'POTION', 10)
    , (0xef888bca6ab6b1d26dbec977c455388ecd794794, 'RGT', 18)
    , (0xb86af5eb59a8e871bfa573fa656123ea86f47c3a, 'CWETHLP', 18)
    , (0x211cc4dd073734da055fbf44a2b4667d5e5fe5d2, 'sUSDe', 18)
    , (0xC3F47f3627305213ADaa021CcCCb61D5987EAa97, 'HRK' , 18)
    , (0x83e1d2310ade410676b1733d16e89f91822fd5c3, 'JitoSOL' , 9)    
    , (0x81b58ae322e933f8238505538a73fe81ad4f2b1e, 'BT' , 18)
    , (0xe405f6384bcd8d44981879599983d92bd9776586, 'UEE' , 9)
    , (0x5e0543f61f94b40c9a5265b5b3a7b35aa8dc6b49, 'AT' , 18)
    , (0x4a2f6ae7f3e5d715689530873ec35593dc28951b, 'wstETH/rETH/cbETH', 18)
    , (0x9791d590788598535278552eecd4b211bfc790cb, 'wstETH-WETH-BPT', 18)
    , (0x502697af336f7413bb4706262e7c506edab4f3b9, 'arbJnrLLP', 18)
    , (0x5fb31318e9a82efcaa2cfefbacf63e85f4dff2f1, 'APT', 12)
    , (0xa37ef01065e0328b50a85256e159b9aaed196e05, 'APT', 24)
    , (0xcfd72be67ee69a0dd7cf0f846fc0d98c33d60f16, 'nUSD-LP', 18)
    , (0xb076f79f8d1477165e2ff8fa99930381fb7d94c1, 'arbMzeLLP', 18)
    , (0x14fbc760efaf36781cb0eb3cb255ad976117b9bd, 'PENDLE-LPT', 18)
    , (0xade4a71bb62bec25154cfc7e6ff49a513b491e81, 'rETH-WETH-BPT', 18)
    , (0x29240aff8c592640a20cbfe0db563a6ffeb12b01, 'APT', 24)
    , (0x0c8972437a38b389ec83d1e666b69b8a4fcf8bfd, 'wstETH/rETH/sfrxETH', 18)
    , (0xd70a52248e546a3b260849386410c7170c7bd1e9, 'nETH-LP', 18)
    , (0x8bc65eed474d1a00555825c91feab6a8255c2107, 'DOLA/USDC BPT', 18)
    , (0x3fd4954a851ead144c2ff72b1f5a38ea5976bd54, 'ankrETH/wstETH-BPT', 18)
    , (0x5402b5f40310bded796c7d0f3ff6683f5c0cffdf, 'sGLP', 18)
    , (0xca5d8f8a8d49439357d3cf46ca2e720702f132b8, 'GYD', 18)
    , (0xed65c5085a18fa160af0313e60dcc7905e944dc7, 'ETHx', 18)
    , (0x221A0f68770658C15B525d0F89F5da2baAB5f321, 'OD', 18)
    , (0xb6b9cb46d9821b507e4f9705ad0d010dc8bf0447, 'TB', 18)
    , (0x4e6b45bb1c7d11402faf72c2d59cabc4085e36f2, 'OOGABOOGA', 18)
    , (0x7cc35c17db6fc7c7894f0ac19932a2c852fa7ed2, 'testDE', 18)
    , (0x88762f15d0150ac231af265737106e0b9e28e584, 'TA', 18)
    , (0xa170eaa9a74ab4b3218c736210b0421af35c3c00, 'MOLANDAK', 18)
    , (0x1d38d4204159aa5e767afba8f76be22117de61e5, 'PENDLE-LPT', 18)
    , (0x2dfaf9a5e4f293bceede49f2dba29aacdd88e0c4, 'PENDLE-LPT', 18)
    , (0x35f3db08a6e9cb4391348b0b404f493e7ae264c0, 'PENDLE-LPT', 18)
    , (0x6ea313859a5d9f6ff2a68f529e6361174bfd2225, 'S*USDC', 6)
    , (0x8d66ff1845b1bacc6e87d867ca4680d05a349ca8, 'S*USDT', 6)
    , (0xba4a858d664ddb052158168db04afa3cff5cfcc8, 'PENDLE-LPT', 18)
    , (0xf9f9779d8ff604732eba9ad345e6a27ef5c2a9d6, 'PENDLE-LPT', 18)
    , (0x4cb9a7ae498cedcbb5eae9f25736ae7d428c9d66, 'XAI', 18)
    , (0x323665443cef804a3b5206103304bd4872ea4253, 'USDV', 6)
    , (0x966570a84709d693463cdd69dcadb0121b2c9d26, 'taoUSD', 18)
    , (0x993614e1c8c9c5abe49462ce5702431978fd767f, 'S*ETH', 18)
    , (0xD460f305B150Bc70b063E806815B50BebE9F21b1, 'APRTo', 18)
    , (0x577fd586c9e6ba7f2e85e025d5824dbe19896656, 'SYNO', 18)
    , (0x6985884c4392d348587b19cb9eaaf157f13271cd, 'ZRO', 18)
    , (0x5a7a183b6b44dc4ec2e3d2ef43f98c5152b1d76d, 'inETH', 18)
    , (0xd08c3f25862077056cb1b710937576af899a4959, 'instETH', 18)
    , (0x7dff72693f6a4149b17e7c6314655f6a9f7c8b33, 'GHO', 18)    
    , (0xa7997f0ec9fa54e89659229fb26537b6a725b798, 'PAL', 18)
    , (0x064F8B858C2A603e1b106a2039f5446D32dc81c1, 'OLAS', 18)    
    , (0xc608dfb90a430df79a8a1edbc8be7f1a0eb4e763, 'fETH', 18)
    , (0x248a431116c6f6fcd5fe1097d16d0597e24100f5, 's_aArbUSDC', 6)
    , (0x965772e0e9c84b6f359c8597c891108dcf1c5b1a, 'PICKLE', 18)        
    , (0x777cf5ba9c291a1a8f57ff14836f6f9dc5c0f9dd, 'SOLID', 18)
) AS temp_table (contract_address, symbol, decimals)
