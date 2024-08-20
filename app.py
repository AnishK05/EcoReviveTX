from flask import Flask, render_template, request, jsonify
import joblib
import subprocess
import os

app = Flask(__name__)

# Load machine learning models
models = {
    "subtropical_forest_time": joblib.load(open('selected_models/subtropical_forest_time.pkl', 'rb')),
    "subtropical_forest_lnrr_soc": joblib.load(open('selected_models/subtropical_forest_lnrr_soc.pkl', 'rb')),
    "subtropical_non_forest_time": joblib.load(open('selected_models/subtropical_non_forest_time.pkl', 'rb')),
    "subtropical_non_forest_lnrr_soc": joblib.load(open('selected_models/subtropical_non_forest_lnrr_soc.pkl', 'rb')),
    "temperate_forest_time": joblib.load(open('selected_models/temperate_forest_time.pkl', 'rb')),
    "temperate_forest_lnrr_soc": joblib.load(open('selected_models/temperate_forest_lnrr_soc.pkl', 'rb')),
    "temperate_non_forest_time": joblib.load(open('selected_models/temperate_non_forest_time.pkl', 'rb')),
    "temperate_non_forest_lnrr_soc": joblib.load(open('selected_models/temperate_non_forest_lnrr_soc.pkl', 'rb')),
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
                c_file = 'C_simulations/basic_ecosystem_modeling.c'
            elif simulation_type == "monte_carlo":
                c_file = 'C_simulations/monte_carlo_ecosystem_modeling.c'
            else:
                return jsonify({"error": "Invalid simulation type selected."})
            
            # Compile the C file and run the simulation
            simulation_result = compile_and_run_c_simulation(c_file, mat, map_, soil_depth, climate, ecosystem)
        else:
            simulation_result = "No simulation type selected."

        return jsonify({"simulation_result": simulation_result})
    except Exception as e:
        return jsonify({"error": str(e)})

def compile_and_run_c_simulation(c_file, mat, map_, soil_depth, climate, ecosystem):
    """Compile and run a C simulation source file with user inputs."""
    try:
        # Compile the C file
        executable = c_file.replace('.c', '.out')
        compile_command = f"gcc {c_file} -o {executable}"
        compile_process = subprocess.run(compile_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        if compile_process.returncode != 0:
            return f"Compilation error: {compile_process.stderr.decode('utf-8')}"
        
        # Run the compiled binary
        process = subprocess.Popen(
            [executable, str(mat), str(map_), str(soil_depth), climate, ecosystem],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        stdout, stderr = process.communicate()

        if process.returncode != 0:
            return f"Execution error: {stderr.decode('utf-8')}"
        
        return stdout.decode('utf-8')
    except Exception as e:
        return f"Simulation error: {str(e)}"

if __name__ == '__main__':
    app.run(debug=True)