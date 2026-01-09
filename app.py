from flask import Flask, render_template, request, jsonify
import joblib
import random
import os

app = Flask(__name__)

# Load machine learning models
models = {
    "subtropical_forest_time": joblib.load(open('selected_models/best_model_Restoration_time_years_Subtropical_Forest.pkl', 'rb')),
    "subtropical_forest_lnrr_soc": joblib.load(open('selected_models/best_model_lnRR.SOC_Subtropical_Forest.pkl', 'rb')),
    "subtropical_non_forest_time": joblib.load(open('selected_models/best_model_Restoration_time_years_Subtropical_Non_Forest.pkl', 'rb')),
    "subtropical_non_forest_lnrr_soc": joblib.load(open('selected_models/best_model_lnRR.SOC_Subtropical_Non_Forest.pkl', 'rb')),
    "temperate_forest_time": joblib.load(open('selected_models/best_model_Restoration_time_years_Temperate_Forest.pkl', 'rb')),
    "temperate_forest_lnrr_soc": joblib.load(open('selected_models/best_model_lnRR.SOC_Temperate_Forest.pkl', 'rb')),
    "temperate_non_forest_time": joblib.load(open('selected_models/best_model_Restoration_time_years_Temperate_Non_Forest.pkl', 'rb')),
    "temperate_non_forest_lnrr_soc": joblib.load(open('selected_models/best_model_lnRR.SOC_Temperate_Non_Forest.pkl', 'rb')),
}

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    try:
        latitude = float(request.form.get('latitude', 0))
        longitude = float(request.form.get('longitude', 0))
        mat = float(request.form.get('mat', 0))
        map_ = float(request.form.get('map', 0))
        soil_depth = float(request.form.get('soil_depth', 0))
        ambient_soc = float(request.form.get('ambient_soc', 0))
        climate = request.form.get('climate', '')
        ecosystem = request.form.get('ecosystem', '')
        prediction_type = request.form.get('prediction_type', '')

        # Determine the correct model key
        model_key = f"{climate}_{ecosystem}_{prediction_type}"
        model = models.get(model_key)

        if model:
            # Prepare the input data for prediction
            data = [latitude, longitude, mat, map_, soil_depth, ambient_soc]
            prediction = model.predict([data])[0]
        else:
            prediction = "Model not found for the given inputs."

        return jsonify({"prediction": prediction})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/simulate', methods=['POST'])
def simulate():
    try:
        mat = float(request.form.get('mat', 0))
        map_ = float(request.form.get('map', 0))
        soil_depth = float(request.form.get('soil_depth', 0))
        climate = request.form.get('climate', '')
        ecosystem = request.form.get('ecosystem', '')
        simulation_type = request.form.get('simulation_type', '')

        if simulation_type:
            if simulation_type == "basic":
                simulation_result = run_basic_simulation(mat, map_, soil_depth, climate, ecosystem)
            elif simulation_type == "monte_carlo":
                simulation_result = run_monte_carlo_simulation(mat, map_, soil_depth, climate, ecosystem)
            else:
                return jsonify({"error": "Invalid simulation type selected."})
        else:
            simulation_result = "No simulation type selected."

        return jsonify({"simulation_result": simulation_result})
    except Exception as e:
        return jsonify({"error": str(e)})

def calculate_soc(mat, map_, soil_depth, climate, ecosystem):
    """Calculate SOC using the same formula as the C code."""
    climate_encoded = 1 if climate == "subtropical" else 0
    ecosystem_encoded = 1 if ecosystem == "forest" else 0
    
    # Same formula as in the C code
    soc = 0.5 - 0.02 * mat + 0.0008 * map_ + 0.03 * soil_depth + 0.2 * climate_encoded + 0.35 * ecosystem_encoded
    return soc

def run_basic_simulation(mat, map_, soil_depth, climate, ecosystem):
    """Run basic deterministic SOC simulation (equivalent to basic_ecosystem_modeling.c)."""
    try:
        soc = calculate_soc(mat, map_, soil_depth, climate, ecosystem)
        return f"Predicted SOC: {soc:.6f}\n"
    except Exception as e:
        return f"Simulation error: {str(e)}"

def run_monte_carlo_simulation(mat, map_, soil_depth, climate, ecosystem, iterations=1000):
    """Run Monte Carlo SOC simulation (equivalent to monte_carlo_ecosystem_modeling.c)."""
    try:
        random.seed()  # Initialize random seed
        soc_sum = 0.0
        
        for i in range(iterations):
            # Small variation in MAT and MAP (same as C code: rand() % 3 - 1 gives -1, 0, or 1)
            mat_variation = mat + (random.randint(0, 2) - 1) * 0.1 * mat
            map_variation = map_ + (random.randint(0, 2) - 1) * 0.1 * map_
            soc = calculate_soc(mat_variation, map_variation, soil_depth, climate, ecosystem)
            soc_sum += soc
        
        soc_average = soc_sum / iterations
        return f"Predicted SOC after Monte Carlo simulation: {soc_average:.6f}\n"
    except Exception as e:
        return f"Simulation error: {str(e)}"

if __name__ == '__main__':
    app.run(debug=True)