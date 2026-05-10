/*
 * rosa_inflammatory_mild.mli — Rosacea Phase 4: Mild Neurovascular-Inflammatory
 *
 * Variant of cbd.mli (mast_cell module) + niacinamide.mli (IL-8/MCP-1)
 * for mild rosacea (ETR: erythematotelangiectatic rosacea).
 *
 * Key perturbations from healthy baseline:
 *   • Mast cell copies: 2 (healthy=1) — increased mast cell density in rosacea
 *   • Histamine initial: 5 (healthy=0) — mast cell priming
 *   • il8 initial: 3, mcp1 initial: 2 (healthy=0) — innate inflammatory markers
 *   • trpv1_signal initial: 2 — TRPV1 sensitisation (flushing trigger)
 *   • p_hist: 2× protions on mast cell (elevated histamine release rate)
 *
 * Severity tier: MILD (flushing + mild erythema; no papules)
 *
 * Biological basis
 * ────────────────
 * Rosacea ETR: chronic TRPV1/TRPA1 sensitisation in sensory neurons →
 * neuropeptide (CGRP, SP) release → mast cell degranulation → histamine,
 * IL-8, MCP-1 → neutrophil/monocyte recruitment → angiogenesis.
 * Cathelicidin (LL-37) derived from kallikrein cleavage of filaggrin/corneum
 * amplifies innate response.  CBD targets TRPV1 + CB2R/mast cell axis.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/rosacea/rosa_inflammatory_mild.mli \
 *       -o /tmp/rosa_mild.msim
 *   bin/msim /tmp/rosa_mild.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_cb2;
    @glue glue_trpv1;
    @glue glue_mc;
    @glue glue_kc;
    @glue glue_nuc;
    @glue glue_mel;
    @glue glue_vas;   /* vascular / neurovascular glue */

    @glue_relation(glue_cb2,   glue_cb2);
    @glue_relation(glue_trpv1, glue_trpv1);
    @glue_relation(glue_mc,    glue_mc);
    @glue_relation(glue_kc,    glue_kc);
    @glue_relation(glue_nuc,   glue_nuc);
    @glue_relation(glue_vas,   glue_vas);

    @glue_radius 0.12;

    /* Sensory keratinocyte — TRPV1 hyper-sensitised in rosacea */
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
        @color LightCoral alpha=140;
        /* 2× TRPV1 protions: rosacea hyper-sensitivity */
        @protion p_trpv1 at (-3,  0);
        @protion p_trpv1 at (-3, -3);
        @protion p_nfkb  at ( 0,  3);
        @protion p_sirt1 at ( 0, -3);
    }

    /* Mast cell — mild rosacea: 2× p_hist (elevated histamine release) */
    @tile mast_cell(sides=6, radius=6) {
        @connector c1(vertices=[v1,v2], glue=glue_mc, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mc, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mc, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mc, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mc, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mc, angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2, angle=90);
        @surface_glue glue_mc;
        @color Plum alpha=150;
        @protion p_cb2  at (0,  2);
        @protion p_hist at (0, -2);
        @protion p_hist at (2, -2);    /* 2nd p_hist: mild rosacea mast cell */
    }

    /* Vascular endothelial cell — neurovascular axis */
    @tile endothelial(sides=4, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_vas, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_vas, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_vas, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_vas, angle=90);
        @surface_glue glue_vas;
        @color LightBlue alpha=160;
        @protion p_vegf at (0,  2);   /* VEGF = angiogenesis driver in rosacea */
        @protion p_nfkb at (0, -2);
    }

    @seed rosa_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — mild rosacea ─────────────────────────────────────── */

@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);

/* Niacinamide (SIRT1 / IL-8 suppression) */
@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);

/* TRPV1 sensitisation: pre-existing signal (flushing trigger) */
@floating trpv1_signal(mobility=6, radius=0.04, concentration=2); /* healthy=0, mild=2 */

/* Mast cell products */
@floating histamine(mobility=8, radius=0.03, concentration=5);    /* healthy=0, mild=5 */
@floating il8(mobility=7, radius=0.04, concentration=3);          /* healthy=0, mild=3 */
@floating mcp1(mobility=7, radius=0.04, concentration=2);

/* Inflammatory mediators */
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);
@floating nad_plus(mobility=4, radius=0.06, concentration=0);

/* Vascular signals */
@floating vegf(mobility=5, radius=0.06, concentration=2);         /* angiogenesis in rosacea */
@floating cgrp(mobility=7, radius=0.04, concentration=2);         /* neuropeptide trigger */

/* Ceramide (TRPV1 pathway — partially activated) */
@floating ceramide(mobility=2, radius=0.07, concentration=0);

/* CBD intermediates */
@floating cb2_signal(mobility=6, radius=0.04, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cb2;
@protion p_trpv1;
@protion p_nfkb;
@protion p_sirt1;
@protion p_hist;
@protion p_vegf;

/* ── Sigma ───────────────────────────────────────────────────────────────── */
/* TRPV1 hyper-reactivity: releases trpv1_signal + ceramide at contact */
@sigma(glue_trpv1, glue_trpv1) = trpv1_signal, ceramide;

/* Mast cell–keratinocyte contact: releases histamine + CGRP */
@sigma(glue_mc, glue_kc) = histamine, cgrp;

@reaction_distance 12;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* TRPV1 activation (mild rosacea: CGRP/heat trigger) */
    p_trpv1: cgrp, cbd_free --> trpv1_signal, cbd_protein;    /* CBD desensitises TRPV1 */
    p_trpv1: cgrp           --> trpv1_signal, trpv1_signal;   /* baseline CGRP excitation */

    /* TRPV1 signal → histamine release from mast cell */
    trpv1_signal, histamine --> histamine, histamine;   /* amplified release */

    /* CB2R — anti-inflammatory */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il8  --> cb2_signal;
    cb2_signal, mcp1 --> cb2_signal;

    /* Mast cell histamine suppression by CBD (CB2R) */
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* SIRT1 (niacinamide): IL-8/MCP-1 suppression */
    /* Niacinamide → NMN → NAD⁺ → SIRT1 → NF-κB suppression */
    niacinamide --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    p_sirt1: nad_plus, il8  --> nad_plus;
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    /* VEGF (angiogenesis) cycling — mild: self-maintains */
    p_vegf: vegf --> vegf, vegf;
    il8, vegf --> vegf;     /* IL-8 → angiogenic signal */

    /* CGRP → further TRPV1 activation (flushing positive feedback) */
    cgrp, trpv1_signal --> cgrp;   /* consumed by cascade */

    /* CBD protein binding */
    cbd_protein --> cbd_free;

    /* Tile assembly */
    @create ceramide, ceramide, ceramide --> rosa_keratinocyte;
    @create histamine, histamine, il8    --> mast_cell;
    @create vegf, vegf                   --> endothelial;
}
