# Types of Ownership of Sui Objects

Each object in Sui has an owner field that indicates how this object is being owned. In Sui Move, there are a total of four types of ownership.

- Owned
    - Owned by an address
    - Owned by another object 
- Shared
    - Shared immutable
    - Shared mutable

## Owned Objects

The first two types of ownership fall under the `Owned Objects` category. Owned objects in Sui are processed differently from shared objects and do not require global ordering. 

### Owned by an Address

Let's continue using our `transcript` example here. This type of ownership is pretty straightforward as the object is owned by an address to which the object is transferred upon object creation, such as in the above example at this line:

```move
    transfer::transfer(transcriptObject, tx_context::sender(ctx)) // where tx_context::sender(ctx) is the recipient
```

where the `transcriptObject` is transferred to the address of the transaction sender upon creation.

### Owned by An Object

In order for an object to be owned by another object, it is done using `dynamic_object_field`, which we will explore in a future section. Basically, when an object is owned by another object, we will call it a child object. A child object is able to be looked up in global storage using its object ID.

## Shared Objects

## Shared Immutable Objects

Certain objects in Sui cannot be mutated by anyone, and because of this, these objects do not have an exclusive owner. All published packages and modules in Sui are immutable objects. 

To make an object immutable manually, one can call the following special function:

```move
    transfer::freeze_object(obj);
```

## Shared Mutable Objects

Shared objects in Sui can be read or mutated by anyone. Shared object transactions require global ordering through a consensus layer protocol, unliked owned objects. 

To create a shared object, one can call this method:

```move
    transfer::share_object(obj);
```

Once an object is shared, it stays mutable and can be accessed by anyone to send a transaction to mutate the object. 

