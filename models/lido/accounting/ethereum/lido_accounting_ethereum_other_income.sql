{{ config(
        alias = 'other_income',
         
        materialized = 'table',
        file_format = 'delta',
        post_hook='{{ expose_spells(\'["ethereum"]\',
                                "project",
                                "lido_accounting",
                                \'["pipistrella", "adcv", "zergil1397", "lido"]\') }}'
        )
}}
--https://dune.com/queries/2011910
--ref{{'lido_accounting_other_income'}}

with tokens AS (
select * from (values 
    (0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32), --LDO
    (0x6B175474E89094C44Da98b954EedeAC495271d0F),   --DAI
    (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),   --USDC
    (0xdAC17F958D2ee523a2206206994597C13D831ec7), -- USDT
    (0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2),   --WETH
    (0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0),   --MATIC
    (0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84),  --stETH
    (0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0) --wstETH
) as tokens(address)),


multisigs_list AS (
select * from (values
(0x3e40d73eb977dc6a537af587d48316fee66e9c8c, 'Ethereum', 'Aragon'),
(0x48F300bD3C52c7dA6aAbDE4B683dEB27d38B9ABb, 'Ethereum', 'FinanceOpsMsig'),
(0x87D93d9B2C672bf9c9642d853a8682546a5012B5, 'Ethereum', 'LiquidityRewardsMsig'),
(0x753D5167C31fBEB5b49624314d74A957Eb271709, 'Ethereum', 'LiquidityRewardMngr'),--Curve Rewards Manager 
(0x1dD909cDdF3dbe61aC08112dC0Fdf2Ab949f79D8, 'Ethereum', 'LiquidityRewardMngr'), --Balancer Rewards Manager V1 
(0x55c8De1Ac17C1A937293416C9BCe5789CbBf61d1, 'Ethereum', 'LiquidityRewardMngr'), --Balancer Rewards Manager V2 
(0x86F6c353A0965eB069cD7f4f91C1aFEf8C725551, 'Ethereum', 'LiquidityRewardMngr'), --Balancer Rewards Manager V3 
(0xf5436129Cf9d8fa2a1cb6e591347155276550635,  'Ethereum', 'LiquidityRewardMngr'),--1inch Reward Manager 
(0xE5576eB1dD4aA524D67Cf9a32C8742540252b6F4,  'Ethereum', 'LiquidityRewardMngr'), --Sushi Reward Manager
(0x87D93d9B2C672bf9c9642d853a8682546a5012B5,  'Polygon',  'LiquidityRewardsMsig'),
(0x9cd7477521B7d7E7F9e2F091D2eA0084e8AaA290,  'Ethereum', 'PolygonTeamRewardsMsig'),
(0x5033823f27c5f977707b58f0351adcd732c955dd,  'Optimism', 'LiquidityRewardsMsig'),
(0x8c2b8595ea1b627427efe4f29a64b145df439d16,  'Arbitrum', 'LiquidityRewardsMsig'),
(0x13c6ef8d45afbccf15ec0701567cc9fad2b63ce8,  'Ethereum',  'ReferralRewardsMsig'),--Solana Ref Prog Msig
(0x12a43b049A7D330cB8aEAB5113032D18AE9a9030,  'Ethereum',  'LegoMsig'),
(0x9B1cebF7616f2BC73b47D226f90b01a7c9F86956,  'Ethereum',  'ATCMsig'),
(0x17F6b2C738a63a8D3A113a228cfd0b373244633D,  'Ethereum',  'PMLMsig'),
(0xde06d17db9295fa8c4082d4f73ff81592a3ac437,  'Ethereum',  'RCCMsig'),
(0x834560f580764bc2e0b16925f8bf229bb00cb759,  'Ethereum',  'TRPMsig')
) as list(address, chain, name)
        
),

diversifications_addresses AS (
select * from  (values
(0x489f04eeff0ba8441d42736549a1f1d6cca74775, '1round_1'),
(0x689e03565e36b034eccf12d182c3dc38b2bb7d33, '1round_2'),
(0xA9b2F5ce3aAE7374a62313473a74C98baa7fa70E, '2round')
) as list(address, name)
),

intermediate_addresses AS (
select * from  (values
(0xe3224542066d3bbc02bc3d70b641be4bc6f40e36, 'Jumpgate(Solana)'),
(0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf, 'Polygon bridge'),
(0xa3a7b6f88361f48403514059f1f16c8e78d60eec, 'Arbitrum bridge'),
(0x99c9fc46f92e8a1c0dec1b1747d010903e884be1, 'Optimism bridge'),
(0x0914d4ccc4154ca864637b0b653bc5fd5e1d3ecf, 'AnySwap bridge (Polkadot, Kusama)'),
(0x3ee18b2214aff97000d974cf647e7c347e8fa585, 'Wormhole bridge'), --Solana, Terra
(0x9ee91F9f426fA633d227f7a9b000E28b9dfd8599, 'stMatic Contract')
) as list(address, name)
),

