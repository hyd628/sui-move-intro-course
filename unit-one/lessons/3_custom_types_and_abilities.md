# Custom Types and Abilities

In this section, we will start creating our Hello World example contract step by step and explain fundamental concepts in Sui Move as they come up, such as custom types and abilities. 

## Initializing the Package

(If you skipped the previous section) You can initialize a Hello World Sui package with the following command in the command line after [installing Sui binaries](./1_set_up_environment.md#install-sui-binaries-locally):

`sui move new hello_world`

## Create the Contract Source File

Use an editor of your choice to create a Move smart contract source file called `hello.move` under the `sources` subfolder. 

And create the empty module as follows:

```move
module hello_world::hello_world;
    // module contents
```

### Import Statements

You can directly import modules in Move by their address, but to make code easier to read, we can organize imports with the keyword `use`. 

```move
use <Address/Alias>::<ModuleName>;
```

In our example, we need to import the following modules:

```move
use std::string;
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
```

## Custom Types

A structure in Sui Move is a custom type that contains key-value pairs, where the key is the name of a property, and the value is what's stored. Defined using the keyword `struct`, a structure can have up to 4 abilities.

### Abilities

Abilities are keywords in Sui Move that define how types behave at the compiler level. 

Abilities are crucial to defining how objects behave in Sui Move at the language level. Each unique combination of abilities in Sui Move is its own design pattern. We will study abilities and how to use them in Sui Move throughout the course.

For now, just know that there are four abilities in Sui Move:

- **copy**: value can be copied (or cloned by value)
- **drop**: value can be dropped by the end of the scope
- **key**: value can be used as a key for global storage operations
- **store**: value can be held inside a struct in global storage

#### Assets

Custom types that have the abilities `key` and `store` are considered to be **assets** in Sui Move. Assets are stored in global storage and can be transferred between accounts.  

### Hello World Custom Type

We define the object in our Hello World example as the following:

```move
/// An object that contains an arbitrary string
public struct HelloWorldObject has key, store {
  	id: UID,
  	/// A string contained in the object
  	text: string::String
}
```

UID here is a Sui Framework type (sui::object::UID) that defines the globally unique ID of an object. Any custom type with the `key` ability is required to have an ID field. 

