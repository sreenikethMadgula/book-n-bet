module sports_betting::betting_contract {
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{TxContext, sender};
    use std::option::{Option, some, none};
    use std::vector;

    use sports_betting::sports_token::SPORTS_TOKEN;

    // Public struct for Bet with key and store abilities
    public struct Bet has key, store {
        id: UID,
        game_id: u64,
        bettor: address,
        bet_amount: u64,
        bet_type: u8,  // 0: Team A, 1: Team B, 2: Draw
        payout: Option<u64>
    }

    // Public struct for GameBettingPool with key and store abilities
    public struct GameBettingPool has key, store {
        id: UID,
        game_id: u64,
        total_pool: Balance<SPORTS_TOKEN>,
        bets: vector<Bet>
    }

    // Public function to create a new betting pool for a game
    public fun create_betting_pool(
        game_id: u64,
        ctx: &mut TxContext
    ) {
        let betting_pool = GameBettingPool {
            id: object::new(ctx),
            game_id,
            total_pool: balance::zero(),
            bets: vector::empty()
        };
        
        transfer::public_share_object(betting_pool);
    }

    // Public function to place a bet in the pool
    public fun place_bet(
        pool: &mut GameBettingPool,
        bet_token: Coin<SPORTS_TOKEN>,
        bet_type: u8,
        ctx: &mut TxContext
    ) {
        let bet_amount = coin::value(&bet_token);
        
        let bet = Bet {
            id: object::new(ctx),
            game_id: pool.game_id,
            bettor: sender(ctx),
            bet_amount,
            bet_type,
            payout: none()
        };

        vector::push_back(&mut pool.bets, bet);
        balance::join(&mut pool.total_pool, coin::into_balance(bet_token));
    }

    // Public function to resolve bets after game outcome
    public fun resolve_bets(
        pool: &mut GameBettingPool,
        winning_type: u8,
        ctx: &mut TxContext
    ) {
        let mut total_winning_pool: u64 = 0;
        let mut winning_bet_indices: vector<u64> = vector::empty();

        let mut i = 0;
        while (i < vector::length(&pool.bets)) {
            let bet = vector::borrow(&pool.bets, i);
            if (bet.bet_type == winning_type) {
                total_winning_pool = total_winning_pool + bet.bet_amount;
                vector::push_back(&mut winning_bet_indices, i);
            };
            i = i + 1;
        };

        if (total_winning_pool == 0) {
            return
        };

        let total_pool_value = balance::value(&pool.total_pool);

        let mut j = 0;
        while (j < vector::length(&winning_bet_indices)) {
            let winner_bet_index = *vector::borrow(&winning_bet_indices, j);
            let winner_bet = vector::borrow(&pool.bets, winner_bet_index);
            
            // Formula: (total_pool_value * winner_bet_amount) / total_winning_pool
            let payout = if (total_winning_pool > 0) {
                (total_pool_value * winner_bet.bet_amount) / total_winning_pool
            } else {
                0
            };
            
            vector::borrow_mut(&mut pool.bets, winner_bet_index).payout = some(payout);

            j = j + 1;
        };
    }
}