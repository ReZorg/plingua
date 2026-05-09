/*
 * follicle_shunt.mli — Phase 2: Appendageal (Follicular) Shunt Pathway
 *
 * Models the hair follicle as a high-flux bypass route that circumvents
 * the rate-limiting SC lipid barrier.  The follicular shunt is especially
 * important for:
 *   • Large, charged, or highly polar molecules (poor SC permeants)
 *   • Nanoparticle and liposome formulations
 *   • Rapid early-time skin uptake (before SC steady-state is reached)
 *
 * Structure modelled
 * ──────────────────
 *   follicle_infundibulum  — upper funnel region (open to skin surface)
 *   follicle_isthmus       — narrow neck connecting infundibulum to bulge
 *   follicle_bulge         — stem-cell niche, tight-junction sealing
 *   follicle_sebaceous     — sebaceous gland duct (lipid secretion)
 *
 * Tile connectivity
 * ─────────────────
 *   Infundibulum ↔ isthmus ↔ bulge : continuous aqueous channel
 *   Sebaceous duct joins isthmus    : lipid secretion creates local
 *                                     lipid phase (enriches lipophilic drug)
 *   Bulge connects to VE tile layer : drug exits follicle into viable tissue
 *
 * Reference: Otberg et al. (2004) JID; Teichmann et al. (2006) EJP;
 *            Lademann et al. (2008) Adv. Drug Deliv. Rev.
 *
 * Run:
 *   bin/mlingua examples/skin/follicle_shunt.mli -o /tmp/follicle.msim
 *   bin/msim /tmp/follicle.msim -steps 300 -v
 */

@msystem<morphogenetic>

@geometry euclidean;

