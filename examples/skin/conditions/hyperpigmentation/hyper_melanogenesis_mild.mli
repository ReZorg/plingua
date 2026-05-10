/*
 * hyper_melanogenesis_mild.mli — Hyperpigmentation Phase 4: Mild
 *
 * Variant of niacinamide.mli (melanocyte module) for mild hyperpigmentation.
 * Key perturbations from healthy baseline:
 *
 *   • alpha_msh initial: 6 (healthy=3) — mild UV/post-inflammatory MSH elevation
 *   • par2_signal initial: 8 (healthy=5) — mildly upregulated melanosome transfer
 *   • tyrosine initial: 15 (healthy=10) — elevated melanin substrate
 *   • 2× melanocyte copies present (higher melanocyte density in PIH)
 *   • Additional tyrosinase protion on melanocyte (mild upregulation)
 *
 * Severity tier: MILD (slight uneven skin tone, macular hyperpigmentation)
 *
 * Biological basis
 * ────────────────
 * Post-inflammatory hyperpigmentation (PIH) / solar lentigo:
 * UV → p53/POMC → α-MSH → MC1R → MITF → tyrosinase (TYR), TRP1, TRP2 →
 * eumelanin synthesis → melanosome packaging → PAR-2-mediated transfer to
 * keratinocytes → pigmentation.
 * Niacinamide PAR-2 competitive block is the primary active mechanism.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/hyperpigmentation/hyper_melanogenesis_mild.mli \
 *       -o /tmp/hyper_mild.msim
 *   bin/msim /tmp/hyper_mild.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_ker;
    @glue glue_mel;
    @glue glue_fib;
    @glue glue_nuc;
    @glue glue_air;

    @glue_relation(glue_ker, glue_ker);
    @glue_relation(glue_mel, glue_mel);
    @glue_relation(glue_fib, glue_fib);
    @glue_relation(glue_nuc, glue_nuc);

    @glue_radius 0.12;

    /* PAR-2-expressing keratinocyte (target of niacinamide) */
    @tile niacin_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_ker, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_ker, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_ker, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_ker, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_ker, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_ker, angle=60);
        @connector c_mel(vertices=[center], glue=glue_mel, angle=90);
        @connector c_nuc(vertices=[center], glue=glue_nuc, angle=-90);
        @surface_glue glue_ker;
        @color Bisque alpha=180;
        @protion p_nmns  at ( 3,  0);
        @protion p_nmnat at (-3,  0);
        @protion p_sirt1 at ( 0,  3);
        @protion p_par2  at ( 0, -3);
        @protion p_nfkb  at ( 2,  2);
    }

    /* Melanocyte — mild PIH: 2× p_tyr protions (mild upregulation) */
    @tile melanocyte(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_mel, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mel, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mel, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mel, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mel, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mel, angle=60);
        @connector c_dendrite(vertices=[center], glue=glue_mel, angle=90);
        @surface_glue glue_mel;
        @color SaddleBrown alpha=200;
        @protion p_tyr  at ( 0,  3);
        @protion p_tyr  at ( 3,  0);   /* 2nd p_tyr: mild PIH upregulation */
        @protion p_msom at ( 0, -3);
        @protion p_mc1r at (-3,  0);
    }

    @seed niacin_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — mild hyperpigmentation ───────────────────────────── */

@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);

/* Melanin synthesis: mildly elevated substrates */
@floating tyrosine(mobility=6, radius=0.04, concentration=15);        /* healthy=10, mild=15 */
@floating dopa(mobility=5, radius=0.05, concentration=0);
@floating dopaquinone(mobility=5, radius=0.05, concentration=0);
@floating eumelanin(mobility=0.5, radius=0.25, concentration=0);
@floating melanosome(mobility=0.8, radius=0.30, concentration=0);

/* MSH/MC1R signalling: mildly elevated */
@floating alpha_msh(mobility=7, radius=0.04, concentration=6);        /* healthy=3, mild=6 */

/* PAR-2 transfer pathway: mildly elevated */
@floating par2_signal(mobility=6, radius=0.04, concentration=8);      /* healthy=5, mild=8 */
@floating par2_blocked(mobility=6, radius=0.04, concentration=0);

/* Inflammatory (post-inflammatory context) */
@floating il8(mobility=7, radius=0.04, concentration=0);
@floating mcp1(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);

/* Anti-glycation */
@floating methylglyoxal(mobility=6, radius=0.03, concentration=5);

/* Barrier lipids */
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating cholesterol(mobility=1.5, radius=0.08, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_nmns;
@protion p_nmnat;
@protion p_sirt1;
@protion p_par2;
@protion p_nfkb;
@protion p_tyr;
@protion p_msom;
@protion p_mc1r;

/* ── Sigma ───────────────────────────────────────────────────────────────── */
/* Mild PIH: elevated melanosome transfer at melanocyte–keratinocyte synapse */
@sigma(glue_mel, glue_mel) = melanosome, melanosome, melanosome;  /* healthy=2, mild=3 */
@sigma(glue_nuc, glue_nuc) = nad_plus, ceramide;

@reaction_distance 12;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* NAD⁺ biosynthesis */
    p_nmns: niacinamide --> nmn;
    p_nmnat: nmn --> nad_plus;
    nad_plus --> nadh;
    nadh --> nad_plus;

    /* SIRT1 anti-inflammatory */
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    nfkb_active --> il8, mcp1;
    p_sirt1: nad_plus, il8  --> nad_plus;
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    /* Melanin synthesis — mildly elevated (2× tyrosinase) */
    p_tyr: tyrosine     --> dopa;
    p_tyr: dopa         --> dopaquinone;
    dopaquinone         --> eumelanin;

    /* MC1R + elevated MSH → amplified tyrosinase */
    p_mc1r: alpha_msh   --> msh_signal;
    msh_signal, tyrosine --> dopa, msh_signal;

    /* Melanosome packaging */
    p_msom: eumelanin, eumelanin, eumelanin --> melanosome;

    /* PAR-2 transfer — mildly elevated (higher par2_signal) */
    p_par2: par2_signal, melanosome --> melanosome_keratin;

    /* Niacinamide PAR-2 block (primary therapeutic action) */
    p_par2: niacinamide, par2_signal --> par2_blocked, niacinamide;
    par2_blocked, melanosome --> melanosome;

    /* Anti-glycation */
    niacinamide, methylglyoxal --> niacinamide_mgly;

    /* Barrier lipids (indirect PPARα) */
    nad_plus --> ceramide, cholesterol;

    @create niacinamide, niacinamide, niacinamide --> niacin_keratinocyte;
    @create tyrosine, tyrosine, alpha_msh          --> melanocyte;
}
