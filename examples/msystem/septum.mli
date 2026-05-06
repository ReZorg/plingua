/*
 * Septum — Prokaryotic cell division without nucleus
 *
 * Based on the Cytos MSystemSeptum example.
 * Models binary fission of a prokaryotic cell: membrane growth
 * from a seed, septum formation across the equator, and
 * controlled splitting into two daughter cells.
 *
 * This is a simpler M system than the eukaryotic cytoskeleton model,
 * demonstrating the fundamental self-assembly and division mechanics.
 */

@msystem<morphogenetic>

@tiling {
    @glue gm;
    @glue gs;
    @glue gd;
    @glue gx;

    @glue_relation(gm, gm);
    @glue_relation(gs, gs);
    @glue_relation(gd, gd);

    @glue_radius 0.1;

    // Membrane tile
    @tile m1(sides=6, radius=5) {
        @connector c1(vertices=[v1,v2], glue=gm, angle=120);
        @connector c2(vertices=[v2,v3], glue=gm, angle=120);
        @connector c3(vertices=[v3,v4], glue=gm, angle=120);
        @connector c4(vertices=[v4,v5], glue=gd, angle=120);
        @connector c5(vertices=[v5,v6], glue=gm, angle=120);
        @connector c6(vertices=[v6,v1], glue=gm, angle=120);
        @surface_glue gx;
        @color LightBlue alpha=100;
    }

    // Septum tile (division plane)
    @tile s1(sides=6, radius=5) {
        @connector c1(vertices=[v1,v2], glue=gs, angle=120);
        @connector c2(vertices=[v2,v3], glue=gs, angle=120);
        @connector c3(vertices=[v3,v4], glue=gs, angle=120);
        @connector c4(vertices=[v4,v5], glue=gs, angle=120);
        @connector c5(vertices=[v5,v6], glue=gs, angle=120);
        @connector c6(vertices=[v6,v1], glue=gs, angle=120);
        @surface_glue gx;
        @color Orange alpha=128;
    }

    @seed m1 at (0, 0, 0);
}

@floating a(mobility=4, radius=0.05, concentration=5);
@floating b(mobility=3, radius=0.05, concentration=0);
@floating x(mobility=6, radius=0.05, concentration=0);

def main() {
    // Membrane growth: a consumed to create membrane tiles
    @create a, a, a, a --> m1;

    // Septum growth: b objects create septum tiles
    @create b, b --> s1;

    // Metabolic: convert a to b over time
    a, a --> b;

    // Division: x triggers splitting at equatorial glue pairs
    @divide gd, x, gd --> gd, gd;
}
