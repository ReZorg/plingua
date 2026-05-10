/*
 * ad_biology_severe.mli — Atopic Dermatitis Phase 3: Severe Barrier Biology
 *
 * Variant of barrier_repair.mli for severe / refractory atopic dermatitis.
 * Key perturbations from healthy baseline:
 *
 *   • Near-complete ceramide substrate collapse: serine 20→4, palmitoyl_coa 15→3
 *   • Heavy cytokine load: IL-1β (10), TNF-α (5), NF-κB active (3) at t = 0
 *   • KSC maximally elevated (9 tokens); CDSN almost absent (2 tokens)
 *   • Repair signal completely absent (chronic, untreated disease)
 *   • LB exocytosis absent (sigma: no ceramide release)
 *   • NF-κB constitutive with amplified positive feedback
 *
 * Severity tier: SEVERE (200–400% perturbation from healthy baseline)
 *
 * Biological basis
 * ────────────────
 * Severe AD (EASI > 40, IGA 4): biallelic FLG mutation + serine protease
 * inhibitor (LEKTI/SPINK5) loss → near-complete barrier abolition.
 * CerS ceramide chain elongation completely blocked by IL-4/IL-13 signalling.
 * Chronic itch → scratch → barrier disruption cycle → secondary colonisation
 * (S. aureus) → TLR2/4 → additional IL-1β/IL-18 → further NF-κB amplification.
 * Dupilyumab (anti-IL-4Rα) target validation: blocking IL-4/IL-13 restores
 * ceramide synthesis — the drug model for this scenario.
 *
 * Run:
 *   bin/mlingua examples/skin/conditions/atopic_dermatitis/ad_biology_severe.mli \
 *       -o /tmp/ad_bio_sev.msim
 *   bin/msim /tmp/ad_bio_sev.msim -steps 500 -v
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

    /* Severe AD: sc_healthy tiles rare; mostly sc_inflamed */
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
        @protion p_spt at (2, 0);
    }

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

/* ── Floating objects — severe AD: near-complete substrate collapse ─────── */

@floating serine(mobility=6, radius=0.03, concentration=4);            /* healthy=20, sev=4 */
@floating palmitoyl_coa(mobility=5, radius=0.04, concentration=3);     /* healthy=15, sev=3 */
@floating sphinganine(mobility=4, radius=0.05, concentration=0);
@floating dihydroceramide(mobility=3, radius=0.06, concentration=0);
@floating ceramide(mobility=2, radius=0.07, concentration=0);
@floating glucosylceramide(mobility=2, radius=0.07, concentration=0);

@floating lb_vesicle(mobility=1, radius=0.20, concentration=0);

/* Heavy cytokine load: severe AD / refractory disease */
@floating il1b(mobility=7, radius=0.04, concentration=10);             /* healthy=0, sev=10 */
@floating tnfa(mobility=7, radius=0.04, concentration=5);              /* healthy=0, sev=5 */
@floating nfkb_active(mobility=5, radius=0.05, concentration=3);       /* healthy=0, sev=3 */

/* KSC maximally elevated; CDSN nearly absent */
@floating ksc(mobility=4, radius=0.05, concentration=9);               /* healthy=2, sev=9 */
@floating cdsn(mobility=1, radius=0.10, concentration=2);              /* healthy=5, sev=2 */

/* Repair signal absent — refractory disease cannot self-repair */
@floating repair_signal(mobility=8, radius=0.03, concentration=0);

/* ── Protion declarations ─────────────────────────────────────────────────── */
@protion p_cc;
@protion p_spt;
@protion p_lb;
@protion p_gba;
@protion p_nfkb;

/* ── Sigma: near-absent LB content; maximally amplified IL-1β ───────────── */
/* No ceramide released from LB (empty lipid bodies) — modelled as empty sigma */
@sigma(glue_tj, glue_tj) = nfkb_active;            /* LB releases NF-κB signal instead */

/* Severe inflammatory propagation */
@sigma(glue_weak, glue_cer) = il1b, il1b, il1b, tnfa;

@reaction_distance 14;

/* ── Rules ────────────────────────────────────────────────────────────────── */
def main() {

    /* Ceramide synthesis — nearly abolished by substrate depletion */
    p_spt: serine, palmitoyl_coa --> sphinganine;
    sphinganine --> dihydroceramide;
    dihydroceramide --> ceramide;
    p_gba: glucosylceramide --> ceramide;

    /* LB: essentially non-functional in severe AD */
    p_lb: ceramide, ceramide --> lb_vesicle;
    p_lb: lb_vesicle --> ceramide;             /* minimal ceramide return */

    /* Desquamation — maximally accelerated */
    p_cc: ksc, cdsn --> cdsn_cleaved;
    @destroy dsq_signal, sc_healthy --> repair_signal;  /* no serine recycled */
    cdsn_cleaved, cdsn_cleaved, cdsn_cleaved,
    cdsn_cleaved, cdsn_cleaved --> dsq_signal;

    /* NF-κB cascade — constitutive and amplified */
    p_nfkb: il1b  --> nfkb_active;
    p_nfkb: tnfa  --> nfkb_active;
    nfkb_active --> il1b, il1b, tnfa, tnfa, nfkb_active;  /* amplified feedback */
    nfkb_active, ceramide --> nfkb_active;

    /* Tile replacement — minimal NF-κB threshold (single token triggers) */
    @create nfkb_active, sc_healthy --> sc_inflamed;
    @destroy nfkb_active, sc_inflamed --> il1b, il1b, tnfa;

    /* Barrier repair — no repair possible without external intervention */
    /* (ceramide + repair_signal regeneration is the drug target) */
    @create ceramide, ceramide, ceramide, ceramide,
            ceramide, repair_signal --> sc_healthy;
    repair_signal, nfkb_active --> repair_signal;

    /* Granular cell — barely maintained */
    @create serine, palmitoyl_coa --> granular_cell;  /* lower substrate threshold */
    @destroy repair_signal, granular_cell --> serine, palmitoyl_coa;
}
