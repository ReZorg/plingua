@msystem<morphogenetic>
@geometry<projective>;

@manifold s3(charts=16, dimension=3, compact=true);
@metric g(type=riemannian, signature=+++);
@connection nabla(type=levi_civita, bundle=tangent);
@capability gauge_invariance;
@flow ricci(type=discrete_ricci, step=0.01, iterations=50, preserve_volume=true);
@polytope c120(dimension=4, vertices=600, edges=1200, faces=720, cells=120, symmetry=H4);

@tiling {
    @glue g1;
    @glue_relation(g1, g1);
    @glue_radius 0.12;

    @tile seed(sides=5, radius=1.0) {
        @connector c1(vertices=[v1,v2], glue=g1, angle=72);
        @connector c2(vertices=[v2,v3], glue=g1, angle=72);
        @connector c3(vertices=[v3,v4], glue=g1, angle=72);
        @connector c4(vertices=[v4,v5], glue=g1, angle=72);
        @connector c5(vertices=[v5,v1], glue=g1, angle=72);
        @surface_glue g1;
        @color Gold alpha=220;
    }

    @seed seed at (0, 0, 0);
}

@floating a(mobility=3.0, radius=0.08, concentration=20);

def main() {
    @create a --> seed;
    @divide g1, a, g1 --> g1, g1;
}
