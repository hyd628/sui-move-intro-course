# Sui Framework

A common use case for smart contracts is issuing custom fungible tokens (such as ERC-20 tokens on Ethereum). Let's take a look at how that can be done on Sui using the Sui Framework, and some variations on the classic fungible tokens.

## Sui Framework

[The Sui Framework](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/docs) is Sui's specific implementation of the Move VM. It contains Sui's native API's including its implementation of the Move standard library, as well as Sui-specific operations such as [crypto primitives](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/groth16.md) and Sui's implementation of [data structures](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/url.md) at the framework level. 

An implementation of a custom fungible token in Sui will heavily leverage some of the libraries in the Sui Framework. 

## `sui::coin`

The main library we will use to implement a custom fungible token on Sui is the [`sui::coin`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/coin.md) module. 

The resources or methods we will directly use in our fungible token example are:

- Resource: [Coin](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/coin.md#resource-coin)
- Resource: [TreasuryCap](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/coin.md#resource-treasurycap)
- Resource: [CoinMetadata](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/coin.md#resource-coinmetadata)
- Method: [coin::create_currency](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/coin.md#0x2_coin_create_currency)

We will revisit each of these in more depth after introducing some new concepts in the next few sections. 





