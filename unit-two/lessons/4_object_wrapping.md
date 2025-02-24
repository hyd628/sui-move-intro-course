# Object Wrapping

There are multiple ways of nesting an object inside of another object in Sui Move. The first way we will introduce is called object wrapping. 

Let's continue our transcript example. We define a new `WrappableTranscript` type, and the associated wrapper type `Folder`.  

```move
public struct WrappableTranscript has store {
    history: u8,
    math: u8,
    literature: u8,
}

public struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
}
```

In the above example, `Folder` wraps `WrappableTranscript`, and `Folder` is addressable through its id as it has the `key` ability. 

## Object Wrapping Properties

For a struct type to be capable of being embedded in a Sui object struct, which will generally have the `key` ability, the embedded struct type must have the `store` ability.

When an object is wrapped, the wrapped object is no longer accessible independently via object ID. Instead it would just be parts of the wrapper object itself. More importantly, the wrapped object can no longer be passed as an argument in Move calls, and the only access point is through the wrapper object. 

Because of this property, object wrapping can be used as a way to make an object inaccessible outside of specific contract calls. For further info about Object wrapping, go check out [here](https://docs.sui.io/devnet/build/programming-with-objects/ch4-object-wrapping). 
