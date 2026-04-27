/*
 * Cytoskeleton — Controlled eukaryotic cell division (mitosis)
 *
 * Based on the M system M₀ from the Cytos PS10 appendix
 * (Sosík, Smolka, Drastík, Garzon).
 *
 * Models cell membrane formation as a dodecahedron (pentagonal tiles),
 * nuclear membrane as a smaller dodecahedron, cytoskeleton growth
 * via microtubules (rods), and controlled division via signal objects.
 *
 * Tile types:
 *   q0 - Large base tile (pentagonal, cellular membrane)
 *   q1 - Large top tile (pentagonal, cellular membrane)
 *   q2 - Large equatorial tile (pentagonal, cellular membrane, with protions)
 *   q3 - Small base tile (pentagonal, nuclear membrane)
 *   q4 - Small equatorial tile (pentagonal, nuclear membrane, with protions)
 *
 * Rod types:
 *   s0 - Auxiliary rod connecting q0 center to q3 center
 *   s1 - Straight microtubule segment
 *   s2 - Fork microtubule segment
 *
 * Floating objects:
 *   a - Primary building material (from environment, concentration 0.1)
 *   b - Intermediate product (catalyzed from a by p2 protions)
 *   c - Nuclear signal (catalyzed in nuclear membrane by p4 protions)
 *   x - Division trigger (released by sigma when microtubule reaches nucleus)
 */

@msystem<morphogenetic>

@tiling {
    // Glue definitions
    @glue g0;
    @glue g1;
    @glue g2;
    @glue g3;
    @glue g4;
    @glue g5;
    @glue g6;
    @glue ga;
    @glue gb;
    @glue gc;
    @glue gd;
    @glue ge;
    @glue gf;
    @glue gt;
    @glue gx;

    // Glue relations
    @glue_relation(g0, g1);
    @glue_relation(g1, g2);
    @glue_relation(g3, g3);
    @glue_relation(g4, g5);
    @glue_relation(g6, g3);
    @glue_relation(g4, gt);
    @glue_relation(g6, gt);
    @glue_relation(ga, gf);
    @glue_relation(gf, ga);
    @glue_relation(gb, gb);
    @glue_relation(gc, gc);
    @glue_relation(gd, gd);
    @glue_relation(ge, gf);

    @glue_radius 0.1;

    // Cellular membrane tiles
    @tile q0(sides=5, radius=10) {
        @connector c1(vertices=[v1,v2], glue=ge, angle=116.57);
        @connector c2(vertices=[v2,v3], glue=ge, angle=116.57);
        @connector c3(vertices=[v3,v4], glue=ge, angle=116.57);
        @connector c4(vertices=[v4,v5], glue=ge, angle=116.57);
        @connector c5(vertices=[v5,v1], glue=ge, angle=116.57);
        @connector c6(vertices=[center], glue=g3, angle=90);
        @connector c7(vertices=[center], glue=g0, angle=90);
        @surface_glue gx;
        @color DeepSkyBlue alpha=64;
    }

    @tile q1(sides=5, radius=10) {
        @connector c1(vertices=[v1,v2], glue=ga, angle=116.57);
        @connector c2(vertices=[v2,v3], glue=ga, angle=116.57);
        @connector c3(vertices=[v3,v4], glue=ga, angle=116.57);
        @connector c4(vertices=[v4,v5], glue=ga, angle=116.57);
        @connector c5(vertices=[v5,v1], glue=ga, angle=116.57);
        @connector c6(vertices=[center], glue=g3, angle=90);
        @surface_glue gx;
        @color DeepSkyBlue alpha=64;
    }

    @tile q2(sides=5, radius=10) {
        @connector c1(vertices=[v1,v2], glue=gf, angle=116.57);
        @connector c2(vertices=[v2,v3], glue=gb, angle=116.57);
        @connector c3(vertices=[v3,v4], glue=gc, angle=116.57);
        @connector c4(vertices=[v4,v5], glue=gd, angle=116.57);
        @connector c5(vertices=[v5,v1], glue=gb, angle=116.57);
        @surface_glue gx;
        @color DeepSkyBlue alpha=64;
        @protion p0 at (2, 0);
        @protion p0 at (2, 2);
        @protion p2 at (0, 0);
        @protion p2 at (0, 2);
        @protion p1 at (-5, -5);
        @protion p1 at (-5, 5);
        @protion p1 at (5, -5);
        @protion p1 at (5, 5);
    }

    // Nuclear membrane tiles
    @tile q3(sides=5, radius=3) {
        @connector c1(vertices=[v1,v2], glue=ga, angle=116.57);
        @connector c2(vertices=[v2,v3], glue=ga, angle=116.57);
        @connector c3(vertices=[v3,v4], glue=ga, angle=116.57);
        @connector c4(vertices=[v4,v5], glue=ga, angle=116.57);
        @connector c5(vertices=[v5,v1], glue=ga, angle=116.57);
        @connector c6(vertices=[center], glue=g2, angle=-90);
        @surface_glue gt;
        @color Gold alpha=64;
    }

    @tile q4(sides=5, radius=3) {
        @connector c1(vertices=[v1,v2], glue=gf, angle=116.57);
        @connector c2(vertices=[v2,v3], glue=gb, angle=116.57);
        @connector c3(vertices=[v3,v4], glue=gc, angle=116.57);
        @connector c4(vertices=[v4,v5], glue=gd, angle=116.57);
        @connector c5(vertices=[v5,v1], glue=gb, angle=116.57);
        @surface_glue gx;
        @color Gold alpha=64;
        @protion p3 at (-1, -1);
        @protion p3 at (-1, 1);
        @protion p3 at (1, -1);
        @protion p3 at (1, 1);
        @protion p4 at (0, 0);
        @protion p4 at (0, 1);
        @protion p4 at (1, 0);
        @protion p4 at (1, 1);
    }

    @seed q0 at (0, 0, 0);
}

// Floating objects
@floating a(mobility=5, radius=0.05, concentration=0.1);
@floating b(mobility=5, radius=0.05, concentration=0);
@floating c(mobility=4, radius=0.05, concentration=0);
@floating x(mobility=7, radius=0.05, concentration=0);

// Protions
@protion p0;
@protion p1;
@protion p2;
@protion p3;
@protion p4;

// Signal release: microtubule connecting to nuclear membrane releases x objects
@sigma(g4, gt) = x, x, x;
@sigma(g6, gt) = x, x, x;

// Reaction distance
@reaction_distance 14;

def main() {
    // Metabolic rules (protion-catalyzed)
    // p0: transport a through cellular membrane
    p0: a --> a;

    // p1: deactivate division signal
    p1: c --> a;
    p1: c, x --> a, a;

    // p2: convert a to b (inside cellular membrane)
    p2: a --> b;

    // p3: deactivate x inside nucleus
    p3: c, x --> a, a;

    // p4: convert a to division signal c
    p4: a --> c, c;

    // Creation rules
    @create a, a, a, a, a, a, a, a --> q1;
    @create a, a, a, a, a, a, a, a --> q2;
    @create a, a, a --> q3;
    @create a, a, a --> q4;
    @create b --> s1;
    @create b --> s2;

    // Division rules
    @divide gc, x, gc --> gc, gc;
    @divide gd, x, gd --> gd, gd;
}
