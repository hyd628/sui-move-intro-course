# Heterogeneous Collections

Homogeneous collections like `Vector` and `Table` can work for marketplaces (or other types of applications) where we need to hold a collection of objects of the same type, but what if we need to hold objects of different types, or if we do not know at compile time what types the objects we need to hold are going to be?

For this type of marketplace, we need to use a _heterogeneous_ collection to hold the items to be sold. Already having done the heavy lifting of understanding dynamic fields, heterogeneous collection in Sui should be very easy to understand. We will look at the `Bag` collection type more closely here. 

## The `Bag` Type

A `Bag` is a heterogeneous map-like collection. The collection is similar to `Table` in that its keys and values are not stored within the `Bag` value, but instead are stored using Sui's object system. The `Bag` struct acts only as a handle into the object system to retrieve those keys and values. 

### Common `Bag` Operations

Sample code of common `Bag` operations is included below: 

```move
module collection::bag {

    use sui::bag::{Bag, Self};
    use sui::tx_context::{TxContext};

    // Defining a table with generic types for the key and value 
    public struct GenericBag {
       items: Bag
    }

    // Create a new, empty GenericBag
    public fun create(ctx: &mut TxContext): GenericBag {
        GenericBag{
            items: bag::new(ctx)
        }
    }

    // Adds a key-value pair to GenericBag
    public fun add<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K, v: V) {
       bag::add(&mut bag.items, k, v);
    }

    /// Removes the key-value pair from the GenericBag with the provided key and returns the value.   
    public fun remove<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K): V {
        bag::remove(&mut bag.items, k)
    }

    // Borrows an immutable reference to the value associated with the key in GenericBag
    public fun borrow<K: copy + drop + store, V: store>(bag: &GenericBag, k: K): &V {
        bag::borrow(&bag.items, k)
    }

    /// Borrows a mutable reference to the value associated with the key in GenericBag
    public fun borrow_mut<K: copy + drop + store, V: store>(bag: &mut GenericBag, k: K): &mut V {
        bag::borrow_mut(&mut bag.items, k)
    }

    /// Check if a value associated with the key exists in the GenericBag
    public fun contains<K: copy + drop + store>(bag: &GenericBag, k: K): bool {
        bag::contains<K>(&bag.items, k)
    }

    /// Returns the size of the GenericBag, the number of key-value pairs
    public fun length(bag: &GenericBag): u64 {
        bag::length(&bag.items)
    }
}
```

The function signatures for interacting with Bag collections are very similar to the function signatures for interacting with Table collections. The main difference is that you don't need to declare any types when creating a new Bag, and the key-value pairs that you add to a Bag can be of different types.
