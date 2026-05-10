/*
 * rosa_inflammatory_severe.mli — Rosacea Phase 4: Severe Inflammatory
 *
 * Variant for severe rosacea (phymatous / rhinophyma or severe papulopustular).
 * Key perturbations:
 *
 *   • Histamine: 20 — heavy mast cell degranulation (persistent flushing)
 *   • il8: 12, mcp1: 10 — massive neutrophil/monocyte recruitment
 *   • trpv1_signal: 10 — constitutive TRPV1 firing (neuropathic sensitisation)
 *   • vegf: 10 — extensive telangiectasia
 *   • cgrp: 10 — maximal neuropeptide signalling
 *   • LL-37: 6 — cathelicidin constitutive overproduction
 *   • Mast cell: 4× p_hist + constitutive degranulation rule
 *   • TRPV1: 4× protions + flare burst rule
 *   • Constitutive NF-κB positive feedback
 *
 * Severity tier: SEVERE (phymatous / rhinophyma; permanent tissue changes)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/rosacea/rosa_inflammatory_severe.mli \
 *       -o /tmp/rosa_sev.msim
 *   bin/msim /tmp/rosa_sev.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_cb2;
    @glue glue_trpv1;
    @glue glue_mc;
    @glue glue_kc;
    @glue glue_nuc;
    @glue glue_vas;

    @glue_relation(glue_cb2,   glue_cb2);
    @glue_relation(glue_trpv1, glue_trpv1);
    @glue_relation(glue_mc,    glue_mc);
    @glue_relation(glue_kc,    glue_kc);
    @glue_relation(glue_nuc,   glue_nuc);
    @glue_relation(glue_vas,   glue_vas);

    @glue_radius 0.12;

    /* Severely hyper-sensitised keratinocyte: 4× TRPV1 protions */
    @tile rosa_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_kc,    angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_kc,    angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_kc,    angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_kc,    angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_kc,    angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_kc,    angle=60);
        @connector c_cb2(vertices=[center],   glue=glue_cb2,   angle=90);
        @connector c_trpv1(vertices=[center], glue=glue_trpv1, angle=45);
        @connector c_nuc(vertices=[center],   glue=glue_nuc,   angle=-90);
        @surface_glue glue_kc;
        @color Crimson alpha=170;
        @protion p_trpv1 at (-3,  0);
        @protion p_trpv1 at (-3, -3);
        @protion p_trpv1 at ( 3,  3);
        @protion p_trpv1 at ( 3, -3);  /* 4th: severe sensitisation */
        @protion p_nfkb  at ( 0,  3);
        @protion p_sirt1 at ( 0, -3);
    }

    /* Mast cell: 4× p_hist + maximally reactive */
    @tile mast_cell(sides=6, radius=6) {
        @connector c1(vertices=[v1,v2], glue=glue_mc, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mc, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mc, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mc, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mc, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mc, angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2, angle=90);
        @surface_glue glue_mc;
        @color DarkRed alpha=200;
        @protion p_cb2  at (0,   2);
        @protion p_hist at (0,  -2);
        @protion p_hist at (2,  -2);
        @protion p_hist at (-2, -2);
        @protion p_hist at (0,  -4);   /* 4th: severe mast cell degranulation */
    }

    @tile endothelial(sides=4, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_vas, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_vas, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_vas, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_vas, angle=90);
        @surface_glue glue_vas;
        @color Red alpha=180;
        @protion p_vegf at (0,  2);
        @protion p_vegf at (2,  0);
        @protion p_vegf at (-2, 0);    /* 3rd VEGF: telangiectasia established */
        @protion p_nfkb at (0, -2);
    }

    @seed rosa_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — severe rosacea ──────────────────────────────────── */

@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);
@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);

@floating trpv1_signal(mobility=6, radius=0.04, concentration=10);   /* severe=10 */
@floating histamine(mobility=8, radius=0.03, concentration=20);       /* severe=20 */
@floating il8(mobility=7, radius=0.04, concentration=12);
@floating mcp1(mobility=7, radius=0.04, concentration=10);
@floating nfkb_active(mobility=5, radius=0.05, concentration=5);
@floating nad_plus(mobility=4, radius=0.06, concentration=0);
@floating vegf(mobility=5, radius=0.06, concentration=10);
@floating cgrp(mobility=7, radius=0.04, concentration=10);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating cb2_signal(mobility=6, radius=0.04, concentration=0);
@floating ll37(mobility=7, radius=0.04, concentration=6);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cb2;
@protion p_trpv1;
@protion p_nfkb;
@protion p_sirt1;
@protion p_hist;
@protion p_vegf;

/* ── Sigma: maximal TRPV1 burst + constitutive mast cell degranulation ───── */
@sigma(glue_trpv1, glue_trpv1) = trpv1_signal, trpv1_signal, trpv1_signal, ceramide;
@sigma(glue_mc, glue_kc) = histamine, histamine, histamine, cgrp, il8;

@reaction_distance 12;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Constitutive TRPV1 spontaneous firing (neuropathic sensitisation) */
    p_trpv1: cgrp --> trpv1_signal, trpv1_signal, trpv1_signal;  /* burst amplitude */
    p_trpv1: cgrp, cbd_free --> trpv1_signal, cbd_protein;

    /* Histamine constitutive amplification (mast cell primed state) */
    trpv1_signal, histamine --> histamine, histamine, histamine;
    trpv1_signal --> cgrp, cgrp, cgrp;    /* maximal CGRP positive feedback */

    /* CB2R — still active but overwhelmed in severe disease */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il8  --> cb2_signal;
    cb2_signal, mcp1 --> cb2_signal;
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* Constitutive NF-κB (severe rosacea: permanent tissue remodelling) */
    nfkb_active --> il8, il8, mcp1, mcp1, nfkb_active;

    /* LL-37 constitutive overproduction (gene mutation in rosacea) */
    ll37 --> ll37, ll37;
    ll37, trpv1_signal --> ll37, trpv1_signal, trpv1_signal;

    /* VEGF constitutive angiogenesis */
    p_vegf: vegf --> vegf, vegf, vegf;

    /* SIRT1 (niacinamide) — therapeutic counter */
    niacinamide --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    p_sirt1: nad_plus, il8  --> nad_plus;
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    cbd_protein --> cbd_free;

    @create ceramide, ceramide, ceramide, ceramide        --> rosa_keratinocyte;
    @create histamine, histamine, histamine, histamine, il8, mcp1 --> mast_cell;
    @create vegf, vegf, vegf, vegf                       --> endothelial;
}
