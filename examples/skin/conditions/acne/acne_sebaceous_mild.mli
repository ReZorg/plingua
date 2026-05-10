/*
 * acne_sebaceous_mild.mli — Acne Phase 4: Mild Sebaceous/Inflammatory
 *
 * Variant of cbd.mli + follicle_shunt.mli for mild acne.
 * Key perturbations from healthy baseline:
 *
 *   • Androgen elevated: 6 tokens (healthy=3) — mild androgenic drive
 *   • Sebum elevated: 20 tokens (healthy=10) — mild sebaceous hyperactivity
 *   • Mild innate inflammation: il1b=2
 *   • Follicular retention: nanoparticle=10 (modest comedone formation proxy)
 *   • Extra p_androgen protion copy on sebocyte (2× lipogenesis rate)
 *
 * Severity tier: MILD (open/closed comedones; no inflammatory papules)
 *
 * Biological basis
 * ────────────────
 * Mild acne: dihydrotestosterone (DHT) via 5α-reductase type 1 in sebocytes
 * drives SREBP-1c/PPAR-α → triglyceride synthesis → sebum output.
 * C. acnes (P. acnes) in follicle lumen produces lipases → free fatty acids →
 * TLR2/4 activation → low-grade IL-1β / CXCL8 → comedonal inflammation.
 * CBD (PPARγ) and AHA (comedolysis) are primary targets.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/acne/acne_sebaceous_mild.mli \
 *       -o /tmp/acne_mild.msim
 *   bin/msim /tmp/acne_mild.msim -steps 400 -v
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
    @glue glue_fol;   /* follicle channel glue */

    @glue_relation(glue_cb2,   glue_cb2);
    @glue_relation(glue_trpv1, glue_trpv1);
    @glue_relation(glue_ppar,  glue_ppar);
    @glue_relation(glue_seb,   glue_seb);
    @glue_relation(glue_kc,    glue_kc);
    @glue_relation(glue_mc,    glue_mc);
    @glue_relation(glue_fol,   glue_fol);

    @glue_radius 0.12;

    /* Keratinocyte: CB2R/TRPV1 expressing */
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

    /* Sebocyte — mild acne: 2× p_androgen protions (elevated lipogenesis) */
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
        @protion p_androgen at (-3,  0);   /* extra: mild acne 2× lipogenesis */
    }

    /* Mast cell */
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
    }

    /* Follicle infundibulum (comedone proxy) */
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
        @color SandyBrown alpha=160;
        @protion p_seb at (5, 0);
    }

    @seed cbd_keratinocyte at (0, 0, 0);
}

/* ── Floating objects — mild acne ───────────────────────────────────────── */

/* CBD (therapeutic agent for acne — sebostatic + anti-inflammatory) */
@floating cbd_free(mobility=2.0, radius=0.09, concentration=25);
@floating cbd_protein(mobility=0.4, radius=0.18, concentration=0);

/* Androgen elevated (mild acne: 2× healthy DHT proxy) */
@floating androgen(mobility=4, radius=0.05, concentration=6);     /* healthy=3, mild=6 */

/* Sebum markedly elevated */
@floating sebum(mobility=0.8, radius=0.15, concentration=20);     /* healthy=10, mild=20 */

/* Mild inflammatory signals */
@floating il1b(mobility=7, radius=0.04, concentration=2);         /* healthy=0, mild=2 */
@floating tnfa(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);
@floating histamine(mobility=8, radius=0.03, concentration=0);

/* Ceramide (TRPV1 pathway — PPARγ target) */
@floating ceramide(mobility=2, radius=0.07, concentration=0);

/* Nanoparticle: follicular retention (comedone plug proxy) */
@floating nanoparticle(mobility=0.3, radius=0.50, concentration=10); /* healthy=8, mild=10 */

/* Sebum-sequestered drug proxy */
@floating drug_lipo(mobility=1.5, radius=0.12, concentration=0);

/* Signalling intermediates */
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

/* ── Sigma ───────────────────────────────────────────────────────────────── */
@sigma(glue_cb2,   glue_cb2)   = cb2_signal, cb2_signal;
@sigma(glue_trpv1, glue_trpv1) = ceramide, ceramide;
@sigma(glue_ppar,  glue_ppar)  = ppar_signal;

@reaction_distance 12;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* CB2R anti-inflammatory */
    p_cb2: cbd_free --> cb2_signal, cbd_protein;
    p_nfkb: cb2_signal, nfkb_active --> cb2_signal;
    cb2_signal, il1b --> cb2_signal;
    cb2_signal, tnfa  --> cb2_signal;

    /* TRPV1 ceramide stimulation */
    p_trpv1: cbd_free --> trpv1_signal, cbd_protein;
    p_spt: trpv1_signal --> ceramide, ceramide;

    /* PPARγ sebostatic — primary acne target */
    p_ppar: cbd_free, androgen --> ppar_signal, cbd_protein;
    p_lip:  ppar_signal, sebum  --> ppar_signal;

    /* Androgen-driven sebum production (2× rate in mild acne) */
    p_androgen: androgen --> sebum, sebum;

    /* PPARγ: blunts androgen response */
    p_ppar: ppar_signal, androgen --> ppar_signal;

    /* Mast cell CB2R — mild histamine suppression */
    p_cb2:  cbd_free --> cb2_signal, cbd_protein;
    p_hist: cb2_signal --> histamine_blk;

    /* Nanoparticle deposition in infundibulum (comedone formation) */
    nanoparticle --> drug_lipo, drug_lipo;

    /* CBD protein binding / release */
    cbd_protein --> cbd_free;

    /* Low-grade innate inflammation cycle (mild acne: TLR2 → IL-1β) */
    [il1b --> il1b]'2;

    /* Tile assembly */
    @create ceramide, ceramide, ceramide --> cbd_keratinocyte;
    @create sebum, sebum, androgen       --> sebocyte;
    @create il1b, tnfa                   --> mast_cell;
}
