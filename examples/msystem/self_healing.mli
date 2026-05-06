/*
 * Self-Healing M System — Robust membrane repair
 *
 * Based on the self-healing properties described in
 * Sosík et al. (2020) Section 5: "Robustness and self-healing".
 *
 * Demonstrates that M systems can recover from random injuries
 * (tile destruction) by re-growing missing tiles from floating
 * objects in the environment. The system maintains homeostasis
 * even under continuous perturbation.
 *
 * The injury model randomly destroys tiles with probability p_injury,
 * but the creation rules continuously rebuild the structure from
 * environmental resources.
 */

@msystem<morphogenetic>

@tiling {
    @glue g1;
    @glue g2;
    @glue gx;

    @glue_relation(g1, g1);
    @glue_relation(g2, g2);

    @glue_radius 0.15;

    // Primary structural tile
    @tile t1(sides=4, radius=3) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=90);
        @connector c2(vertices=[v2,v3], glue=g1, angle=90);
        @connector c3(vertices=[v3,v4], glue=g1, angle=90);
        @connector c4(vertices=[v4,v1], glue=g1, angle=90);
        @surface_glue gx;
        @color Green alpha=100;
    }

    // Repair tile (different color to visualize healing)
    @tile t2(sides=4, radius=3) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=90);
        @connector c2(vertices=[v2,v3], glue=g1, angle=90);
        @connector c3(vertices=[v3,v4], glue=g1, angle=90);
        @connector c4(vertices=[v4,v1], glue=g1, angle=90);
        @surface_glue gx;
        @color Yellow alpha=150;
    }

    @seed t1 at (0, 0, 0);
}

@floating a(mobility=5, radius=0.05, concentration=8);
@floating r(mobility=3, radius=0.05, concentration=0);

def main() {
    // Growth: create structural tiles
    @create a, a --> t1;

    // Repair: create repair tiles from repair signal
    @create r, r --> t2;

    // Destruction produces repair signal: tile destroyed releases repair objects
    @destroy a, t1 --> r, r, r;

    // Metabolic: slowly convert repair objects back to building material
    r --> a;
}
