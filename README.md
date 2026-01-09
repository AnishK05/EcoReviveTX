# EcoReviveTX

## Overview

**EcoReviveTX** is a web application that predicts ecological restoration outcomes for Texas landscapes. The platform uses machine learning models trained on ecological restoration data (adapted from [Wang et al. (2020)](https://datadryad.org/stash/dataset/doi:10.5061/dryad.msbcc2g0g)) to estimate restoration timelines and soil carbon dynamics based on site-specific environmental conditions. Users can input geographic coordinates, climate data, and soil characteristics to predict either (1) restoration time in years, or (2) soil organic carbon response (lnRR.SOC). The application also includes C-based ecosystem simulations for scenario analysis.

This project is an ongoing partnership with the **Texas Parks and Wildlife Department** to support ecological restoration efforts across the state.

Explore the website [here](https://ecorevive-tx.vercel.app/)

![EcoReviveTXScreenshot](static/ecorevivetxscreenshot.png)

## Technologies Used

* **Front-End:** JavaScript (jQuery), HTML, CSS
* **Back-End:** Flask, RESTful APIs
* **Machine Learning:** Python
* **Ecosystem Modeling:** C
* **Data Visualization:** MATLAB
* **Deployment:** Vercel

## Features

* **Machine Learning Prediction Tool:** Eight trained models (4 climate/ecosystem combinations × 2 prediction targets) using Random Forest, Gradient Boosting, Linear Regression, and SVR. The best-performing model for each category was selected based on R² score. Models take latitude, longitude, MAT (°C), MAP (mm), soil depth (cm), ambient SOC (g/kg), climate zone (subtropical/temperate), and ecosystem type (forest/non-forest) as inputs. Outputs restoration time (years) or soil carbon response (lnRR.SOC).

* **C-Based Ecosystem Simulations:** Two simulation methods: (1) Basic deterministic model that calculates SOC using environmental variables, and (2) Monte Carlo simulation (1000 iterations) that introduces randomized variations in MAT and MAP to quantify uncertainty. Both simulations use a formula-based approach to predict SOC dynamics.

* **Data Source:** Models trained on ecological restoration data from Chinese ecosystems with similar climate and soil characteristics to Texas, allowing transferability of restoration patterns to Texas landscapes. Data visualizations and graphs were generated using MATLAB to analyze key environmental trends and patterns.

* **Architecture:** Flask REST API serves predictions and executes C simulation binaries. jQuery handles asynchronous form submissions and dynamic result display. Models are loaded at application startup and served via POST endpoints.