ldo_referral_payments_addr AS (
select * from  (values
(0x558247e365be655f9144e1a0140d793984372ef3),
(0x6DC9657C2D90D57cADfFB64239242d06e6103E43),
(0xDB2364dD1b1A733A690Bf6fA44d7Dd48ad6707Cd),
(0x586b9b2F8010b284A0197f392156f1A7Eb5e86e9),
(0xC976903918A0AF01366B31d97234C524130fc8B1),
(0x53773e034d9784153471813dacaff53dbbb78e8c),
(0x883f91D6F3090EA26E96211423905F160A9CA01d),
(0xf6502Ea7E9B341702609730583F2BcAB3c1dC041),
(0x82AF9d2Ea81810582657f6DC04B1d7d0D573F616),
(0x351806B55e93A8Bcb47Be3ACAF71584deDEaB324),
(0x9e2b6378ee8ad2A4A95Fe481d63CAba8FB0EBBF9),
(0xaf8aE6955d07776aB690e565Ba6Fbc79B8dE3a5d) --rhino
) as list(address)
),


dai_referral_payments_addr AS (
    SELECT _recipient AS address FROM  {{source('lido_ethereum','AllowedRecipientsRegistry_evt_RecipientAdded')}}
    WHERE
    (
        NOT EXISTS (SELECT _recipient FROM {{source('lido_ethereum','AllowedRecipientsRegistry_evt_RecipientRemoved')}}) 
        OR (
            EXISTS (SELECT _recipient FROM {{source('lido_ethereum','AllowedRecipientsRegistry_evt_RecipientRemoved')}})
            AND 
            _recipient NOT IN (SELECT _recipient FROM {{source('lido_ethereum','AllowedRecipientsRegistry_evt_RecipientRemoved')}})
        )
    ) 
    UNION ALL
    SELECT 0xaf8aE6955d07776aB690e565Ba6Fbc79B8dE3a5d --rhino
),

steth_referral_payments_addr AS (
    SELECT _recipient AS address FROM {{source('lido_ethereum','AllowedRecipientsRegistry_RevShare_evt_RecipientAdded')}}
),

other_income_txns AS (
    SELECT
        evt_block_time, 
        CAST(value AS DOUBLE) AS value, 
        evt_tx_hash, 
        contract_address
    FROM  {{source('erc20_ethereum','evt_transfer')}}
    WHERE contract_address IN (SELECT address FROM tokens)
    AND to IN (
        SELECT 
            address 
        FROM multisigs_list 
        WHERE name IN ('Aragon','FinanceOpsMsig') AND chain = 'Ethereum'
    )
    AND "from" NOT IN (
        SELECT address FROM multisigs_list
        UNION ALL
        SELECT address FROM ldo_referral_payments_addr
        UNION ALL
        SELECT address FROM dai_referral_payments_addr  
        UNION ALL
        SELECT address FROM steth_referral_payments_addr
        UNION ALL
        select 0x0000000000000000000000000000000000000000
        UNION ALL
        SELECT address FROM diversifications_addresses    
    )    
    UNION ALL
    --ETH staked by DAO
    SELECT
        t.evt_block_time as period, 
        CAST(t.value AS DOUBLE) AS token_amount, 
        t.evt_tx_hash, 
        t.contract_address
    FROM  {{source('erc20_ethereum','evt_transfer')}} t
    join  {{source('lido_ethereum','steth_evt_Submitted')}} s on t.evt_tx_hash = s.evt_tx_hash
    WHERE t.contract_address = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84
    AND t.to in (select address from multisigs_list where chain = 'Ethereum' and name ='Aragon')
    AND t."from" = 0x0000000000000000000000000000000000000000
),

--Solana stSOL income--

stsol_income_txs AS (
    select 
        tx_id, 
        block_time AS period, 
        block_slot, 
        pre_token_balance, 
        post_token_balance, 
        token_balance_change AS delta
    FROM {{source('solana','account_activity')}}
    WHERE  block_time >= CAST('2021-11-01' AS TIMESTAMP)
    AND pre_token_balance IS NOT NULL
    AND token_mint_address =  '7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj'
    AND address =  'CYpYPtwY9QVmZsjCmguAud1ctQjXWKpWD7xeL5mnpcXk'
    AND token_balance_change > 0
    ORDER BY block_time DESC
),

stsol_income AS (
    SELECT  
            i.period AS period,
            '7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj' AS token,
            COALESCE(delta,0) AS amount_token,
            tx_id as evt_tx_hash
    FROM  stsol_income_txs i 
    
)

SELECT * from (
    SELECT
        evt_block_time AS period, 
        contract_address AS token,
        value AS amount_token,
        evt_tx_hash
    FROM other_income_txns
    
    UNION ALL
    --ETH inflow
    SELECT
        block_time AS time,
        0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 AS token,
        CAST(tr.value AS DOUBLE),
        tx_hash
    FROM {{source('ethereum','traces')}} tr
    WHERE tr.success = True
    AND tr.to in (
        SELECT 
            address 
        FROM multisigs_list 
        WHERE name IN ('Aragon','FinanceOpsMsig') AND chain = 'Ethereum'
    )
    AND tr."from" NOT IN ( 
        SELECT address FROM multisigs_list
        UNION ALL 
        SELECT address FROM diversifications_addresses    
    )
    AND tr.type='call'
    AND (tr.call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR tr.call_type IS NULL)
    
    UNION --stSOL to solana treasury
    SELECT
        period, 
        from_base64('7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj') AS token,
        amount_token,
        from_base64(evt_tx_hash)
    FROM stsol_income
) WHERE amount_token != 0
