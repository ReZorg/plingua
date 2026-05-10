/*
 * rosa_inflammatory_moderate.mli — Rosacea Phase 4: Moderate Inflammatory
 *
 * Variant for moderate rosacea (papulopustular rosacea, subtype 2).
 * Key perturbations from mild:
 *
 *   • Histamine: 10 (mild=5)
 *   • il8: 6, mcp1: 5 (moderate Th1 infiltrate)
 *   • trpv1_signal: 5 (moderate TRPV1 sensitisation)
 *   • vegf: 5 (angiogenesis escalation, visible telangiectasia)
 *   • cgrp: 5 (neuropeptide amplification)
 *   • Mast cell copies: 3× p_hist (high degranulation rate)
 *   • TRPV1 constitutive firing rule (no CBD needed for activation)
 *
 * Severity tier: MODERATE (papulopustular; persistent redness + pustules)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/rosacea/rosa_inflammatory_moderate.mli \
 *       -o /tmp/rosa_mod.msim
 *   bin/msim /tmp/rosa_mod.msim -steps 400 -v
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

    /* Rosa keratinocyte — 3× TRPV1 protions: moderate hyper-reactivity */
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
        @color LightCoral alpha=160;
        @protion p_trpv1 at (-3,  0);
        @protion p_trpv1 at (-3, -3);
        @protion p_trpv1 at ( 3,  3);   /* 3rd TRPV1: moderate sensitisation */
        @protion p_nfkb  at ( 0,  3);
        @protion p_sirt1 at ( 0, -3);
    }

    /* Mast cell — moderate: 3× p_hist */
    @tile mast_cell(sides=6, radius=6) {
        @connector c1(vertices=[v1,v2], glue=glue_mc, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mc, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mc, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mc, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mc, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mc, angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2, angle=90);
        @surface_glue glue_mc;
        @color DarkMagenta alpha=160;
        @protion p_cb2  at (0,  2);
        @protion p_hist at (0, -2);
        @protion p_hist at (2, -2);
        @protion p_hist at (-2, -2);
    }

    @tile endothelial(sides=4, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_vas, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_vas, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_vas, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_vas, angle=90);
        @surface_glue glue_vas;
        @color Salmon alpha=170;
        @protion p_vegf at (0,  2);
        @protion p_vegf at (2,  0);   /* 2nd VEGF protion: angiogenic expansion */
        @protion p_nfkb at (0, -2);
    }

    @seed rosa_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — moderate rosacea ─────────────────────────────────── */

@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);
@floating niacinamide(mobility=5.5, radius=0.04, concentration=50);

@floating trpv1_signal(mobility=6, radius=0.04, concentration=5);    /* moderate=5 */
@floating histamine(mobility=8, radius=0.03, concentration=10);       /* moderate=10 */
@floating il8(mobility=7, radius=0.04, concentration=6);
@floating mcp1(mobility=7, radius=0.04, concentration=5);
@floating nfkb_active(mobility=5, radius=0.05, concentration=2);
@floating nad_plus(mobility=4, radius=0.06, concentration=0);
@floating vegf(mobility=5, radius=0.06, concentration=5);             /* moderate=5 */
@floating cgrp(mobility=7, radius=0.04, concentration=5);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating cb2_signal(mobility=6, radius=0.04, concentration=0);

/* LL-37 (cathelicidin — rosacea-specific innate AMP) */
@floating ll37(mobility=7, radius=0.04, concentration=3);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cb2;
@protion p_trpv1;
@protion p_nfkb;
@protion p_sirt1;
@protion p_hist;
@protion p_vegf;

/* ── Sigma ───────────────────────────────────────────────────────────────── */
@sigma(glue_trpv1, glue_trpv1) = trpv1_signal, trpv1_signal, ceramide;
@sigma(glue_mc, glue_kc) = histamine, histamine, cgrp;

@reaction_distance 12;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Constitutive TRPV1 firing (without CBD: spontaneous activation) */
    p_trpv1: cgrp --> trpv1_signal, trpv1_signal;
    p_trpv1: cgrp, cbd_free --> trpv1_signal, cbd_protein;   /* CBD desensitises */

    /* Histamine amplification */
    trpv1_signal, histamine --> histamine, histamine;
    trpv1_signal --> cgrp, cgrp;                             /* flare feedback */

    /* CB2R anti-inflammatory */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il8  --> cb2_signal;
    cb2_signal, mcp1 --> cb2_signal;
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* NF-κB constitutive (moderate rosacea) */
    nfkb_active --> il8, mcp1, nfkb_active;

    /* LL-37 (cathelicidin) amplifies TRPV1 and mast cell responses */
    ll37, trpv1_signal --> ll37, trpv1_signal, trpv1_signal;

    /* SIRT1 anti-inflammatory (niacinamide) */
    niacinamide --> nad_plus;
    p_sirt1: nad_plus, nfkb_active --> nad_plus, nfkb_inact;
    p_sirt1: nad_plus, il8  --> nad_plus;
    p_sirt1: nad_plus, mcp1 --> nad_plus;

    /* VEGF angiogenesis (moderate: constitutive) */
    p_vegf: vegf --> vegf, vegf;
    il8, vegf --> vegf, vegf;

    /* Ceramide → mild barrier support */
    ceramide, ceramide --> ceramide, ceramide, ceramide;

    cbd_protein --> cbd_free;

    @create ceramide, ceramide, ceramide        --> rosa_keratinocyte;
    @create histamine, histamine, histamine, il8 --> mast_cell;
    @create vegf, vegf, vegf                    --> endothelial;
}