@tiling {

    /* ── Glue definitions ─────────────────────────────────────────────── */
    @glue glue_fol;      /* follicle-channel inner-wall glue             */
    @glue glue_seb;      /* sebaceous duct glue (lipid-secreting)        */
    @glue glue_bulge;    /* bulge–VE interface glue                      */
    @glue glue_inf;      /* infundibulum–SC interface glue               */
    @glue glue_aq;       /* aqueous-channel pairing                      */
    @glue glue_open;     /* open surface (no opposing tile)              */

    /* Compatible pairs */
    @glue_relation(glue_fol,   glue_fol);
    @glue_relation(glue_seb,   glue_seb);
    @glue_relation(glue_bulge, glue_bulge);
    @glue_relation(glue_inf,   glue_inf);
    @glue_relation(glue_aq,    glue_aq);

    @glue_radius 0.20;   /* wider channel than SC intercellular gap */

    /* ────────────────────────────────────────────────────────────────────
     * TILE: follicle_infundibulum
     *
     * Upper funnel of hair follicle.  Wide cylindrical cross-section
     * (radius ~40 µm), open to SC/donor at top, connects to isthmus below.
     * Modelled as circular tile (sides=8 approximation).
     */
    @tile follicle_infundibulum(sides=8, radius=40) {
        /* Lateral wall connectors (follicle self-sealing) */
        @connector c1(vertices=[v1,v2], glue=glue_fol, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fol, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fol, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fol, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fol, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fol, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fol, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fol, angle=45);
        /* Open top: receives drug from donor / SC surface */
        @connector c_top(vertices=[center], glue=glue_inf, angle=90);
        /* Bottom: connects to isthmus */
        @connector c_bot(vertices=[center], glue=glue_aq, angle=-90);
        @surface_glue glue_open;
        @color SandyBrown alpha=160;
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: follicle_isthmus
     *
     * Narrow neck region (radius ~20 µm); connects infundibulum to bulge.
     * Sebaceous duct joins at mid-point via glue_seb connector.
     */
    @tile follicle_isthmus(sides=8, radius=20) {
        @connector c1(vertices=[v1,v2], glue=glue_fol, angle=45);
        @connector c2(vertices=[v2,v3], glue=glue_fol, angle=45);
        @connector c3(vertices=[v3,v4], glue=glue_fol, angle=45);
        @connector c4(vertices=[v4,v5], glue=glue_fol, angle=45);
        @connector c5(vertices=[v5,v6], glue=glue_fol, angle=45);
        @connector c6(vertices=[v6,v7], glue=glue_fol, angle=45);
        @connector c7(vertices=[v7,v8], glue=glue_fol, angle=45);
        @connector c8(vertices=[v8,v1], glue=glue_fol, angle=45);
        /* Upper: receives from infundibulum */
        @connector c_top(vertices=[center], glue=glue_aq, angle=90);
        /* Lower: connects to bulge */
        @connector c_bot(vertices=[center], glue=glue_aq, angle=-90);
        /* Sebaceous duct inlet (lateral) */
        @connector c_seb(vertices=[v3,v4], glue=glue_seb, angle=0);
        @surface_glue glue_open;
        @color SaddleBrown alpha=150;
        /* Protion for sebum lipid processing */
        @protion p_seb at (5, 0);
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: follicle_bulge
     *
     * Stem-cell niche (radius ~15 µm).  Tight-junction sealed.
     * Bottom face glues to keratinocyte tiles in VE layer.
     */
    @tile follicle_bulge(sides=6, radius=15) {
        @connector c1(vertices=[v1,v2], glue=glue_fol, angle=60);
        @connector c2(vertices=[v2,v3], glue=glue_fol, angle=60);
        @connector c3(vertices=[v3,v4], glue=glue_fol, angle=60);
        @connector c4(vertices=[v4,v5], glue=glue_fol, angle=60);
        @connector c5(vertices=[v5,v6], glue=glue_fol, angle=60);
        @connector c6(vertices=[v6,v1], glue=glue_fol, angle=60);
        /* Top: receives from isthmus */
        @connector c_top(vertices=[center], glue=glue_aq, angle=90);
        /* Bottom: drug exits into VE / dermal tissue */
        @connector c_exit(vertices=[center], glue=glue_bulge, angle=-90);
        @surface_glue glue_open;
        @color RosyBrown alpha=180;
        @protion p_stem at (0, 0);   /* stem-cell renewal marker */
    }

    /* ────────────────────────────────────────────────────────────────────
     * TILE: sebaceous_gland
     *
     * Lipid-secreting gland (radius ~30 µm, rounded quad tile).
     * Connected to follicle_isthmus via glue_seb.
     */
    @tile sebaceous_gland(sides=4, radius=30) {
        @connector c1(vertices=[v1,v2], glue=glue_seb, angle=90);
        @connector c2(vertices=[v2,v3], glue=glue_seb, angle=90);
        @connector c3(vertices=[v3,v4], glue=glue_seb, angle=90);
        @connector c4(vertices=[v4,v1], glue=glue_seb, angle=90);
        /* Duct outlet into isthmus */
        @connector c_duct(vertices=[center], glue=glue_seb, angle=0);
        @surface_glue glue_open;
        @color Gold alpha=130;
        @protion p_lip at (0, 0);   /* lipid synthesis protion */
        @protion p_lip at (5, 5);
    }

    /* ── Seed: infundibulum at origin */
    @seed follicle_infundibulum at (0, 0, 0);
}

/* ── Floating objects ─────────────────────────────────────────────────── */

/*
 * drug_aq — aqueous-soluble drug entering follicular channel
 * (high mobility in aqueous lumen; low in lipid phases)
 */
@floating drug_aq(mobility=5.5, radius=0.04, concentration=30);

/*
 * drug_lipo — lipophilic drug / nanoparticle
 * (low aqueous mobility; sequestered by sebum lipids in isthmus)
 */
@floating drug_lipo(mobility=1.5, radius=0.12, concentration=15);

/*
 * sebum — sebaceous lipid secretion
 * (fills follicular canal; partitions lipophilic drugs)
 */
@floating sebum(mobility=0.8, radius=0.15, concentration=5);

/*
 * nanoparticle — NP formulation bypassing SC via follicle
 * (very low mobility; deposits in infundibulum / isthmus)
 */
@floating nanoparticle(mobility=0.3, radius=0.50, concentration=8);

/* ── Protion declarations ─────────────────────────────────────────────── */
@protion p_seb;    /* sebum lipid processor in isthmus          */
@protion p_stem;   /* stem-cell renewal marker in bulge         */
@protion p_lip;    /* lipid synthesis in sebaceous gland        */

/* ── Sigma: glue-pair release mappings ───────────────────────────────── */
/*
 * When infundibulum bonds to SC-corneocyte (glue_inf pair),
 * release follicular-entry signal: two drug_aq tokens start the shunt.
 */
@sigma(glue_inf, glue_inf) = drug_aq, drug_aq;

/*
 * When bulge exits into dermis/VE (glue_bulge pair),
 * release follicular drug bolus into viable tissue.
 */
@sigma(glue_bulge, glue_bulge) = drug_aq, drug_lipo;

@reaction_distance 18;

/* ── Rules ─────────────────────────────────────────────────────────────── */
def main() {

    /* ── Follicular channel assembly ─────────────────────────────────
     * Self-assembly of channel tiles from structural proteins (prot_f).
     */
    @create prot_f, prot_f, prot_f --> follicle_infundibulum;
    @create prot_f, prot_f        --> follicle_isthmus;
    @create prot_f, stem_signal   --> follicle_bulge;

    /* ── Sebaceous gland assembly ─────────────────────────────────────
     * Lipid precursors + androgen signal → sebaceous gland tile.
     */
    @create sebum, sebum, sebum, androgen --> sebaceous_gland;

    /* ── Sebum secretion into isthmus ─────────────────────────────────
     * p_lip protion catalyses sebum lipid production.
     */
    p_lip: sebum --> sebum, sebum;

    /* ── Sebum-mediated drug partitioning ─────────────────────────────
     * p_seb in isthmus: lipophilic drug associates with sebum.
     * Sebum acts as drug reservoir in the follicular channel.
     */
    p_seb: drug_lipo, sebum --> drug_lipo_seb;
    p_seb: drug_lipo_seb    --> drug_lipo, sebum;   /* slow release */

    /* ── Nanoparticle deposition ──────────────────────────────────────
     * Large NPs deposit in infundibulum and isthmus, then slowly release
     * encapsulated drug.
     */
    @create nanoparticle, nanoparticle --> follicle_infundibulum;
    nanoparticle --> drug_aq, drug_aq, drug_aq;   /* drug release from NP */

    /* ── Stem cell renewal (follicle_bulge protion) ───────────────────
     * p_stem drives continuous epithelial renewal in bulge.
     */
    p_stem: stem_signal --> stem_signal, prot_f;

    /* ── Follicle remodelling / atresia ──────────────────────────────
     * Atresia signal destroys old isthmus tile; rebuilding follows.
     */
    @destroy atresia, follicle_isthmus --> prot_f, prot_f;

    /* ── Drug delivery to dermis (exit from bulge) ────────────────────
     * Drug leaving bulge becomes systemically available.
     */
    drug_aq  --> drug_aq_sys;
    drug_lipo --> drug_lipo_sys;
}
