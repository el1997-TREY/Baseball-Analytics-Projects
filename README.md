Baseball Analytics: Modeling At-Bat Outcomes and Hitter Performance

Overview
This project explores key factors that influence the outcomes of Major League Baseball (MLB) at-bats, using detailed pitch-by-pitch data from the 2018–2024 seasons. Our goal is to model and visualize how characteristics like foul balls, pitch counts, ballpark effects, handedness matchups, and pitch outcomes contribute to batter success—particularly home runs and slugging performance.

Objective
To develop a comprehensive, data-driven framework for evaluating MLB hitters by:
	•	Analyzing trends in foul balls, pitch sequences, and plate appearance lengths
	•	Exploring the effect of pitcher-batter matchups and ballpark characteristics
	•	Creating a side-by-side “Killer Plot” that compares hitters using advanced metrics

This work aims to eliminate media bias and surface-level narrative in favor of a purely statistical view of player quality.

Dataset
	•	Primary Dataset: 1.2M+ plate appearances, 128 variables — includes pitch-by-pitch outcomes and contextual features
	•	Secondary Dataset: Aggregated advanced metrics used for direct hitter comparison

Data includes:
	•	Foul ball counts
	•	Pitch outcomes (strike, ball, in-play)
	•	Batter/pitcher handedness
	•	Game metadata (date, ballpark, etc.)

Key Analyses & Visualizations
	•	Scatter plots of foul balls vs. total pitches per at-bat
	•	Histograms and boxplots of pitch distributions
	•	Lollipop and area charts showing HR rate vs. foul counts and matchup types
	•	Violin plots of foul ball distribution across seasons
	•	Diverging bar and lollipop charts of SLG and OBP by count
	•	Ballpark-based bar charts showing pitch outcome distributions
	•	Seasonal trend plots of home runs by month
	•	Interactive Killer Plot: Compare two hitters based on weighted performance indicators (SLG, exit velocity, walk rate, etc.)

Key Findings
	•	Home run rates increase significantly in longer at-bats with more foul balls
	•	Batters in “hitter’s counts” (like 2-0 or 3-1) have far higher OBP and SLG
	•	Oakland’s ballpark sees more foul balls due to larger foul territory
	•	Lefty-righty matchup effects diminish in long at-bats (more than 7+ pitches)
	•	Our Killer Plot helps quantify and visualize differences between players based on deep-plate appearance quality, not reputation

Tools Used
	•	R (ggplot2, dplyr, DBI, RSQLite, viridis)
	•	Data manipulation, SQL querying, custom visualizations
	•	Interactive graphics for player comparisons

Future Improvements
	•	Add player photo integration in Killer Plot
	•	Enable filtering by team or position
	•	Explore pitch sequence modeling (e.g., how fouls/walks evolve in an at-bat)
	•	Extend modeling to include pitcher fatigue and in-game substitution logic
