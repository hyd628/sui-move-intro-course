# Object Wrapping Example

We will implement an example of object wrapping to our transcript example, so that `WrappableTranscript` is wrapped by a `Folder` object, and so that the `Folder` object can only be unpacked by, and thus the transcript inside only accessible by an intended address/viewer. 

## Modify `WrappableTranscript` and `Folder`

First, we need to make some adjustments to our two custom types `WrappableTranscript` and `Folder` from the previous section

1. We need to add the `key` ability to our type definitions for `WrappableTranscript`, so that they become assets and are transferrable. 

Remember that custom types with the abilities `key` and `store` are considered to be assets in Sui Move. 

```move
public struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
}
```

2. We need to add an additional field `intended_address` to the `Folder` struct that indicates the address of the intended viewer of the wrapped transcript. 

```move
public struct Folder has key {
    id: UID,
    transcript: WrappableTranscript,
    intended_address: address
}
```

## Request Transcript Method

```move
public fun request_transcript(transcript: WrappableTranscript, intended_address: address, ctx: &mut TxContext){
    let folderObject = Folder {
        id: object::new(ctx),
        transcript,
        intended_address
    };
    //We transfer the wrapped transcript object directly to the intended address
    transfer::transfer(folderObject, intended_address)
}
```

This method simply takes in a `WrappableTranscript` object and wraps it in a `Folder` object, and transfers the wrapped transcript to the intended address of the transcript. 

## Unwrap Transcript Method

```move
public fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext){
    // Check that the person unpacking the transcript is the intended viewer
    assert!(folder.intended_address == tx_context::sender(ctx), 0);
    let Folder {
        id,
        transcript,
        intended_address:_,
    } = folder;
    transfer::transfer(transcript, tx_context::sender(ctx));
    // Deletes the wrapper Folder object
    object::delete(id)
    }
```

This method unwraps the `WrappableTranscript` object from the `Folder` wrapper object if the method caller is the intended viewer of the transcript, and sends it to the method caller. 

*Quiz: Why do we need to delete the wrapper object here manually? What happens if we don't delete it?*

### Assert

We used the `assert!` syntax to verify that the address sending the transaction to unpack the transcript is the same as the `intended_address` field of the `Folder` wrapper object. 

the `assert!` macro takes in two parameters of the format:

```
assert!(<bool expression>, <code>)
```

where the boolean expression must evaluate to true, otherwise it will abort with error code `<code>`.

### Custom Errors

We are using a default 0 for our error code above, but we can also define a custom error constant in the following way:

```move
    const ENotIntendedAddress: u64 = 1;
```

This error code then can be consumed at the application level and handled appropriately. 

**Here is the second work-in-progress version of what we have written so far: [WIP transcript.move](../example_projects/transcript/sources/transcript_2.move_wip)**

