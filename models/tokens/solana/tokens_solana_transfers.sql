 {{
  config(
        schema = 'tokens_solana',
        alias = 'transfers',
        materialized = 'incremental',
        file_format = 'delta',
        incremental_strategy = 'merge',
        partition_by = ['block_date'],
        incremental_predicates = [incremental_predicate('DBT_INTERNAL_DEST.block_time')],
        unique_key = ['tx_id','outer_instruction_index','inner_instruction_index', 'block_slot'],
        post_hook='{{ expose_spells(\'["solana"]\',
                                    "sector",
                                    "tokens",
                                    \'["ilemi"]\') }}')
}}

with 
token2022_fee_state as (
      --we need the fee basis points and maximum fee for token2022 transfers because the fee amount is not emitted in transferChecked
      SELECT 
      call_account_arguments[1] as account_mint
      , try(bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,
                  1+1+1+1+1+case when bytearray_substring(call_data,1+1+1,1) = 0x01 and bytearray_substring(call_data,1+1+1+32+1,1) = 0x01
                              then 64
                              when bytearray_substring(call_data,1+1+1,1) = 0x01 and bytearray_substring(call_data,1+1+1+32+1,1) = 0x00
                              then 32
                              when bytearray_substring(call_data,1+1+1,1) = 0x00 and bytearray_substring(call_data,1+1+1+1,1) = 0x01
                              then 32
                              when bytearray_substring(call_data,1+1+1,1) = 0x00 and bytearray_substring(call_data,1+1+1+1,1) = 0x00
                              then 0
                              end --variations of COPTION enums for first two arguments
                  ,2)))) as fee_basis
      , try(bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,
                  1+1+1+1+1+case when bytearray_substring(call_data,1+1+1,1) = 0x01 and bytearray_substring(call_data,1+1+1+32+1,1) = 0x01
                              then 64
                              when bytearray_substring(call_data,1+1+1,1) = 0x01 and bytearray_substring(call_data,1+1+1+32+1,1) = 0x00
                              then 32
                              when bytearray_substring(call_data,1+1+1,1) = 0x00 and bytearray_substring(call_data,1+1+1+1,1) = 0x01
                              then 32
                              when bytearray_substring(call_data,1+1+1,1) = 0x00 and bytearray_substring(call_data,1+1+1+1,1) = 0x00
                              then 0
                              end
                        +2
                  ,16)))) as fee_maximum
      , call_block_time as fee_time
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_transferFeeExtension') }}
      WHERE bytearray_substring(call_data,1+1,1) = 0x00 --https://github.com/solana-labs/solana-program-library/blob/8f50c6fabc6ec87ada229e923030381f573e0aed/token/program-2022/src/extension/transfer_fee/instruction.rs#L38
      UNION ALL 
      SELECT 
      call_account_arguments[1] as account_mint
      , try(bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,
                  1+1+1,2)))) as fee_basis
      , try(bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,
                  1+1+1+2,16)))) as fee_maximum
      , call_block_time as fee_time
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_transferFeeExtension') }}
      WHERE bytearray_substring(call_data,1+1,1) = 0x05 --https://github.com/solana-labs/solana-program-library/blob/8f50c6fabc6ec87ada229e923030381f573e0aed/token/program-2022/src/extension/transfer_fee/instruction.rs#L147
)

