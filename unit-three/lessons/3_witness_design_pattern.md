# The Witness Design Pattern

Next, we need to understand the witness pattern to peek under the hood of how a fungible token is implemented in Sui Move. 

Witness is a design pattern used to prove that the resource or type in question, `A`, can be initiated only once after the ephemeral `witness` resource has been consumed. The `witness` resource must be immediately consumed or dropped after use, ensuring that it cannot be reused to create multiple instances of `A`.

## Witness Pattern Example

In the below example, the `witness` resource is `PEACE`, while the type `A` that we want to control the instantiation of is `Guardian`. 

The `witness` resource type must have the `drop` keyword so that this resource can be dropped after being passed into a function. We see that the instance of `PEACE` resource is passed into the `create_guardian` method and dropped (note the underscore before `witness`), ensuring that only one instance of `Guardian` can be created.

```move
    /// Module that defines a generic type `Guardian<T>` which can only be
    /// instantiated with a witness.
    module witness::peace {
        use sui::object::{Self, UID};
        use sui::transfer;
        use sui::tx_context::{Self, TxContext};

        /// Phantom parameter T can only be initialized in the `create_guardian`
        /// function. But the types passed here must have `drop`.
        public struct Guardian<phantom T: drop> has key, store {
            id: UID
        }

        /// This type is the witness resource and is intended to be used only once.
        public struct PEACE has drop {}

        /// The first argument of this function is an actual instance of the
        /// type T with `drop` ability. It is dropped as soon as received.
        public fun create_guardian<T: drop>(
            _witness: T, ctx: &mut TxContext
        ): Guardian<T> {
            Guardian { id: object::new(ctx) }
        }

        /// Module initializer is the best way to ensure that the
        /// code is called only once. With `Witness` pattern it is
        /// often the best practice.
        fun init(witness: PEACE, ctx: &mut TxContext) {
            transfer::transfer(
                create_guardian(witness, ctx),
                tx_context::sender(ctx)
            )
        }
    }
```

*The example above is modified from the excellent book [Sui Move by Example](https://examples.sui.io/patterns/witness.html) by [Damir Shamanaev](https://github.com/damirka).*

### The `phantom` Keyword

In the above example, we want the `Guardian` type to have the `key` and `store` abilities, so that it's an asset and is transferrable and persists in global storage. 

We also want to pass in the `witness` resource, `PEACE`, into `Guardian`, but `PEACE` only has the `drop` ability. Recall our previous discussion on [ability constraints](./2_intro_to_generics.md#ability-constraints) and inner types, the rule implies that `PEACE` should also have `key` and `storage` given that the outer type `Guardian` does. But in this case, we do not want to add unnecessary abilities to our `witness` type, because doing so could cause undesirable behaviors and vulnerabilities. 

We can use the keyword `phantom` to get around this situation. When a type parameter is either not used inside the struct definition or is only used as an argument to another `phantom` type parameter, we can use the `phantom` keyword to ask the Move type system to relax the ability constraint rules on inner types. We see that `Guardian` doesn't use the type `T` in any of its fields, so we can safely declare `T` to be a `phantom` type. 

For a more in-depth explanation of the `phantom` keyword, please check the [relevant section](https://github.com/move-language/move/blob/main/language/documentation/book/src/generics.md#phantom-type-parameters) of the Move language documentation.

## One Time Witness

One Time Witness (OTW) is a sub-pattern of the Witness pattern, where we utilize the module `init` function to ensure that only one instance of the `witness` resource is created (so type `A` is guaranteed to be a singleton). 

In Sui Move a type is considered an OTW if its definition has the following properties:

- The type is named after the module but uppercased
- The type only has the `drop` ability

To get an instance of this type, you need to add it as the first argument to the module `init` function as in the above example. The Sui runtime will then generate the OTW struct automatically at module publish time. 

The above example uses the One Time Witness design pattern to guarantee that `Guardian` is a singtleton.
