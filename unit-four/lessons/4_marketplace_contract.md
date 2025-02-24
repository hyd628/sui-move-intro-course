# Marketplace Contract

Now that we have a solid understanding of how various types of collections and dynamic fields work, we can start writing the contract for an on-chain marketplace that can support the following features:

- Listing of arbitrary item types and numbers
- Accepts payment in a custom or native fungible token type
- Can concurrently allow multiple sellers to list their items and securely receive payments

## Type Definitions

First, we define the overall `Marketplace` struct:

```move
    /// A shared `Marketplace`. Can be created by anyone using the
    /// `create` function. One instance of `Marketplace` accepts
    /// only one type of Coin - `COIN` for all its listings.
    public struct Marketplace<phantom COIN> has key {
        id: UID,
        items: Bag,
        payments: Table<address, Coin<COIN>>
    }
```

`Marketplace` will be a shared object that can be accessed and mutated by anyone. It accepts a `COIN` generic type parameter that defines what [fungible token](../../unit-three/lessons/4_the_coin_resource_and_create_currency.md) type the payments will be accepted in. 

The `items` field will hold item listings, which can be different types, thus we use the heterogeneous `Bag` collection here. 

The `payments` field will hold payments received by each seller. This can be represented by a key-value pair with the seller's address as the key and the coin type accepted as the value. Because the types for the key and value here are homogeneous and fixed, we can use the `Table` collection type for this field. 

_Quiz: How would you modify this struct to accept multiple fungible token types?_

Next, we define a `Listing` type:

```move
    /// A single listing that contains the listed item and its
    /// price in [`Coin<COIN>`].
    public struct Listing has key, store {
        id: UID,
        ask: u64,
        owner: address,
    }
```
This struct holds the information we need related to an item listing. We will attach the actual item to be traded to the `Listing` object as a dynamic object field, eliminating the need to define any item field or collection. 

Note that `Listing` has the `key` ability, so we are now able to use its object id as the key when we place it inside of a collection. 

## Listing and Delisting

Next, we write the logic for listing and delisting items. First, listing an item:

```move
   /// List an item at the Marketplace.
    public fun list<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item: T,
        ask: u64,
        ctx: &mut TxContext
    ) {
        let item_id = object::id(&item);
        let listing = Listing {
            ask,
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
        };

        ofield::add(&mut listing.id, true, item);
        bag::add(&mut marketplace.items, item_id, listing)
    }
```
As mentioned earlier, we will simply use the dynamic object field interface to attach the item of arbitrary type to be sold, and then we add the `Listing` object to the `Bag` of listings, using the object id of the item as the key, and the actual `Listing` object as the value (which is why `Listing` also has the `store` ability). 

For delisting, we define the following methods:

```move
   /// Internal function to remove listing and get an item back. Only owner can do that.
    fun delist<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        ctx: &mut TxContext
    ): T {
        let Listing {
            id,
            owner,
            ask: _,
        } = bag::remove(&mut marketplace.items, item_id);

        assert!(tx_context::sender(ctx) == owner, ENotOwner);

        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    /// Call [`delist`] and transfer item to the sender.
    public fun delist_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        ctx: &mut TxContext
    ) {
        let item = delist<T, COIN>(marketplace, item_id, ctx);
        transfer::public_transfer(item, tx_context::sender(ctx));
    }
```

Note how the delisted `Listing` object is unpacked and deleted, and the listed item object is retrieved through [`ofield::remove`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/dynamic_object_field.move#L71). Remember that Sui assets cannot be destroyed outside of their defining module, so we must transfer the item to the delister. 

## Purchasing and Payments

Buying an item is similar to delisting but with additional logic for handling payments. 

```move
    /// Internal function to purchase an item using a known Listing. Payment is done in Coin<C>.
    /// Amount paid must match the requested amount. If conditions are met,
    /// owner of the item gets the payment and buyer receives their item.
    fun buy<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        paid: Coin<COIN>,
    ): T {
        let Listing {
            id,
            ask,
            owner
        } = bag::remove(&mut marketplace.items, item_id);

        assert!(ask == coin::value(&paid), EAmountIncorrect);

        // Check if there's already a Coin hanging and merge `paid` with it.
        // Otherwise attach `paid` to the `Marketplace` under owner's `address`.
        if (table::contains<address, Coin<COIN>>(&marketplace.payments, owner)) {
            coin::join(
                table::borrow_mut<address, Coin<COIN>>(&mut marketplace.payments, owner),
                paid
            )
        } else {
            table::add(&mut marketplace.payments, owner, paid)
        };

        let item = ofield::remove(&mut id, true);
        object::delete(id);
        item
    }

    /// Call [`buy`] and transfer item to the sender.
    public fun buy_and_take<T: key + store, COIN>(
        marketplace: &mut Marketplace<COIN>,
        item_id: ID,
        paid: Coin<COIN>,
        ctx: &mut TxContext
    ) {
        transfer::transfer(
            buy<T, COIN>(marketplace, item_id, paid),
            tx_context::sender(ctx)
        )
    }

```

The first part is the same as delisting an item from listing, but we also check if the payment sent in is the right amount. The second part will insert the payment coin object into our `payments` `Table`, and depending on if the seller already has some balance, it will either do a simple `table::add` or `table::borrow_mut` and `coin::join` to merge the payment to existing balance. 

The entry function `buy_and_take` simply calls `buy` and transfers the purchased item to the buyer. 

### Taking Profit

Lastly, we define methods for sellers to retrieve their balance from the marketplace. 

```move
   /// Internal function to take profits from selling items on the `Marketplace`.
    fun take_profits<COIN>(
        marketplace: &mut Marketplace<COIN>,
        ctx: &mut TxContext
    ): Coin<COIN> {
        table::remove<address, Coin<COIN>>(&mut marketplace.payments, tx_context::sender(ctx))
    }

    /// Call [`take_profits`] and transfer Coin object to the sender.
    public fun take_profits_and_keep<COIN>(
        marketplace: &mut Marketplace<COIN>,
        ctx: &mut TxContext
    ) {
        transfer::transfer(
            take_profits(marketplace, ctx),
            tx_context::sender(ctx)
        )
    }
```

_Quiz: why do we not need to use [Capability](../../unit-two/lessons/6_capability_design_pattern.md) based access control under this marketplace design? Can we implement the capability design pattern here? What property would that give to the marketplace?_

## Full Contract

You can find the full smart contract for our implementation of a generic marketplace under the [`example_projects/marketplace`](../example_projects/marketplace/sources/marketplace.move) folder.
