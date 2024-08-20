#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define ITERATIONS 1000 // Set the number of iterations here

double calculateSOC(double MAT, double MAP, double soilDepth, const char *climate, const char *ecosystem);

int main(int argc, char *argv[]) {
    if (argc != 6) { // Updated to 6 to include program name + 5 arguments
        fprintf(stderr, "Usage: %s MAT MAP soilDepth climate ecosystem\n", argv[0]);
        return 1;
    }

    double MAT = atof(argv[1]);
    double MAP = atof(argv[2]);
    double soilDepth = atof(argv[3]);
    const char *climate = argv[4];
    const char *ecosystem = argv[5];

    srand(time(0));
    double SOC_sum = 0;

    for (int i = 0; i < ITERATIONS; i++) {
        double MAT_variation = MAT + (rand() % 3 - 1) * 0.1 * MAT; // Small variation in MAT
        double MAP_variation = MAP + (rand() % 3 - 1) * 0.1 * MAP; // Small variation in MAP
        double SOC = calculateSOC(MAT_variation, MAP_variation, soilDepth, climate, ecosystem);
        SOC_sum += SOC;
    }

    double SOC_average = SOC_sum / ITERATIONS;
    printf("Predicted SOC after Monte Carlo simulation: %f\n", SOC_average);

    return 0;
}

double calculateSOC(double MAT, double MAP, double soilDepth, const char *climate, const char *ecosystem) {
    double climate_encoded = (strcmp(climate, "subtropical") == 0) ? 1 : 0;
    double ecosystem_encoded = (strcmp(ecosystem, "forest") == 0) ? 1 : 0;

    // Refined formula based on literature trends
    return 0.5 - 0.02 * MAT + 0.0008 * MAP + 0.03 * soilDepth + 0.2 * climate_encoded + 0.35 * ecosystem_encoded;
}