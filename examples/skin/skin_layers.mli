/*
 * skin_layers.mli — Phase 2: Spatial Stratified Skin Geometry
 *
 * 3D stratified tissue structure with three distinct layers:
 *   • Stratum Corneum (SC)   — flat corneocyte + lipid-bilayer matrix
 *   • Viable Epidermis (VE)  — keratinocyte monolayer
 *   • Dermis                 — fibroblast-rich connective tissue
 *
 * Mechanistic basis
 * ─────────────────
 * SC corneocytes are modelled as flat hexagonal tiles arranged in a
 * brick-wall (offset) lattice.  Intercellular lipid lamellae are
 * represented by lipid-glue connectors (glue_lam).  The transcellular
 * route uses through-connectors on corneocyte faces; the intercellular
 * (tortuous) route uses lateral lipid connectors with increased tortuosity
 * encoded in glue_radius.  Keratinocyte and fibroblast tiles sit below the
 * SC in separate layers connected by basal-lamina glue.
 *
 * Floating objects represent cosmeceutical molecules diffusing through the
 * tile graph; their mobility and radius encode diffusivity and molecular
 * size respectively.
 *
 * Reference: Notman & Anwar (2013) Biochemistry; Kattou et al. (2019)
 * Pharm. Res.; IHE/OECD skin-permeation guidelines.
 *
 * Run:
 *   bin/mlingua examples/skin/skin_layers.mli -o /tmp/skin_layers.msim
 *   bin/msim /tmp/skin_layers.msim -steps 500 -v
 */

@msystem<morphogenetic>

/* ── Geometry profile ──────────────────────────────────────────────────── */
@geometry euclidean;

/* ── Tiling system ─────────────────────────────────────────────────────── */
@tiling {

    /* ── Glue definitions ─────────────────────────────────────────────── */

    /* SC lipid-bilayer lateral glue (intercellular route) */
    @glue glue_lam;
    /* SC corneocyte-to-corneocyte transcellular face glue */
    @glue glue_cc;
    /* SC–VE basal interface glue */
    @glue glue_sc_ve;
    /* VE–dermis interface glue */
    @glue glue_ve_d;
    /* Keratinocyte lateral tight-junction glue */
    @glue glue_tj;
    /* Dermis fibroblast lateral glue */
    @glue glue_fb;
    /* Surface (air-facing) non-reactive glue */
    @glue glue_air;

    /* ── Glue compatibility relations ─────────────────────────────────
     *
     * Only matching glue pairs can bond.  Asymmetric glue_sc_ve models
     * directed flux from SC into VE; glue_lam self-pairs for lateral
     * lipid continuity.
     */
    @glue_relation(glue_lam,   glue_lam);    /* lipid–lipid lateral bond    */
    @glue_relation(glue_cc,    glue_cc);     /* corneocyte–corneocyte bond   */
    @glue_relation(glue_sc_ve, glue_sc_ve);  /* SC basal face → VE apical   */
    @glue_relation(glue_ve_d,  glue_ve_d);   /* VE basal face → dermis       */
    @glue_relation(glue_tj,    glue_tj);     /* tight-junction sealing       */
    @glue_relation(glue_fb,    glue_fb);     /* fibroblast–fibroblast ECM    */

    /*
     * Glue radius: intercellular lipid channel width ~0.04 µm modelled
     * as tight radius; transcellular connector is broader.
     */
    @glue_radius 0.12;

    /* ──────────────────────────────────────────────────────────────────
     * TILE: sc_corneocyte
     *
     * Flat hexagonal tile (sides=6) representing a single corneocyte.
     * Radius ~10 µm × 0.3 µm (highly flattened).
     *
     * Connectors:
     *   c1–c6  : lateral lipid-bilayer edges (glue_lam) — intercellular
     *   c_top  : apical face (air-facing, glue_air)
     *   c_base : basal face (SC–VE interface, glue_sc_ve)
     *   c_trans: transcellular pore channel (glue_cc)
     */
    @tile sc_corneocyte(sides=6, radius=10) {
        /* Lateral lipid-bilayer connectors (intercellular route) */
        @connector c1(vertices=[v1,v2], glue=glue_lam, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_lam, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_lam, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_lam, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_lam, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_lam, angle=60);
        /* Transcellular channel (top–bottom through-pore) */
        @connector c_trans(vertices=[center], glue=glue_cc, angle=90);
        /* Apical face: air-skin interface */
        @connector c_top(vertices=[center], glue=glue_air, angle=180);
        /* Basal face: SC → VE junction */
        @connector c_base(vertices=[center], glue=glue_sc_ve, angle=-90);
        @surface_glue glue_air;
        @color Beige alpha=180;
    }

    /* ──────────────────────────────────────────────────────────────────
     * TILE: keratinocyte
     *
     * Polygonal (hexagonal) keratinocyte in the viable epidermis.
     * Radius ~8 µm; lateral tight junctions seal the paracellular space.
     */
    @tile keratinocyte(sides=6, radius=8) {
        @connector c1(vertices=[v1,v2], glue=glue_tj, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_tj, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_tj, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_tj, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_tj, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_tj, angle=60);
        /* Apical face receives drug from SC basal face */
        @connector c_apical(vertices=[center], glue=glue_sc_ve, angle=90);
        /* Basal face delivers to dermis */
        @connector c_basal(vertices=[center], glue=glue_ve_d, angle=-90);
        @surface_glue glue_tj;
        @color PaleGreen alpha=140;
        /* Lamellar body secretion site (Phase 3) */
        @protion p_lb at (0, 3);
        @protion p_lb at (0, -3);
    }

    /* ──────────────────────────────────────────────────────────────────
     * TILE: dermal_fibroblast
     *
     * Irregular (octagonal proxy) fibroblast in dermis.
     * Radius ~12 µm; connected by extracellular matrix (ECM) glue.
     */
    @tile dermal_fibroblast(sides=8, radius=12) {
        @connector c1(vertices=[v1,v2], glue=glue_fb, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fb, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fb, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fb, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fb, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fb, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fb, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fb, angle=45);
        /* Apical face receives drug from VE */
        @connector c_apical(vertices=[center], glue=glue_ve_d, angle=90);
        /* Capillary sink connector (dermal clearance) */
        @connector c_cap(vertices=[center], glue=glue_air, angle=-90);
        @surface_glue glue_fb;
        @color LightCoral alpha=120;
        /* Collagen synthesis site (Phase 4 peptides) */
        @protion p_col at (0, 0);
    }

    /* ── Seed: single SC corneocyte at origin — self-assembly builds layer */
    @seed sc_corneocyte at (0, 0, 0);
}

