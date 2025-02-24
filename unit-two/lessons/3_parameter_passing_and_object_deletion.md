# Parameter Passing and Object Deletion

## Parameter Passing (by `value`, `ref` and `mut ref`)

If you are familiar with rustlang, then you are probably familiar with the Rust ownership system. One advantage of movelang compared to Solidity is that you can get a sense of what a function call might do to the asset that you used for the function interaction. Here are some examples:

```move
use sui::object::{Self};

// You are allowed to retrieve the score but cannot modify it
public fun view_score(transcriptObject: &TranscriptObject): u8{
    transcriptObject.literature
}

// You are allowed to view and edit the score but not allowed to delete it
public fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
    transcriptObject.literature = score
}

// You are allowed to do anything with the score, including view, edit, or delete the entire transcript itself.
public fun delete_transcript(transcriptObject: TranscriptObject){
    let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
    object::delete(id);
}
```

## Object Deletion and Struct Unpacking

The `delete_transcript` method from the example above illustrates how to delete an object on Sui. 

1. In order to delete an object, you must first unpack the object and retrieve its object ID. Unpacking can only be done inside the module that defines the object due to Move's privileged struct operation rules:

- Struct types can only be created ("packed"), destroyed ("unpacked") inside the module that defines the struct
- The fields of a struct are only accessible inside the module that defines the struct

Following these rules, if you want to modify your struct outside its defining module, you will need to provide public methods for these operations. 

2. After unpacking the struct and retrieving its ID, the object can be deleted by simply calling the `object::delete` framework method on its object ID. 

*💡Note: the, `_`, underscore in the above method denotes unused variables or parameters. This will consume the variable or parameter immediately.*

**Here is the work-in-progress version of what we have written so far: [WIP transcript.move](../example_projects/transcript/sources/transcript_1.move_wip)**



