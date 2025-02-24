# Functions

In this section, we will introduce functions in Sui Move and write our first Sui Move function as a part of the Hello World example. 

## Function Visibility

Sui Move functions have three types of visibility:

- **private**: the default visibility of a function; it can only be accessed by functions inside the same module
- **public**: the function is accessible by functions inside the same module and by functions defined in another module
- **public(package)**: the function is accessible by functions of modules inside the same package

## Return Value

The return type of a function is specified in the function signature after the function parameters, separated by a colon. 

A function's last line (of execution) without a semicolon is the return value. 

Example:

```move
    public fun addition (a: u8, b: u8): u8 {
        a + b    
    }
```

<!--
## Entry Functions

In Sui Move, entry functions are simply functions that can be called by transactions. They must satisfy the following three requirements:

- Denoted by the keyword `entry`
- have no return value
- (optional) have a mutable reference to an instance of the `TxContext` type in the last parameter

-->

## Transaction Context

Functions called directly through a transaction typically have an instance of `TxContext` as the last parameter. This is a special parameter set by the Sui Move VM and does not need to be specified by the user calling the function. 

The `TxContext` object contains [essential information](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/packages/sui-framework/sources/tx_context.move) about the transaction used to call the entry function, such as the sender's address, the tx's digest ID, the tx's epoch, etc. 

## Create the `mint` Function 

We can define our minting function in the Hello World example as the following:

```move
    public fun mint(ctx: &mut TxContext) {
        let object = HelloWorldObject {
            id: object::new(ctx),
            text: string::utf8(b"Hello World!")
        };
        transfer::public_transfer(object, tx_context::sender(ctx));
    }
```

This function simply creates a new instance of the `HelloWorldObject` custom type, then uses the Sui system [`public_transfer`](https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/sui/transfer.md#function-public_transfer) function to send it to the transaction caller. 

