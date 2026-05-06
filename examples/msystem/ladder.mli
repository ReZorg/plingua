/*
 * Ladder — Simple linear self-assembly
 *
 * Based on the MSystemLadder Cytos example.
 * Demonstrates basic 1D growth: square tiles connect edge-to-edge
 * forming a ladder-like structure extending in one direction.
 *
 * This is one of the simplest non-trivial M systems, useful for
 * understanding tile connectivity and creation rules.
 */

@msystem<morphogenetic>

@tiling {
    @glue ga;
    @glue gb;
    @glue gx;

    @glue_relation(ga, ga);
    @glue_relation(gb, gb);

    @glue_radius 0.1;

    // Rung tile (horizontal bar)
    @tile rung(sides=4, radius=2) {
        @connector c1(vertices=[v1,v2], glue=ga, angle=90);
        @connector c2(vertices=[v2,v3], glue=gb, angle=90);
        @connector c3(vertices=[v3,v4], glue=ga, angle=90);
        @connector c4(vertices=[v4,v1], glue=gb, angle=90);
        @surface_glue gx;
        @color Cyan alpha=150;
    }

    @seed rung at (0, 0, 0);
}

@floating a(mobility=4, radius=0.05, concentration=5);

def main() {
    // Create new rung tiles from floating objects
    @create a, a --> rung;
}
