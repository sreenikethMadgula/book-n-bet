module sports_betting::game_ticket_nft {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};
    use std::string::String;

    // Public struct with key and store abilities
    public struct GameTicketNFT has key, store {
        id: UID,
        game_id: u64,
        seat_number: String,
        event_date: String,
        team_names: String
    }

    // Public function to mint a new game ticket NFT
    public fun mint_ticket(
        game_id: u64,
        seat_number: String,
        event_date: String,
        team_names: String,
        ctx: &mut TxContext
    ): GameTicketNFT {
        GameTicketNFT {
            id: object::new(ctx),
            game_id,
            seat_number,
            event_date,
            team_names
        }
    }

    // Public function to transfer ticket to another address
    public fun transfer_ticket(
        ticket: GameTicketNFT, 
        recipient: address
    ) {
        transfer::transfer(ticket, recipient);
    }

    // Public function to burn ticket if needed
    public fun burn_ticket(ticket: GameTicketNFT) {
        let GameTicketNFT { id, game_id: _, seat_number: _, event_date: _, team_names: _ } = ticket;
        object::delete(id);
    }
}