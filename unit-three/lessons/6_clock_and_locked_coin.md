# Clock and Locked Coin Example

In the second fungible token example, we will introduce how to obtain time on-chain in Sui, and how to utilize that to implement a vesting mechanism for a coin. 

## Clock 

Sui Framework has a native [clock module](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/clock.md) that makes timestamps available in Move smart contracts. 

The main method that you will need to access is the following: 

```
public fun timestamp_ms(clock: &clock::Clock): u64
```

the [`timestamp_ms`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/clock.md#0x2_clock_timestamp_ms) function returns the current system timestamp, as a running total of milliseconds since an arbitrary point in the past.

The [`clock`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/clock.md#0x2_clock_Clock) object has a special reserved identifier, `0x6`, that needs to be passed into function calls using it as one of the inputs. 

## Locked Coin

Now that we know how to access time on-chain through `clock`, implementing a vesting fungible token is relatively straight forward. 

### `Locker` Custom Type

`locked_coin` builds on top of the `managed_coin` implementation with the addition of one more custom type, `Locker`:

```move
    /// Transferrable object for storing the vesting coins
    ///
    public struct Locker has key, store {
        id: UID,
        start_date: u64,
        final_date: u64,
        original_balance: u64,
        current_balance: Balance<LOCKED_COIN>

    }
```

Locker is a transferrable [asset](https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-one/lessons/3_custom_types_and_abilities.md#assets) that encodes the information related to the vesting schedule and vesting status of tokens issued. 

`start_date` and `final_date` are timestamps obtained from `clock`, marking the start and end of the vesting term.

`original_balance` is the initial balance issued into a `Locker`, `balance` is the current and remaining balance taking account any vested portion that's already withdrawn. 

### Minting

In the `locked_mint` method, we create and transfer a `Locker` with the specified amount of tokens and vesting scheduled encoded:

```move
    /// Mints and transfers a locker object with the input amount of coins and specified vesting schedule
    /// 
    public fun locked_mint(treasury_cap: &mut TreasuryCap<LOCKED_COIN>, recipient: address, amount: u64, lock_up_duration: u64, clock: &Clock, ctx: &mut TxContext){
        
        let coin = coin::mint(treasury_cap, amount, ctx);
        let start_date = clock::timestamp_ms(clock);
        let final_date = start_date + lock_up_duration;

        transfer::public_transfer(Locker {
            id: object::new(ctx),
            start_date: start_date,
            final_date: final_date,
            original_balance: amount,
            current_balance: coin::into_balance(coin)
        }, recipient);
    }
```

Note how `clock` is used here to get the current timestamp. 

### Withdrawing

The `withdraw_vested` method contains the majority of the logic to compute the vested amounts:

```move
    /// Withdraw the available vested amount assuming linear vesting
    ///
    public fun withdraw_vested(locker: &mut Locker, clock: &Clock, ctx: &mut TxContext){
        let total_duration = locker.final_date - locker.start_date;
        let elapsed_duration = clock::timestamp_ms(clock) - locker.start_date;
        let total_vested_amount = if (elapsed_duration > total_duration) {
            locker.original_balance
        } else {
            locker.original_balance * elapsed_duration / total_duration
        };
        let available_vested_amount = total_vested_amount - (locker.original_balance-balance::value(&locker.current_balance));
        transfer::public_transfer(coin::take(&mut locker.current_balance, available_vested_amount, ctx), sender(ctx))
    }
```

This example assumes a simple linear vesting schedule, but can be modified to accommodate a wide range of vesting logic and schedule. 

### Full Contract

You can find the full smart contract for our implementation of a [`locked_coin`](../example_projects/locked_coin/sources/locked_coin.move) under the [example_projects/locked_coin](../example_projects/locked_coin/) folder.
