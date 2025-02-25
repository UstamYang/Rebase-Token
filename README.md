# Cross-chain Rebase Toekn

1. A protocal that allows user to deposit into a vault and in return, receiver rebase tokens that represent theire underlying balance.
2. Rebase toekn -> balanceOf function is dynamic to show the increasing balance with time.
   - Balace increases linearly with time.
   - mint tokens to our users every time they foerform an action (minting, burning, transferring, or ....bridging)
3. Interest rate
   - Undivually set an intersest rate or each user based on some global interest rate of the protocal at the time the user deposits onto the vault.
   - This global interest rate can only decrease to incetivise/reward early adopter.