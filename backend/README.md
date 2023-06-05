# Prediction Markets Using dAPIs

This specific project only targets tokens tradable and not real-world political/geographical events.

Implementing Prediction Markets by allowing users to create new predictions or trade available predictions.
dAPIs are the source of settling the predictions after the time has surpassed for a given prediction.

### Business Model

There are two ways the platform is able to sustain itself :

1. Trading fee from the user. This includes buying the bet tokens, swapping them or selling them if the user wants to get their investment back. (NOTE: If the deadline passes the people cant back off and the tokens can't be swapped back to USDC).
2. When a person wants to create a new prediction people can bet on they will be charged a set amount. This will add to the reserve as well as prevent overflowing the contract with garbage requests.

For the prediction creators they can claim 10% of the total platform fee collected by the market handler after the prediction is over. Benefits being the creator will be motivated to create valuable predictions to bet upon.
