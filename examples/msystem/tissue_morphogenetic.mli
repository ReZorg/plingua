/*
 * Tissue-Morphogenetic System — Deep Echo State Network inspired
 *
 * Combines tissue-like P system topology with M system spatial dynamics.
 * Based on the tissue-like P system for deep echo state networks
 * (Yang et al., Journal of Membrane Computing, 2022).
 *
 * This model demonstrates:
 * - Graph-based cell communication (tissue topology)
 * - Spatial tile assembly for compartment formation
 * - Signal propagation through compartment walls
 * - Reservoir-like dynamics for time series processing
 *
 * The tissue-morphogenetic model bridges P-Lingua tissue models
 * with M-Lingua spatial geometry.
 */

@msystem<tissue_morphogenetic>

@tiling {
    @glue gi;
    @glue go;
    @glue gc;
    @glue gx;

    @glue_relation(gi, gi);
    @glue_relation(go, go);
    @glue_relation(gc, gc);

    @glue_radius 0.2;

    // Input compartment tile
    @tile input_cell(sides=6, radius=4) {
        @connector c1(vertices=[v1,v2], glue=gi, angle=120);
        @connector c2(vertices=[v2,v3], glue=gc, angle=120);
        @connector c3(vertices=[v3,v4], glue=gi, angle=120);
        @connector c4(vertices=[v4,v5], glue=gc, angle=120);
        @connector c5(vertices=[v5,v6], glue=gi, angle=120);
        @connector c6(vertices=[v6,v1], glue=gc, angle=120);
        @surface_glue gx;
        @color Blue alpha=80;
        @protion pin at (0, 0);
    }

    // Reservoir compartment tile (ESN-inspired)
    @tile reservoir_cell(sides=6, radius=4) {
        @connector c1(vertices=[v1,v2], glue=gc, angle=120);
        @connector c2(vertices=[v2,v3], glue=gc, angle=120);
        @connector c3(vertices=[v3,v4], glue=gc, angle=120);
        @connector c4(vertices=[v4,v5], glue=gc, angle=120);
        @connector c5(vertices=[v5,v6], glue=gc, angle=120);
        @connector c6(vertices=[v6,v1], glue=gc, angle=120);
        @surface_glue gx;
        @color Purple alpha=80;
        @protion pres at (0, 0);
    }

    // Output compartment tile
    @tile output_cell(sides=6, radius=4) {
        @connector c1(vertices=[v1,v2], glue=go, angle=120);
        @connector c2(vertices=[v2,v3], glue=gc, angle=120);
        @connector c3(vertices=[v3,v4], glue=go, angle=120);
        @connector c4(vertices=[v4,v5], glue=gc, angle=120);
        @connector c5(vertices=[v5,v6], glue=go, angle=120);
        @connector c6(vertices=[v6,v1], glue=gc, angle=120);
        @surface_glue gx;
        @color Red alpha=80;
        @protion pout at (0, 0);
    }

    @seed input_cell at (0, 0, 0);
}

// Signal objects
@floating signal_in(mobility=3, radius=0.03, concentration=1.0);
@floating signal_res(mobility=4, radius=0.03, concentration=0);
@floating signal_out(mobility=3, radius=0.03, concentration=0);
@floating excite(mobility=5, radius=0.02, concentration=0);

// Protions
@protion pin;
@protion pres;
@protion pout;

def main() {
    // Build the tissue: create reservoir and output compartments
    @create signal_in, signal_in, signal_in --> reservoir_cell;
    @create signal_res, signal_res --> output_cell;

    // Protion-catalyzed signal processing
    pin: signal_in --> signal_res;
    pres: signal_res --> excite, signal_out;
    pout: signal_out --> excite;

    // Metabolic: reservoir excitation dynamics
    excite, excite --> signal_res;
}
