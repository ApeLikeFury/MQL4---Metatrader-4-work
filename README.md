# MQL4---Metatrader-4-work

These files contain some of my work for Forex Identity LLC

The Metatrader 4 platform is required to run this code, so i've included some images of trades which this algorithm has detected in the past.

Example images: https://docs.google.com/document/d/1tOp1vfcAzP59QPahXhtcTyOoI4wKZ4C6N8JfxtYxG_M/edit?usp=sharing

The file "IdentityV7.mq4" contains code to identify complex price patterns based on a variety of factors.
This can send a push notification to your mobile device when a potential trading opportunity is detected.

Some information about these price patterns is included in the "Trading algorithm explanation" Google document. 
Please note that I've had to censor certain parts of the document in compliance with my non-disclosure agreement with the company. I have also slightly modified certain elements of my code.

The file "TradingFeatures.mq4" can interface with Metatrader 4 charts to place and exit trades as well as calculate correct risk management automatically.
We decided to use neural networks for this going forward as certain price structures can be very subjective, requiring experience in trading and difficult to code with fixed rules.
