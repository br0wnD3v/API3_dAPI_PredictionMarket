# Prediction Markets Using dAPIs

This specific project only targets tokens tradable and not real-world political/geographical events.

Implementing Prediction Markets by allowing users to create new predictions or trade available predictions.
dAPIs are the source of settling the predictions after the time has surpassed for a given prediction.

### Business Model

There are two ways the platform is able to sustain itself :

1. Trading fee from the user. This includes buying the bet tokens, swapping them or selling them if the user wants to get their investment back. (NOTE: If the deadline passes the people cant back off and the tokens can't be swapped back to USDC).
2. When a person wants to create a new prediction people can bet on they will be charged a set amount. This will add to the reserve as well as prevent overflowing the contract with garbage requests.

For the prediction creators they can claim 10% of the total platform fee collected by the market handler after the prediction is over. Benefits being the creator will be motivated to create valuable predictions to bet upon.

### List of mathematical models commonly used in prediction markets

1. Market Scoring Rule (MSR): MSR is a class of scoring rules that assigns scores or rewards to traders based on the accuracy of their predictions. The scoring rule encourages traders to reveal their true beliefs and bet in proportion to their confidence. Different variants of MSR exist, such as logarithmic MSR (LMSR) mentioned earlier.

2. Kelly criterion: The Kelly criterion is a mathematical formula that helps traders determine the optimal amount of their bankroll to allocate to a particular bet. It considers the probability of winning and the payoff odds to optimize the expected return and manage risk.

3. Brier score: The Brier score is a scoring rule that measures the accuracy of probabilistic predictions. It assigns a score based on the squared difference between the predicted probability and the actual outcome. Lower Brier scores indicate more accurate predictions.

4. Bayes' theorem: Bayes' theorem is a fundamental concept in probability theory that enables updating beliefs based on new evidence. It combines prior knowledge or beliefs with observed data to compute updated probabilities. It is often used in prediction markets to incorporate new information and adjust probabilities accordingly.

5. Gaussian processes: Gaussian processes are a statistical modeling technique that can be used to estimate and predict outcomes based on observed data. They provide a flexible framework for modeling uncertainty and can be applied to prediction markets to capture the distribution of possible outcomes.

6. Monte Carlo simulations: Monte Carlo simulations involve running repeated simulations of an event or outcome using random variables and statistical models. It helps estimate probabilities and assess potential outcomes by generating a large number of simulated scenarios.

7. Machine learning algorithms: Various machine learning algorithms, such as logistic regression, support vector machines, or neural networks, can be applied to prediction markets. These algorithms learn from historical data and patterns to make predictions or estimate probabilities.

These are just a few examples of mathematical models used in prediction markets. Different prediction market platforms or systems may utilize different models or a combination of them, depending on their specific goals, design, and requirements.
