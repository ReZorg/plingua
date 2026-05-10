/*
 * ad_biology_mild.mli — Atopic Dermatitis Phase 3: Mild Barrier Biology
 *
 * Variant of barrier_repair.mli for mild atopic dermatitis.
 * Key perturbations:
 *
 *   • Ceramide synthesis substrates reduced (~30%): serine 20→14, palmitoyl_coa 15→10
 *   • Mild IL-1β priming (2 tokens at t = 0)
 *   • KSC (kallikrein-5) slightly elevated (4 tokens vs healthy 2)
 *   • All repair pathways intact (mild disease = homeostatic balance possible)
 *   • NF-κB pathway active but not constitutive
 *
 * Severity tier: MILD
 *
 * Biological basis
 * ────────────────
 * Mild AD ceramide deficiency reduces lamellar body lipid content by ~30%.
 * p_spt (SPT) activity is indirectly impaired by low-grade IL-4/IL-13
 * signalling via SOCS3.  The kallikrein-5/LEKTI imbalance is modest.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/atopic_dermatitis/ad_biology_mild.mli \
 *       -o /tmp/ad_bio_mild.msim
 *   bin/msim /tmp/ad_bio_mild.msim -steps 500 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    @glue glue_cer;
    @glue glue_weak;
    @glue glue_tj;
    @glue glue_dsg;
    @glue glue_air;

    @glue_relation(glue_cer,  glue_cer);
    @glue_relation(glue_weak, glue_weak);
    @glue_relation(glue_cer,  glue_weak);
    @glue_relation(glue_tj,   glue_tj);
    @glue_relation(glue_dsg,  glue_dsg);

    @glue_radius 0.10;

    /* sc_healthy — ceramide-depleted but structurally intact (mild AD) */
    @tile sc_healthy(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_cer, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_cer, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_cer, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_cer, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_cer, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_cer, angle=60);
        @connector c_top(vertices=[center], glue=glue_air, angle=90);
        @connector c_base(vertices=[center], glue=glue_tj,  angle=-90);
        @surface_glue glue_air;
        @color Wheat alpha=200;
        @protion p_cc at ( 4,  4);
        @protion p_cc at ( 4, -4);
        @protion p_cc at (-4,  4);
        @protion p_cc at (-4, -4);
        @protion p_cc at ( 0,  0);
        @protion p_spt at (2, 0);    /* SPT mildly impaired (fewer substrates available) */
    }

    /* sc_inflamed — present in mild AD at low frequency */
    @tile sc_inflamed(sides=6, radius=10) {
        @connector c1(vertices=[v1,v2], glue=glue_weak, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_weak, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_weak, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_weak, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_weak, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_weak, angle=60);
        @connector c_top(vertices=[center], glue=glue_air, angle=90);
        @connector c_base(vertices=[center], glue=glue_tj,  angle=-90);
        @surface_glue glue_air;
        @color OrangeRed alpha=160;
        @protion p_spt at (0, 0);
    }

    /* granular_cell — lamellar body exocytosis slightly reduced */
    @tile granular_cell(sides=6, radius=9) {
        @connector c1(vertices=[v1,v2], glue=glue_dsg, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_dsg, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_dsg, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_dsg, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_dsg, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_dsg, angle=60);
        @connector c_apical(vertices=[center], glue=glue_tj, angle=90);
        @connector c_basal(vertices=[center], glue=glue_tj, angle=-90);
        @surface_glue glue_dsg;
        @color LightYellow alpha=200;
        @protion p_lb  at ( 3,  3);
        @protion p_lb  at (-3,  3);
        @protion p_lb  at ( 0,  4);
        @protion p_gba at (0, -2);
        @protion p_nfkb at (-3, -3);
    }

    @seed sc_healthy at (0, 0, 0);
}

/* ── Floating objects — mild AD: ceramide substrates reduced ─────────────── */

/* Sphingolipid substrates reduced ~30% in mild AD */
@floating serine(mobility=6, radius=0.03, concentration=14);       /* healthy=20, mild=14 */
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=10); /* healthy=15, mild=10 */
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Mild inflammatory priming: IL-1β present at t = 0 */
@floating il1b(mobility=7, radius=0.04, concentration=2);          /* healthy=0, mild=2 */
@floating tnfa(mobility=7, radius=0.04, concentration=0);
@floating nfkb_active(mobility=5, radius=0.05, concentration=0);

/* KSC slightly elevated in mild AD (LEKTI/serine protease imbalance) */
@floating ksc(mobility=4, radius=0.05, concentration=4);            /* healthy=2, mild=4 */
@floating cdsn(mobility=1, radius=0.10, concentration=5);

/* Repair signal intact in mild AD */
@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cc;
@protion p_spt;
@protion p_lb;
@protion p_gba;
@protion p_nfkb;

/* ── Sigma release mappings ──────────────────────────────────────────────── */
/* Reduced ceramide release (lamellar body lipid content ~70% of healthy) */
@sigma(glue_tj, glue_tj) = ceramide, ceramide;    /* healthy=3 ceramides; mild=2 */

/* Inflamed front propagates IL-1β (same as healthy baseline) */
@sigma(glue_weak, glue_cer) = il1b, il1b;

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Ceramide synthesis (substrate-limited in mild AD) */
    p_spt: serine, palmitoyl_coa --> sphinganine;
    sphinganine --> dihydroceramide;
    dihydroceramide --> ceramide;
    p_gba: glucosylceramide --> ceramide;

    /* Lamellar body exocytosis (slightly impaired LB content in mild AD) */
    p_lb: ceramide, ceramide, ceramide --> lb_vesicle;
    p_lb: lb_vesicle --> ceramide, ceramide, ceramide;

    /* Desquamation (mildly elevated KSC activity) */
    p_cc: ksc, cdsn --> cdsn_cleaved;
    @destroy dsq_signal, sc_healthy --> serine, serine, repair_signal;
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* NF-κB cascade (mild AD: activated but not constitutive) */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;
    nfkb_active --> il1b, tnfa, nfkb_active;
    nfkb_active, ceramide --> nfkb_active;

    /* Inflammatory tile replacement (same threshold as healthy) */
    @create nfkb_active, nfkb_active, sc_healthy --> sc_inflamed;
    @destroy nfkb_active, sc_inflamed --> il1b, tnfa;

    /* Barrier repair (intact in mild AD) */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;
    repair_signal, nfkb_active --> repair_signal;

    /* Granular cell supply (slightly reduced substrate) */
    @create serine, serine, palmitoyl_coa, palmitoyl_coa --> granular_cell;
    @destroy repair_signal, granular_cell --> serine, serine,
                                              palmitoyl_coa, palmitoyl_coa;
}
