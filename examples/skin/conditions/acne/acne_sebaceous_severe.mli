/*
 * acne_sebaceous_severe.mli — Acne Phase 4: Severe Sebaceous/Inflammatory
 *
 * Variant for severe acne (nodular/cystic acne vulgaris).
 * Key perturbations from healthy baseline:
 *
 *   • Androgen: 15 tokens — androgens drive severe cystic sebaceous pathology
 *   • Sebum: 55 tokens — gross sebaceous hyperproduction
 *   • il1b=8, tnfa=5, nfkb_active=3 — heavy innate + adaptive inflammation
 *   • Follicular nanoparticle: 18 — dense comedone plug / cyst obstruction
 *   • 4× p_androgen on sebocyte — maximal lipogenesis drive
 *   • Histamine primed (mast cell activation at t=0)
 *   • Sebum positive feedback constitutive
 *
 * Severity tier: SEVERE (nodular/cystic, scarring risk)
 *
 * Key drug target: isotretinoin analog (reduces sebocyte survival/activity);
 * CBD PPARγ, AHA (comedolysis), retinol (cornification normalisation).
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/acne/acne_sebaceous_severe.mli \
 *       -o /tmp/acne_sev.msim
 *   bin/msim /tmp/acne_sev.msim -steps 400 -v
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

    /* Sebocyte — severe acne: 4× p_androgen protions */
    @tile sebocyte(sides=4, radius=20) {
        @connector c1(vertices=[v1,v2], glue=glue_seb, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_seb, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_seb, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_seb, angle=90);
        @connector c_ppar(vertices=[center], glue=glue_ppar, angle=90);
        @surface_glue glue_seb;
        @color DarkGoldenrod alpha=180;
        @protion p_ppar     at ( 0,  5);
        @protion p_lip      at ( 0, -5);
        @protion p_androgen at ( 5,  0);
        @protion p_androgen at (-5,  0);
        @protion p_androgen at ( 0, -8);
        @protion p_androgen at ( 3,  3);   /* 4th protion: severe cystic acne */
    }

    /* Mast cells — maximally reactive, 3 histamine sites */
    @tile mast_cell(sides=6, radius=6) {
        @connector c1(vertices=[v1,v2], glue=glue_mc, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_mc, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_mc, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_mc, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_mc, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_mc, angle=60);
        @connector c_cb2(vertices=[center], glue=glue_cb2, angle=90);
        @surface_glue glue_mc;
        @color DarkMagenta alpha=180;
        @protion p_cb2  at (0,  2);
        @protion p_hist at (0, -2);
        @protion p_hist at (2, -2);
        @protion p_hist at (-2, -2);
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
        @color SaddleBrown alpha=200;
        @protion p_seb at (5,  0);
        @protion p_seb at (-5, 0);
        @protion p_seb at (0,  5);   /* 3rd p_seb: cystic follicle plugging */
    }

    @seed cbd_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — severe acne ─────────────────────────────────────── */

@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);

@floating androgen(mobility=4, radius=0.05, concentration=15);    /* severe=15 */
@floating sebum(mobility=0.8, radius=0.15, concentration=55);     /* severe=55 */

@floating il1b(mobility=7, radius=0.04, concentration=8);         /* severe=8 */
@floating tnfa(mobility=7, radius=0.04, concentration=5);
@floating nfkb_active(mobility=5, radius=0.05, concentration=3);
@floating histamine(mobility=8, radius=0.03, concentration=5);    /* pre-activated mast cells */

@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating nanoparticle(mobility=0.3, radius=0.50, concentration=18); /* severe comedone */
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

@sigma(glue_cb2,   glue_cb2)   = cb2_signal, cb2_signal, cb2_signal;
@sigma(glue_trpv1, glue_trpv1) = ceramide, ceramide;
@sigma(glue_ppar,  glue_ppar)  = ppar_signal, ppar_signal;

@reaction_distance 12;

def main() {

    /* CB2R anti-inflammatory */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il1b --> cb2_signal;
    cb2_signal, tnfa  --> cb2_signal;

    /* TRPV1 */
    p_trpv1: cbd_free --> trpv1_signal, cbd_protein;
    p_spt: trpv1_signal --> ceramide, ceramide;

    /* PPARγ sebostatic */
    p_ppar: cbd_free, androgen --> ppar_signal, cbd_protein;
    p_lip:  ppar_signal, sebum  --> ppar_signal;

    /* Massive androgen-driven sebum production */
    p_androgen: androgen --> sebum, sebum, sebum;   /* 3× output in severe */

    /* Constitutive sebum autocatalysis (cystic biofilm) */
    sebum, sebum --> sebum, sebum, sebum;

    /* PPARγ blunts androgen (CBD therapeutic effect) */
    p_ppar: ppar_signal, androgen --> ppar_signal;

    /* Constitutive NF-κB / inflammatory cycle */
    nfkb_active --> il1b, il1b, tnfa, tnfa, nfkb_active;

    /* Mast cell histamine release (pre-existing) */
    p_hist: histamine, il1b --> histamine, histamine;

    /* Mast cell CB2R activation (CBD suppresses) */
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* Cystic follicle: nanoparticle retention + drug release */
    nanoparticle --> drug_lipo, drug_lipo, drug_lipo, drug_lipo;

    cbd_protein --> cbd_free;

    @create ceramide, ceramide, ceramide --> cbd_keratinocyte;
    @create sebum, sebum, sebum, sebum, androgen --> sebocyte;
    @create il1b, il1b, il1b, tnfa, tnfa        --> mast_cell;

    /* CBD promotes keratinocyte anti-apoptotic (prevents scar formation) */
    @destroy tnfa, tnfa, cbd_free, cbd_keratinocyte --> ceramide, cb2_signal;
}
