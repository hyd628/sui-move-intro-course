// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::transcript {

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Transcript {
        history: u8,
        math: u8,
        literature: u8,
    }

    struct TranscriptObject has key {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    struct WrappableTranscript has key, store {
        id: UID,
        history: u8,
        math: u8,
        literature: u8,
    }

    struct Folder has key {
        id: UID,
        transcript: WrappableTranscript,
        intended_address: address
    }

    public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let transcriptObject = TranscriptObject {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(transcriptObject, tx_context::sender(ctx))
    }

    public entry fun create_wrappable_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let wrappableTranscript = WrappableTranscript {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(wrappableTranscript, tx_context::sender(ctx))
    }

    // You are allowed to retrieve the score but cannot modify it
    public fun view_score(transcriptObject: &TranscriptObject): u8{
        transcriptObject.literature
    }

    // You are allowed to view and edit the score but not allowed to delete it
    public entry fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
        transcriptObject.literature = score
    }

    // You are allowed to do anything with the score, including view, edit, delete the entire transcript itself.
    public entry fun delete_transcript(transcriptObject: TranscriptObject){
        let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
        object::delete(id);
    }

    public entry fun request_transcript(transcript: WrappableTranscript, intended_address: address, ctx: &mut TxContext){
        let folderObject = Folder {
            id: object::new(ctx),
            transcript,
            intended_address
        };
        transfer::transfer(folderObject, tx_context::sender(ctx))
    }

    public entry fun unpack_wrapped_transcript(folder: Folder, ctx: &mut TxContext){
        // Check that the person unpacking the transcript is the intended viewer
        assert!(folder.intended_address == tx_context::sender(ctx), 0);
        let Folder {
            id,
            transcript,
            intended_address:_,
        } = folder;
        transfer::transfer(transcript, tx_context::sender(ctx));
        object::delete(id)
    }
}