, base as (  
      SELECT 
            account_source, account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'transfer' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_transfer') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            account_source, account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'transfer' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_transferChecked') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            null as account_source, account_account as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'mint' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_mintTo') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            null as account_source, account_account as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'mint' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_mintToChecked') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            account_account as account_source, null as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'burn' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_burn') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            account_account as account_source, null as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'burn' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'spl_token' as token_version
      FROM {{ source('spl_token_solana','spl_token_call_burnChecked') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      --token2022. Most mint and account extensions still use the parent transferChecked instruction, hooks are excecuted after and interest-bearing is precalculated.
      UNION ALL

      SELECT 
            account_source, account_destination, amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , action
            , call_outer_instruction_index, call_inner_instruction_index
            , fee
            , token_version
      FROM (
            SELECT 
                  account_source, account_destination
                  , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount --note that interestbearing mints have a different amount methodology, to add later
                  , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
                  , 'transfer' as action
                  , call_outer_instruction_index, call_inner_instruction_index
                  , least(
                        cast(bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as double)
                              *cast(f.fee_basis as double)/10000
                        ,f.fee_maximum) as fee --we want to take the percent fee on total amount, but not exceed the maximum fee
                  , 'token2022' as token_version
                  , f.fee_time
                  , row_number() over (partition by tr.call_tx_id,  tr.call_outer_instruction_index,  tr.call_inner_instruction_index order by f.fee_time desc) as latest_fee
            FROM {{ source('spl_token_2022_solana','spl_token_2022_call_transferChecked') }} tr
            LEFT JOIN token2022_fee_state f ON tr.account_tokenMint = f.account_mint AND tr.call_block_time >= f.fee_time
            WHERE 1=1 
            {% if is_incremental() %}
            AND {{incremental_predicate('tr.call_block_time')}}
            {% endif %}
      ) WHERE latest_fee = 1

      UNION ALL

      SELECT 
            null as account_source, account_mintTo as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'mint' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'token2022' as token_version
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_mintTo') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT
            null as account_source, account_mintTo as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'mint' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'token2022' as token_version
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_mintToChecked') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            account_burnAccount as account_source, null as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'burn' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'token2022' as token_version
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_burn') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      UNION ALL

      SELECT 
            account_burnAccount as account_source, null as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+1,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'burn' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , null as fee
            , 'token2022' as token_version
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_burnChecked') }}
      WHERE 1=1 
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}

      --token2022 transferFeeExtension has some extra complications. It's the only extension with its own transferChecked wrapper (confidential transfers will have this too)      
      UNION ALL

      SELECT 
            call_account_arguments[1] as account_source, call_account_arguments[3] as account_destination
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data,1+2,8))) as amount
            , call_tx_id, call_block_time, call_block_slot, call_outer_executing_account, call_tx_signer
            , 'transfer' as action
            , call_outer_instruction_index, call_inner_instruction_index
            , bytearray_to_uint256(bytearray_reverse(bytearray_substring(call_data, 1+2+8+1,8))) as fee
            , 'token2022' as token_version
      FROM {{ source('spl_token_2022_solana','spl_token_2022_call_transferFeeExtension') }}
      WHERE bytearray_substring(call_data,1,2) = 0x1a01 --https://github.com/solana-labs/solana-program-library/blob/8f50c6fabc6ec87ada229e923030381f573e0aed/token/program-2022/src/extension/transfer_fee/instruction.rs#L284
      {% if is_incremental() %}
      AND {{incremental_predicate('call_block_time')}}
      {% endif %}
) 

SELECT
    call_block_time as block_time
    , cast (date_trunc('day', call_block_time) as date) as block_date
    , call_block_slot as block_slot
    , action
    , amount
    , fee
    , COALESCE(tk_s.token_mint_address, tk_d.token_mint_address) as token_mint_address
    , tk_s.token_balance_owner as from_owner
    , tk_d.token_balance_owner as to_owner
    , account_source as from_token_account
    , account_destination as to_token_account
    , token_version
    , call_tx_signer as tx_signer
    , call_tx_id as tx_id
    , call_outer_instruction_index as outer_instruction_index
    , COALESCE(call_inner_instruction_index,0) as inner_instruction_index
    , call_outer_executing_account as outer_executing_account
FROM base tr
--get token and accounts
LEFT JOIN {{ ref('solana_utils_token_accounts') }} tk_s ON tk_s.address = tr.account_source 
LEFT JOIN {{ ref('solana_utils_token_accounts') }} tk_d ON tk_d.address = tr.account_destination
WHERE 1=1
-- AND call_block_time > now() - interval '90' day --for faster CI testing