# EcoReviveTX

## Overview

**EcoReviveTX** is a full-stack web application designed to support ecological restoration efforts in Texas. It leverages AI & machine learning, statistical analysis, data visualization with MATLAB, and C-based simulations to provide actionable insights for park rangers and environmental professionals. The platform offers tools for predicting restoration timelines and soil health metrics, as well as for simulating various environmental scenarios. By integrating these technologies, EcoReviveTX aids in accelerating ecosystem recovery and managing Texas's natural landscapes more sustainably. The platform utilizes a modern tech stack, including jQuery, Flask, C, MATLAB, and machine learning (Python), to create a powerful tool for ecological restoration. Currently in efforts to collaborate with the Texas Parks and Wildlife Department.

Explore the website [here](https://ecorevivetx.onrender.com/)

![EcoReviveTXScreenshot](static/ecorevivetxscreenshot.png)

## Technologies Used

* **Front-End:** JavaScript (jQuery), HTML, CSS
* **Back-End:** Flask, RESTful APIs
* **Machine Learning:** Python
* **Ecosystem Modeling:** C
* **Data Visualization:** MATLAB
* **Deployment:** Render

## Features & Project Highlights

* **Prediction Tool:** Implements multivariate machine learning models (Gradient Boosting, Linear Regression, Random Forest, Support Vector Regression) built with Python to predict restoration timelines and soil health metrics. The tool processes inputs such as latitude, longitude, mean annual temperature (MAT), mean annual precipitation (MAP), soil depth, and ambient soil organic carbon (SOC) to enable data-driven restoration strategies.
* **Simulation Tool:**  Offers C-based simulations for forecasting restoration outcomes. Users input environmental variables like MAT, MAP, soil depth, climate type, and ecosystem type to analyze potential restoration scenarios. The simulations include Monte Carlo methods for enhanced precision in uncertain conditions.
* **MATLAB-Driven Data Visualizations:** Provides detailed and actionable graphs to highlight key environmental trends. These visualizations were adapted from a study originally focused on ecological restoration in China, tailored specifically to the environmental conditions of Texas. The similarities in climate and ecosystem variables between the regions allowed for precise refinements, ensuring relevance and accuracy for Texas landscapes.
* **Flask-Driven RESTful APIs:** Powers the platform’s back-end infrastructure, enabling communication between the prediction and simulation tools and the front end. Flask’s lightweight framework ensures scalable performance and efficient data handling.
* **Dynamic Front-End with jQuery:** Leverages jQuery for efficient DOM manipulation, asynchronous API requests, and dynamic updates to simulation and prediction results. Enables real-time data rendering and user interaction without requiring full-page reloads.