/* ── Floating cosmeceutical molecules ─────────────────────────────────── */

/*
 * Caffeine (reference compound, log P −0.07, MW 194 Da)
 * High aqueous mobility; small radius.
 */
@floating caffeine(mobility=4.5, radius=0.04, concentration=50);

/*
 * Generic hydrophilic active (represents niacinamide, vitamin C, etc.)
 * log P < 1, MW < 250 Da
 */
@floating active_hydrophilic(mobility=3.8, radius=0.05, concentration=20);

/*
 * Generic lipophilic active (represents retinol, CBD, etc.)
 * log P > 3, MW > 300 Da — lower aqueous mobility
 */
@floating active_lipophilic(mobility=1.8, radius=0.08, concentration=10);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_lb;   /* lamellar body secretion site (keratinocyte apical) */
@protion p_col;  /* collagen synthesis site (fibroblast) */

/* ── Sigma: glue-pair release mappings ───────────────────────────────── */
/*
 * When SC_corneocyte connects to keratinocyte (glue_sc_ve pair),
 * release ceramide lipid objects (lamellar body exocytosis signal).
 */
@sigma(glue_sc_ve, glue_sc_ve) = ceramide, ceramide;

/*
 * When keratinocyte connects to fibroblast (glue_ve_d pair),
 * release EGF growth-factor proxy (paracrine signalling).
 */
@sigma(glue_ve_d, glue_ve_d) = egf;

/* ── Reaction distance (lipid bilayer width ≈ 0.04 µm proxy) ─────────── */
@reaction_distance 12;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ── SC self-assembly: corneocytes form from lipid building blocks ─
     *
     * Lipid precursors aggregate to form new corneocyte tiles.
     * Three lipid tokens → one sc_corneocyte tile (simplified).
     */
    @create ceramide, ceramide, ceramide --> sc_corneocyte;

    /* ── Desquamation: surface corneocyte shedding ────────────────────
     *
     * Top-layer corneocytes shed when desquamation signal (dsq) present.
     * Releases lipid objects back to environment.
     */
    @destroy dsq, sc_corneocyte --> ceramide, ceramide;

    /* ── VE growth: keratinocyte proliferation ───────────────────────
     *
     * Epidermal growth factor (EGF) drives keratinocyte division.
     */
    @create egf, egf, egf --> keratinocyte;

    /* ── Dermis maintenance: fibroblast creation ─────────────────────
     *
     * Collagen precursors (col_pre) + TGF-β signal → fibroblast tile.
     */
    @create col_pre, col_pre, tgfb --> dermal_fibroblast;

    /* ── Fibroblast division at ECM boundary ─────────────────────────
     *
     * When two fibroblasts meet at ECM glue, TGF-β is released.
     */
    @divide glue_fb, tgfb, glue_fb --> glue_fb, glue_fb;

    /* ── Metabolic: transcellular drug transport through SC ──────────
     *
     * Lipophilic active partitions into corneocyte lipid phase.
     * p_lb protion catalyses lamellar body exocytosis of ceramide.
     */
    p_lb: active_lipophilic --> active_lipophilic, ceramide;

    /* ── Metabolic: capillary drug clearance in dermis ───────────────
     *
     * Fibroblast p_col protion acts as clearance catalyst (represents
     * capillary uptake / protein binding in dermis).
     */
    p_col: caffeine --> caffeine_clr;
    p_col: active_hydrophilic --> active_clr;
    p_col: active_lipophilic  --> active_clr;

    /* ── Intercellular lipid route: caffeine diffusion ───────────────
     *
     * Caffeine diffuses laterally through lipid lamellae.
     * Direct metabolic conversion between lipid channels.
     */
    caffeine --> caffeine;

    /* ── Tight junction regulation ───────────────────────────────────
     *
     * Calcium (Ca2+) signal stabilises tight junctions in VE.
     * Low Ca2+ → paracellular route opens (glue_tj weakened).
     */
    ca2p --> tj_signal;
    tj_signal --> ca2p;
}
