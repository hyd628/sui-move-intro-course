# The `Coin` Resource and `create_currency` Method

Now we know how generics and witness patterns work, let's revisit the `Coin` resource and the `create_currency` method.

## The `Coin` Resource

Now we understand how generics work. We can revisit the `Coin` resource from `sui::coin`.  It's [defined](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/coin.move#L28) as the following:

```move
public struct Coin<phantom T> has key, store {
        id: UID,
        balance: Balance<T>
    }
```

The `Coin` resource type is a struct that has a generic type `T` and two fields, `id` and `balance`. `id` is of the type `sui::object::UID`, which we have already seen before. 

`balance` is of the type [`sui::balance::Balance`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/balance.md#0x2_balance_Balance), and is [defined](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/balance.move#L29) as:

```move 
public struct Balance<phantom T> has store {
    value: u64
}
```

Recall our discussion on [`phantom`](./3_witness_design_pattern.md#the-phantom-keyword), The type `T` is used in `Coin` only as an argument to another phantom type for `Balance`, and in `Balance`, it's not used in any of its fields, thus `T` is a `phantom` type parameter. 

`Coin<T>` serves as a transferrable asset representation of a certain amount of the fungible token type `T` that can be transferred between addresses or consumed by smart contract function calls. 

## The `create_currency` Method

Let's look at what `coin::create_currency` actually does in its [source code](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/coin.move#L201):

```move
    public fun create_currency<T: drop>(
        witness: T,
        decimals: u8,
        symbol: vector<u8>,
        name: vector<u8>,
        description: vector<u8>,
        icon_url: Option<Url>,
        ctx: &mut TxContext
    ): (TreasuryCap<T>, CoinMetadata<T>) {
        // Make sure there's only one instance of the type T
        assert!(sui::types::is_one_time_witness(&witness), EBadWitness);

        // Emit Currency metadata as an event.
        event::emit(CurrencyCreated<T> {
            decimals
        });

        (
            TreasuryCap {
                id: object::new(ctx),
                total_supply: balance::create_supply(witness)
            },
            CoinMetadata {
                id: object::new(ctx),
                decimals,
                name: string::utf8(name),
                symbol: ascii::string(symbol),
                description: string::utf8(description),
                icon_url
            }
        )
    }
```

The assert checks that the `witness` resource passed in is a One Time Witness using the [`sui::types::is_one_time_witness`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/types.move) method from the Sui Framework. 

The method creates and returns two objects, one is the `TreasuryCap` resource and the other is a `CoinMetadata` resource. 

### `TreasuryCap`

The `TreasuryCap` is an asset and is guaranteed to be a singleton object by the One Time Witness pattern:

```move
    /// Capability allowing the bearer to mint and burn
    /// coins of type `T`. Transferable
    public struct TreasuryCap<phantom T> has key, store {
            id: UID,
            total_supply: Supply<T>
        }
```

It wraps a singleton field `total_supply` of type `Balance::Supply`:

```move
/// A Supply of T. Used for minting and burning.
    /// Wrapped into a `TreasuryCap` in the `Coin` module.
    public struct Supply<phantom T> has store {
        value: u64
    }
```

`Supply<T>` tracks the total amount of the given custom fungible token of type `T` currently circulating. You can see why this field must be a singleton, as having multiple `Supply` instances for a single token type makes no sense. 

### `CoinMetadata`

This is a resource that stores the metadata of the fungible token that has been created. It includes the following fields:

- `decimals`: the precision of this custom fungible token
- `name`: the name of this custom fungible token
- `symbol`: the token symbol of this custom fungible token
- `description`: the description of this custom fungible token
- `icon_url`: the URL to the icon file of this custom fungible token

The information contained in `CoinMetadata` can be thought of as a basic and lightweight fungible token standard of Sui, and can be used by wallets and explorers to display fungible tokens created using the `sui::coin` module. 
