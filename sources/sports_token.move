module sports_betting::sports_token {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};
    use std::option;

    // Public struct with drop ability
    public struct SPORTS_TOKEN has drop {}

    // Initialization function
    fun init(witness: SPORTS_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<SPORTS_TOKEN>(
            witness, 
            9,
            b"SPORTS",
            b"Sports Betting Token",
            b"Token for sports betting platform",
            option::none(),
            ctx
        );

        transfer::public_transfer(treasury_cap, sender(ctx));
        
        transfer::public_freeze_object(metadata);
    }

    // Public function to mint tokens
    public fun mint(
        treasury_cap: &mut TreasuryCap<SPORTS_TOKEN>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext
    ) {
        let coin = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(coin, recipient);
    }

    // Public function to burn tokens
    public fun burn(
        treasury_cap: &mut TreasuryCap<SPORTS_TOKEN>, 
        coin: Coin<SPORTS_TOKEN>
    ) {
        coin::burn(treasury_cap, coin);
    }

    public fun get_token(_witness: &SPORTS_TOKEN): u64 {
        1
    }
}