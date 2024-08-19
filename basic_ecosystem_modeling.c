#include <stdio.h>
#include <stdlib.h>
#include <string.h>

double calculateSOC(double MAT, double MAP, double soilDepth, const char *climate, const char *ecosystem);

int main(int argc, char *argv[]) {
    if (argc != 6) {
        fprintf(stderr, "Usage: %s <MAT> <MAP> <soilDepth> <climate> <ecosystem>\n", argv[0]);
        return 1;
    }

    // Parse command-line arguments
    double MAT = atof(argv[1]);
    double MAP = atof(argv[2]);
    double soilDepth = atof(argv[3]);
    const char *climate = argv[4];
    const char *ecosystem = argv[5];

    double SOC = calculateSOC(MAT, MAP, soilDepth, climate, ecosystem);
    printf("Predicted SOC: %f\n", SOC);

    return 0;
}

double calculateSOC(double MAT, double MAP, double soilDepth, const char *climate, const char *ecosystem) {
    double climate_encoded = (strcmp(climate, "subtropical") == 0) ? 1 : 0;
    double ecosystem_encoded = (strcmp(ecosystem, "forest") == 0) ? 1 : 0;

    // Refined formula based on literature trends
    return 0.5 - 0.02 * MAT + 0.0008 * MAP + 0.03 * soilDepth + 0.2 * climate_encoded + 0.35 * ecosystem_encoded;
}