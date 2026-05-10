/*
 * acne_sebaceous_moderate.mli — Acne Phase 4: Moderate Sebaceous/Inflammatory
 *
 * Variant for moderate acne (inflammatory papules and pustules).
 * Key perturbations from mild:
 *
 *   • Androgen: 10 tokens (mild=6)
 *   • Sebum: 35 tokens (mild=20)
 *   • il1b=5, tnfa=2, nfkb_active=1 (Th1/innate escalation)
 *   • Follicular nanoparticle retention: 14 (comedone plugs)
 *   • 3× p_androgen protions on sebocyte (strong lipogenesis)
 *   • Sebum self-amplification rule (biofilm formation proxy)
 *
 * Severity tier: MODERATE (papulopustular acne)
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/acne/acne_sebaceous_moderate.mli \
 *       -o /tmp/acne_mod.msim
 *   bin/msim /tmp/acne_mod.msim -steps 400 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_cb2;
    @glue glue_trpv1;
    @glue glue_ppar;
    @glue glue_seb;
    @glue glue_kc;
    @glue glue_mc;
    @glue glue_fol;

    @glue_relation(glue_cb2,   glue_cb2);
    @glue_relation(glue_trpv1, glue_trpv1);
    @glue_relation(glue_ppar,  glue_ppar);
    @glue_relation(glue_seb,   glue_seb);
    @glue_relation(glue_kc,    glue_kc);
    @glue_relation(glue_mc,    glue_mc);
    @glue_relation(glue_fol,   glue_fol);

    @glue_radius 0.12;

    @tile cbd_keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_kc,    angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_kc,    angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_kc,    angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_kc,    angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_kc,    angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_kc,    angle=60);
        @connector c_cb2(vertices=[center],   glue=glue_cb2,   angle=90);
        @connector c_trpv1(vertices=[center], glue=glue_trpv1, angle=45);
        @surface_glue glue_kc;
        @color PaleGreen alpha=140;
        @protion p_cb2   at ( 3,  0);
        @protion p_trpv1 at (-3,  0);
        @protion p_nfkb  at ( 0,  3);
        @protion p_spt   at ( 0, -3);
    }

    /* Sebocyte — moderate acne: 3× p_androgen protions */
    @tile sebocyte(sides=4, radius=20) {
        @connector c1(vertices=[v1,v2], glue=glue_seb, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_seb, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_seb, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_seb, angle=90);
        @connector c_ppar(vertices=[center], glue=glue_ppar, angle=90);
        @surface_glue glue_seb;
        @color Gold alpha=130;
        @protion p_ppar     at ( 0,  3);
        @protion p_lip      at ( 0, -3);
        @protion p_androgen at ( 3,  0);
        @protion p_androgen at (-3,  0);
        @protion p_androgen at ( 0, -5);   /* 3rd protion: moderate sebaceous drive */
    }

    /* Mast cells × 2 (recruited by innate inflammatory signals) */
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
        @protion p_hist at (2, -2);   /* 2nd hist protion: elevated reactivity */
    }

    @tile follicle_infundibulum(sides=8, radius=40) {
        @connector c1(vertices=[v1,v2], glue=glue_fol, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fol, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fol, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fol, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fol, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fol, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fol, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fol, angle=45);
        @surface_glue glue_fol;
        @color SaddleBrown alpha=170;
        @protion p_seb at (5, 0);
        @protion p_seb at (-5, 0);   /* 2nd p_seb: follicular lipid buildup */
    }

    @seed cbd_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — moderate acne ───────────────────────────────────── */

@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);

@floating androgen(mobility=4, radius=0.05, concentration=10);    /* moderate=10 */
@floating sebum(mobility=0.8, radius=0.15, concentration=35);     /* moderate=35 */

@floating il1b(mobility=7, radius=0.04, concentration=5);         /* moderate=5 */
@floating tnfa(mobility=7, radius=0.04, concentration=2);
@floating nfkb_active(mobility=5, radius=0.05, concentration=1);
@floating histamine(mobility=8, radius=0.03, concentration=2);    /* mast cell priming */

@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating nanoparticle(mobility=0.3, radius=0.50, concentration=14); /* moderate comedone */
@floating drug_lipo(mobility=1.5, radius=0.12, concentration=0);
@floating cb2_signal(mobility=6, radius=0.04, concentration=0);
@floating trpv1_signal(mobility=6, radius=0.04, concentration=0);
@floating ppar_signal(mobility=5, radius=0.05, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cb2;
@protion p_trpv1;
@protion p_nfkb;
@protion p_spt;
@protion p_ppar;
@protion p_lip;
@protion p_androgen;
@protion p_hist;
@protion p_seb;

@sigma(glue_cb2,   glue_cb2)   = cb2_signal, cb2_signal;
@sigma(glue_trpv1, glue_trpv1) = ceramide, ceramide;
@sigma(glue_ppar,  glue_ppar)  = ppar_signal;

@reaction_distance 12;

def main() {

    /* CB2R anti-inflammatory */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il1b --> cb2_signal;
    cb2_signal, tnfa  --> cb2_signal;

    /* TRPV1 ceramide stimulation */
    p_trpv1: cbd_free --> trpv1_signal, cbd_protein;
    p_spt: trpv1_signal --> ceramide, ceramide;

    /* PPARγ sebostatic */
    p_ppar: cbd_free, androgen --> ppar_signal, cbd_protein;
    p_lip:  ppar_signal, sebum  --> ppar_signal;

    /* Androgen → sebum (3× rate in moderate acne) */
    p_androgen: androgen --> sebum, sebum;

    /* Sebum self-amplification (biofilm/microcomedone formation) */
    sebum, sebum, sebum --> sebum, sebum, sebum, sebum;   /* autocatalytic buildup */

    /* PPARγ blunts androgen */
    p_ppar: ppar_signal, androgen --> ppar_signal;

    /* Mast cell activation */
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* Moderate inflammatory cascade */
    nfkb_active --> il1b, tnfa, nfkb_active;

    /* Nanoparticle release in comedone */
    nanoparticle --> drug_lipo, drug_lipo, drug_lipo;

    cbd_protein --> cbd_free;

    @create ceramide, ceramide, ceramide --> cbd_keratinocyte;
    @create sebum, sebum, sebum, androgen --> sebocyte;   /* more sebum needed: moderate */
    @create il1b, il1b, tnfa             --> mast_cell;   /* higher threshold: recruited */
}
