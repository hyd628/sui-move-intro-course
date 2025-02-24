# Working with Sui Objects

## Introduction

Sui Move is a fully object-centric language. Transactions on Sui are expressed as operations where the inputs and outputs are both objects. As we briefly touched on this concept in [Unit One, Lesson 4](../../unit-one/lessons/4_custom_types_and_abilities.md#custome-types-and-abilities), Sui objects are the basic unit of storage in Sui. It all starts from the `struct` keyword.

Let's first start with an example that represents a transcript recording a student's grades:

```move
public struct Transcript {
    history: u8,
    math: u8,
    literature: u8,
}
```

The above definition is a regular Move struct, but it is not a Sui object. In order to make a custom Move type instantiate a Sui object in global storage, we need to add the `key` ability, and a globally unique `id: UID` field inside the struct definition. 

```move
use sui::object::{UID};

public struct TranscriptObject has key {
    id: UID,
    history: u8,
    math: u8,
    literature: u8,
}
```

## Create a Sui Object

Creating a Sui object requires a unique ID. We use the `sui::object::new` function to create a new ID passing in the current `TxContext`. 

In Sui, every object must have an owner, which can be either an address, another object, or "shared". In our examples, we decided to make our new `transcriptObject` owned by the transaction sender. It is done using the `transfer` function of the Sui framework and using `tx_context::sender` function to get the current entry call's sender's address.  

We will discuss object ownership more in-depth in the next section. 

```move
public fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
  let transcriptObject = TranscriptObject {
    id: object::new(ctx),
    history,
    math,
    literature,
  };
  transfer::transfer(transcriptObject, tx_context::sender(ctx))
}
```

*💡Note: the provided sample code generates a warning message: warning[Lint W01001]: non-composable transfer to sender. For further details, refer to the article ("Sui Linters and Warnings Update Increases Coder Velocity")[https://blog.sui.io/linter-compile-warnings-update/]*

*💡Note: Move supports field punning, which allows us to skip the field values if the field name happens to be the same as the name of the value variable it is bound to.*

