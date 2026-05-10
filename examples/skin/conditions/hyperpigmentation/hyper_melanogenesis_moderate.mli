/*
 * hyper_melanogenesis_moderate.mli — Hyperpigmentation Phase 4: Moderate
 *
 * Variant for moderate hyperpigmentation (melasma / persistent PIH).
 * Key perturbations from mild:
 *
 *   • alpha_msh: 12 (mild=6) — hormonal MSH elevation (melasma UV context)
 *   • par2_signal: 15 (mild=8) — significantly upregulated transfer
 *   • tyrosine: 22 (mild=15) — elevated substrate
 *   • 2 melanocyte copies present (higher melanocyte density)
 *   • 3× p_tyr protions on melanocyte
 *   • MSH self-amplification rule (MITF positive feedback)
 *
 * Severity tier: MODERATE (visible darkening, multiple areas)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/hyperpigmentation/hyper_melanogenesis_moderate.mli \
 *       -o /tmp/hyper_mod.msim
 *   bin/msim /tmp/hyper_mod.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_ker;
    @glue glue_mel;
    @glue glue_nuc;

    @glue_relation(glue_ker, glue_ker);
    @glue_relation(glue_mel, glue_mel);
    @glue_relation(glue_nuc, glue_nuc);

    @glue_radius 0.12;

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

    /* Melanocyte — moderate: 3× p_tyr */
    @tile melanocyte(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_mel, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mel, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mel, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mel, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mel, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mel, angle=60);
        @connector c_dendrite(vertices=[center], glue=glue_mel, angle=90);
        @surface_glue glue_mel;
        @color Chocolate alpha=220;
        @protion p_tyr  at ( 0,  3);
        @protion p_tyr  at ( 3,  0);
        @protion p_tyr  at (-3,  0);   /* 3rd p_tyr: moderate upregulation */
        @protion p_msom at ( 0, -3);
        @protion p_mc1r at ( 3, -3);
        @protion p_mc1r at (-3, -3);   /* 2nd MC1R: more MSH responsive */
    }

    @seed niacin_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — moderate hyperpigmentation ───────────────────────── */

@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);
@floating nmn(mobility=4.5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4.0, radius=0.06, concentration=0);
/* NADH is not explicitly tracked; NAD⁺ is recycled via niacinamide salvage only */

@floating tyrosine(mobility=6, radius=0.04, concentration=22);        /* moderate=22 */
@floating dopa(mobility=5, radius=0.05, concentration=0);
@floating dopaquinone(mobility=5, radius=0.05, concentration=0);
@floating eumelanin(mobility=0.5, radius=0.25, concentration=0);
@floating melanosome(mobility=0.8, radius=0.30, concentration=0);

@floating alpha_msh(mobility=7, radius=0.04, concentration=12);       /* moderate=12 */
@floating par2_signal(mobility=6, radius=0.04, concentration=15);     /* moderate=15 */
@floating par2_blocked(mobility=6, radius=0.04, concentration=0);

@floating il8(mobility=7, radius=0.04, concentration=0);
@floating mcp1(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=1);      /* PIH context: low-grade inflam */
@floating methylglyoxal(mobility=6, radius=0.03, concentration=5);
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
/* Moderate: higher melanosome burst per synapse */
@sigma(glue_mel, glue_mel) = melanosome, melanosome, melanosome, melanosome;
@sigma(glue_nuc, glue_nuc) = nad_plus, ceramide;

@reaction_distance 12;

def main() {

    /* NAD⁺ biosynthesis (niacinamide salvage pathway) */
    p_nmns: niacinamide --> nmn;
    p_nmnat: nmn --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    nfkb_active --> il8, mcp1;
    p_sirt1: nad_plus, il8  --> nad_plus;
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    /* Melanin synthesis (3× tyrosinase rate in moderate PIH) */
    p_tyr: tyrosine     --> dopa;
    p_tyr: dopa         --> dopaquinone;
    dopaquinone         --> eumelanin;

    /* MC1R (2× responsive) + MITF positive feedback */
    p_mc1r: alpha_msh   --> msh_signal;
    msh_signal, tyrosine --> dopa, msh_signal;
    /* MITF positive feedback: alpha_msh amplifies itself via MITF loop */
    msh_signal --> alpha_msh, msh_signal;

    /* Melanosome packaging (3× tyrosinase → faster eumelanin fill) */
    p_msom: eumelanin, eumelanin, eumelanin --> melanosome;

    /* PAR-2 transfer (elevated signal → more transfer events) */
    p_par2: par2_signal, melanosome --> melanosome_keratin;
    p_par2: par2_signal, melanosome --> melanosome_keratin;  /* 2nd copy: more transfer */

    /* Niacinamide PAR-2 block */
    p_par2: niacinamide, par2_signal --> par2_blocked, niacinamide;
    par2_blocked, melanosome --> melanosome;

    /* Anti-glycation */
    niacinamide, methylglyoxal --> niacinamide_mgly;

    /* Barrier lipids */
    nad_plus --> ceramide, cholesterol;

    @create niacinamide, niacinamide, niacinamide --> niacin_keratinocyte;
    @create tyrosine, tyrosine, tyrosine, alpha_msh --> melanocyte;  /* more substrate */
    @divide glue_mel, msh_signal, glue_mel --> glue_mel, glue_mel;
}
