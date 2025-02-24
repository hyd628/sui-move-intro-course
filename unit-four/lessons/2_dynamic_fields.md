# Dynamic Fields

To peek under how collections like `Table` are actually implemented in Sui Move, we need to introduce the concept of dynamic fields in Sui Move. Dynamic fields are heterogeneous fields that can be added or removed at runtime, and can have arbitrary user-assigned names. 

There are two sub-types of dynamic fields: 

  - **Dynamic Fields** can store any value that has the `store` ability, however, an object stored in this kind of field will be considered wrapped and will not be accessible directly via its ID by external tools (explorers, wallets, etc) accessing storage.
  - **Dynamic Object Fields** values *must* be Sui objects (have the `key` and `store` abilities, and `id: UID` as the first field), but will still be directly accessible via their object ID after being attached.

## Dynamic Field Operations

### Adding a Dynamic Field

To illustrate how to work with dynamic fields, we define the following structs:

```move
   // Parent struct
    public struct Parent has key {
        id: UID,
    }

    // Dynamic field child struct type containing a counter
    public struct DFChild has store {
        count: u64
    }

    // Dynamic object field child struct type containing a counter
    public struct DOFChild has key, store {
        id: UID,
        count: u64,
    }
```

Here's the API to use for adding **dynamic fields** or **dynamic object fields** to an object:

```move
  module collection::dynamic_fields {

      use sui::dynamic_object_field as ofield;
      use sui::dynamic_field as field;

    // Adds a DFChild to the parent object under the provided name
    public fun add_dfchild(parent: &mut Parent, child: DFChild, name: vector<u8>) {
        field::add(&mut parent.id, name, child);
    }

    // Adds a DOFChild to the parent object under the provided name
    public fun add_dofchild(parent: &mut Parent, child: DOFChild, name: vector<u8>) {
        ofield::add(&mut parent.id, name, child);
    } 
  }
```

### Accessing and Mutating a Dynamic Field

Dynamic fields and dynamic object fields can be read or accessed as the following:

```move
    // Borrows a reference to a DOFChild
    public fun borrow_dofchild(child: &DOFChild): &DOFChild {
        child
    }

    // Borrows a reference to a DFChild via its parent object
    public fun borrow_dfchild_via_parent(parent: &Parent, child_name: vector<u8>): &DFChild {
        field::borrow<vector<u8>, DFChild>(&parent.id, child_name)
    }

    // Borrows a reference to a DOFChild via its parent object
    public fun borrow_dofchild_via_parent(parent: &Parent, child_name: vector<u8>): &DOFChild {
        ofield::borrow<vector<u8>, DOFChild>(&parent.id, child_name)
    }
```

Dynamic fields and dynamic object fields can also be mutated as the following:

```move
    // Mutate a DOFChild directly
    public fun mutate_dofchild(child: &mut DOFChild) {
        child.count = child.count + 1;
    }

    // Mutate a DFChild directly
    public fun mutate_dfchild(child: &mut DFChild) {
        child.count = child.count + 1;
    }

    // Mutate a DFChild's counter via its parent object
    public fun mutate_dfchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
        child.count = child.count + 1;
    }

    // Mutate a DOFChild's counter via its parent object
    public fun mutate_dofchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        mutate_dofchild(ofield::borrow_mut<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        ));
    }
```
*Quiz: Why can `mutate_dofchild` be an entry function but not `mutate_dfchild`?* 

### Removing a Dynamic Field

We can remove a dynamic field from its parent object as follows:

```move
    // Removes a DFChild given its name and parent object's mutable reference, and returns it by value
    public fun remove_dfchild(parent: &mut Parent, child_name: vector<u8>): DFChild {
        field::remove<vector<u8>, DFChild>(&mut parent.id, child_name)
    }

    // Deletes a DOFChild given its name and parent object's mutable reference
    public fun delete_dofchild(parent: &mut Parent, child_name: vector<u8>) {
        let DOFChild { id, count: _ } = ofield::remove<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        );
        object::delete(id);
    }

    // Removes a DOFChild from the parent object and transfers it to the caller
    public fun reclaim_dofchild(parent: &mut Parent, child_name: vector<u8>, ctx: &mut TxContext) {
        let child = ofield::remove<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        );
        transfer::transfer(child, tx_context::sender(ctx));
    }
```

Note that in the case of a dynamic object field, we can delete or transfer it after removing its attachment to another object, as a dynamic object field is a Sui object. But we cannot do the same with a dynamic field, as it does not have the `key` ability and is not a Sui object. 

## Dynamic Field vs. Dynamic Object Field

When should you use a dynamic field versus a dynamic object field? Generally speaking, we want to use dynamic object fields when the child type in question has the `key` ability and use dynamic fields otherwise. 

For a full explanation of the underlying reason, please check [this forum post](https://forums.sui.io/t/dynamicfield-vs-dynamicobjectfield-why-do-we-have-both/2095) by @sblackshear.  

## Revisiting `Table`

Now we understand how dynamic fields work, we can think of the `Table` collection as a thin wrapper around dynamic field operations. 

You can look through the [source code](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/table.move) of the `Table` type in Sui as an exercise, and see how each of the previously introduced operations map to dynamic field operations and with some additional logic to keep track of the size of the `Table`. 
