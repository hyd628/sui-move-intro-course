# Homogeneous Collections 

Before we delve into the main topic of building a marketplace on Sui, let's learn about collections in Move first. 

## vectors

`Vector` in Move is similar to those in other languages such as C++. It's a way to dynamically allocate memory at runtime and manage a group of a single type, which can be a specific type or a [generic type](../../unit-three/lessons/2_intro_to_generics.md). 

See the included example code for defining a `vector` and its basic operations. 

```move
module collection::vector {

    use std::vector;

    public struct Widget {
    }

    // Vector for a specified  type
    public struct WidgetVector {
        widgets: vector<Widget>
    }

    // Vector for a generic type 
    public struct GenericVector<T> {
        values: vector<T>
    }

    // Creates a GenericVector that holds a generic type T
    public fun create<T>(): GenericVector<T> {
        GenericVector<T> {
            values: vector::empty<T>()
        }
    }

    // Push a value of type T into a GenericVector
    public fun put<T>(vec: &mut GenericVector<T>, value: T) {
        vector::push_back<T>(&mut vec.values, value);
    }

    // Pops a value of type T from a GenericVector
    public fun remove<T>(vec: &mut GenericVector<T>): T {
        vector::pop_back<T>(&mut vec.values)
    }

    // Returns the size of a given GenericVector
    public fun size<T>(vec: &mut GenericVector<T>): u64 {
        vector::length<T>(&vec.values)
    }
}

```

It's important to note that while a vector defined with a generic type can accept objects of _an arbitrary type_, all objects in the collection still must be _the same type_, that is, the collection is _homogeneous_. 

## Table

A `Table` is a map-like collection that dynamically stores key-value pairs. But unlike a traditional map collection, its keys and values are not stored within the `Table` value, but instead are stored using Sui's object system. The `Table` struct acts only as a handle into the object system to retrieve those keys and values. 

The `key` type of a `Table` must have the ability constraint of `copy + drop + store`, and the `value` type must have the ability constraint of `store`. 

`Table` is also a type of _homogeneous_ collection where the key and value fields can be specified or generic types, but all values and all keys in a `Table` collection must be of the _same_ type. 

*Quiz: Would two table objects containing the exact same key-value pairs be equal to each other when checked with the `===` operator? Try it out.*

See the below example for working with `Table` collections:

```move
module collection::table {

    use sui::table::{Table, Self};
    use sui::tx_context::{TxContext};

    // Defining a table with specified types for the key and value
    public struct IntegerTable {
        table_values: Table<u8, u8>
    }

    // Defining a table with generic types for the key and value 
    public struct GenericTable<phantom K: copy + drop + store, phantom V: store> {
        table_values: Table<K, V>
    }

    // Create a new, empty GenericTable with key type K, and value type V
    public fun create<K: copy + drop + store, V: store>(ctx: &mut TxContext): GenericTable<K, V> {
        GenericTable<K, V> {
            table_values: table::new<K, V>(ctx)
        }
    }

    // Adds a key-value pair to GenericTable
    public fun add<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K, v: V) {
        table::add(&mut table.table_values, k, v);
    }

    /// Removes the key-value pair in the GenericTable `table: &mut Table<K, V>` and returns the value.   
    public fun remove<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K): V {
        table::remove(&mut table.table_values, k)
    }

    // Borrows an immutable reference to the value associated with the key in GenericTable
    public fun borrow<K: copy + drop + store, V: store>(table: &GenericTable<K, V>, k: K): &V {
        table::borrow(&table.table_values, k)
    }

    /// Borrows a mutable reference to the value associated with the key in GenericTable
    public fun borrow_mut<K: copy + drop + store, V: store>(table: &mut GenericTable<K, V>, k: K): &mut V {
        table::borrow_mut(&mut table.table_values, k)
    }

    /// Check if a value associated with the key exists in the GenericTable
    public fun contains<K: copy + drop + store, V: store>(table: &GenericTable<K, V>, k: K): bool {
        table::contains<K, V>(&table.table_values, k)
    }

    /// Returns the size of the GenericTable, the number of key-value pairs
    public fun length<K: copy + drop + store, V: store>(table: &GenericTable<K, V>): u64 {
        table::length(&table.table_values)
    }

}
```
