/*
 * Boxy Hallows — Self-replicating boxes in 3D
 *
 * Based on the M system from Sosík et al., "From P systems to morphogenetic
 * systems" (Journal of Membrane Computing, 2020).
 *
 * A single seed tile d (square) self-assembles into boxes via the creation
 * rule, then boxes divide and push apart, generating exponential growth.
 *
 * M = (F, ∅, T, ∅, R, ∅) where:
 *   F = ({a}, m(a)=5, ρ(a)=0.05, ε(a)=10)
 *   T = ({d}, {g1}, {(g1,g1)}, 0.1, {d})
 *   R = { a → d,  g1 a g1 → g1,g1 }
 */

@msystem<morphogenetic>

@tiling {
    @glue g1;
    @glue gx;
    @glue_relation(g1, g1);
    @glue_radius 0.1;

    @tile d(sides=4, radius=2) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=90);
        @connector c2(vertices=[v2,v3], glue=g1, angle=90);
        @connector c3(vertices=[v3,v4], glue=g1, angle=90);
        @connector c4(vertices=[v4,v1], glue=g1, angle=90);
        @surface_glue gx;
        @color Blue alpha=128;
    }

    @seed d at (0, 0, 0);
}

@floating a(mobility=5, radius=0.05, concentration=10);

def main() {
    // Creation: floating object a consumed to create tile d
    @create a --> d;

    // Division: two connected tiles with g1 glues disconnect, consuming a
    @divide g1, a, g1 --> g1, g1;
}
