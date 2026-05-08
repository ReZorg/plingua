# TODO examples catalog for P-systems & membrane computing

This catalog was prepared from GitHub and web sources to track known implementations and prioritize new example models for this repository.

## 1) Known implementations (GitHub + web)

| Implementation | Scope | Evidence |
|---|---|---|
| `RGNC/plingua` | P-Lingua compiler/simulator for membrane computing | https://github.com/RGNC/plingua |
| `manugarciaquismondo/pLinguaCore` | P-Lingua core implementation | https://github.com/manugarciaquismondo/pLinguaCore |
| `manugarciaquismondo/pLinguaPlugin` | Eclipse plugin for modeling/simulation with pLinguaCore | https://github.com/manugarciaquismondo/pLinguaPlugin |
| `RGNC/pcuda` | GPU simulator for P systems with active membranes | https://github.com/RGNC/pcuda |
| PMCGPU project (PCUDA, PCUDASAT, TSPCUDASAT, ABCD-GPU, ENPS-GPU, SNP-GPGPU) | Parallel/GPU simulators for membrane computing | https://sourceforge.net/p/pmcgpu/wiki/Home/ |
| `quancs/UPSimulator` | General P system simulator (cell-like, tissue-like, neural-like) | https://github.com/quancs/UPSimulator |
| `Kernel-P-Systems/kPWorkbench` | kP-Lingua framework for simulation + formal verification | https://github.com/Kernel-P-Systems/kPWorkbench |
| `a1sabau/spiking-p-system` | Spiking neural P system implementation | https://github.com/a1sabau/spiking-p-system |
| `RodGal-2020/psystems-examples` | Cross-simulator P-system example collection | https://github.com/RodGal-2020/psystems-examples |
| MeCoSim (web-documented) | Membrane Computing Simulator with P-Lingua ecosystem support | http://www.p-lingua.org/mecosim/ |
| GPLingua (web-documented) | Graphical modeling support in P-Lingua ecosystem | http://www.p-lingua.org/wiki/index.php/Download |
| PLPS (web-documented) | Parallel simulation tooling in P-Lingua ecosystem | http://www.p-lingua.org/wiki/index.php/Download |

> Notes
> - P-Lingua web resources are included from discoverable references even when direct fetch may be unavailable from this environment.
> - This is a living catalog; additions should be evidence-backed (repository, official docs, or paper landing page).

## 2) TODO examples backlog (sorted by P-system type, application category, complexity)

Complexity levels: **L1 = introductory**, **L2 = intermediate**, **L3 = advanced/research-grade**.

| P-system type | Application category | Complexity | TODO example target | Why add it / source inspiration |
|---|---|---:|---|---|
| Cell-like (transition) | Formal languages / automata | L1 | `todo_transition_language_acceptor.pli` | Minimal recognizer-style transition system baseline |
| Cell-like (active membranes) | SAT / NP-complete | L1 | `todo_sat_active_membranes_minimal.pli` | Simple SAT instance with explicit membranes/rules (PCUDASAT lineage) |
| Cell-like (active membranes) | SAT / NP-complete | L2 | `todo_sat_active_membranes_parametric.pli` | Parameterized SAT generator with input scaling |
| Cell-like (active membranes) | Verification workflows | L2 | `todo_active_membranes_roundtrip_stress.pli` | Stresses compile/simulate round-trip behavior |
| Kernel P systems | Verification (LTL/CTL) | L2 | `todo_kp_queries_safety_liveness.md` | Aligns with kPWorkbench query/verification style |
| Kernel P systems | Multi-agent systems | L3 | `todo_kp_flame_agent_coordination.pli` | kPWorkbench + FLAME style scenario |
| Probabilistic / PDP | Ecology | L1 | `todo_pdp_two_species_competition.pli` | Small stochastic ecosystem starter model |
| Probabilistic / PDP | Ecology | L2 | `todo_pdp_predator_prey_with_capacity.pli` | Capacity-limited predator-prey model |
| Probabilistic / PDP | Epidemiology | L2 | `todo_pdp_sir_contact_network.pli` | Disease spread with stochastic transition rules |
| Probabilistic / PDP | Socio-economic systems | L3 | `todo_pdp_market_microdynamics.pli` | Inspired by market-modeling PDP codepack |
| Spiking neural P systems | Arithmetic / language generation | L1 | `todo_snp_3k_plus_2.pli` | Mirrors canonical small SNP examples |
| Spiking neural P systems | Control / temporal encoding | L2 | `todo_snp_delay_coding.pli` | Demonstrates delay-heavy firing semantics |
| Spiking neural P systems | GPU-ready workloads | L3 | `todo_snp_large_dense_topology.pli` | Benchmark-style model inspired by SNP-GPGPU/cusnp lines |
| Tissue-like | SAT / NP-complete | L1 | `todo_tissue_sat_minimal.pli` | Minimal tissue SAT variant (TSPCUDASAT lineage) |
| Tissue-like | SAT / NP-complete | L2 | `todo_tissue_sat_parametric.pli` | Scalable tissue SAT families |
| Tissue-like | Distributed routing / graph dynamics | L2 | `todo_tissue_graph_reachability.pli` | Message-passing over tissue graph structure |
| Tissue-like | Bio-inspired communication | L3 | `todo_tissue_multichannel_transport.pli` | Multi-channel communication patterns (UPSimulator-like feature set) |
| Numerical / enzymatic | Robotics / navigation | L3 | `todo_enps_navigation_controller.pli` | Inspired by ENPS simulator usage in robotics contexts |

## 3) Prioritized near-term TODO set for this repository

1. ✅ `todo_pdp_two_species_competition.pli` (Probabilistic/PDP, Ecology, L1) — uses `pdp_model.pli`
2. ✅ `todo_snp_3k_plus_2.pli` (Spiking neural, Arithmetic, L1) — uses `snp_model.pli`
3. ✅ `todo_tissue_sat_minimal.pli` (Tissue-like, SAT, L1) — uses `tissue_division_model.pli`
4. ✅ `todo_sat_active_membranes_minimal.pli` (Cell-like active membranes, SAT, L1) — uses `membrane_division_model.pli`
5. ✅ `todo_transition_language_acceptor.pli` (Transition, formal-language baseline, L1) — uses `transition_model.pli`

## 4) Completed L2 / L3 examples

| P-system type | Example file | Status |
|---|---|---|
| Cell-like (active membranes) | `todo_sat_active_membranes_parametric.pli` | ✅ L2 |
| Cell-like (active membranes) | `todo_active_membranes_roundtrip_stress.pli` | ✅ L2 |
| Probabilistic / PDP | `todo_pdp_predator_prey_with_capacity.pli` | ✅ L2 |
| Probabilistic / PDP | `todo_pdp_sir_contact_network.pli` | ✅ L2 |
| Spiking neural P systems | `todo_snp_delay_coding.pli` | ✅ L2 |
| Tissue-like | `todo_tissue_sat_parametric.pli` | ✅ L2 |
| Tissue-like | `todo_tissue_graph_reachability.pli` | ✅ L2 |
| Kernel P systems | `todo_kp_queries_safety_liveness.md` | ✅ L2 (doc) |
| Probabilistic / PDP | `todo_pdp_market_microdynamics.pli` | ✅ L3 |
| Spiking neural P systems | `todo_snp_large_dense_topology.pli` | ✅ L3 |
| Tissue-like | `todo_tissue_multichannel_transport.pli` | ✅ L3 |

## 5) Remaining backlog (not yet implemented)

| P-system type | Example file | Reason pending |
|---|---|---|
| Kernel P systems | `todo_kp_flame_agent_coordination.pli` | No kP model in P-Lingua yet |
| Numerical / enzymatic | `todo_enps_navigation_controller.pli` | No ENPS model in P-Lingua yet |

---

## 6) Skin — Multiscale Cosmeceutical Model (all phases complete)

Complexity levels: **L1 = introductory**, **L2 = intermediate**, **L3 = advanced/research-grade**.

| Phase | P-system type / DSL | Application | Complexity | Example file | Description |
|---|---|---|---:|---|---|
| 1 | Cell-like (transition) | Transdermal PBPK | L1 | `skin/sc_ve_diffusion.pli` | 1D two-compartment Fickian diffusion (donor→SC→VE→sink); validates against Franz cell caffeine data |
| 2 | M-Lingua spatial | Skin tissue geometry | L2 | `skin/skin_layers.mli` | 3D stratified SC/VE/dermis tile system with transcellular + intercellular routes; cosmeceutical floating objects |
| 2 | M-Lingua spatial | Appendageal pathway | L2 | `skin/follicle_shunt.mli` | Hair follicle bypass route (infundibulum, isthmus, bulge, sebaceous gland); nanoparticle deposition |
| 3 | M-Lingua metabolic | Barrier biology | L3 | `skin/barrier_repair.mli` | Ceramide de novo synthesis (SPT→dihydroceramide→ceramide), lamellar body exocytosis, desquamation counter, NF-κB inflammatory cascade, barrier repair |
| 4 | M-Lingua metabolic | Cosmeceutical actives | L2 | `skin/actives/cbd.mli` | CBD pharmacology: CB2R anti-inflammatory, TRPV1 ceramide stimulation, PPARγ sebostatic effect, mast cell modulation |
| 4 | M-Lingua metabolic | Cosmeceutical actives | L2 | `skin/actives/retinol.mli` | Retinoid cascade (retinol→RAL→RA→CRABP→RAR/RXR): collagen synthesis, MMP inhibition, cornification, retinoid dermatitis |
| 4 | M-Lingua metabolic | Cosmeceutical actives | L2 | `skin/actives/niacinamide.mli` | Niacinamide pathways: NAD⁺ biosynthesis, SIRT1 anti-inflammatory, PAR-2 melanin-transfer block, anti-glycation, barrier lipid upregulation |
| 4 | M-Lingua metabolic | Cosmeceutical actives | L2 | `skin/actives/aha.mli` | AHA keratolysis: pH-dependent kallikrein activation, corneodesmolysis, Ca²⁺ sequestration, cell-cycle counter, post-exfoliation repair |
| 5 | R-Lingua | Parameter calibration | L3 | `skin/skin_rr.rli` | Trielectic ennead formulation optimisation: 3 agents (CBD oil, niacinamide gel, retinol liposome) × 3 arenas (SC, VE, dermis); grip index = bioavailability optimality |
| 6 | OpenCog (PLN + ECAN + OpenPsi) | PBPK systemic coupling | L3 | `opencog/skin_pbpk.pli` | Full PBPK: SC→VE→dermis→blood→liver; PLN safety/efficacy inference; ECAN rate-limiting-barrier attention; OpenPsi competence/integrity/exploration drives |

### Skin model documentation

See `docs/SKIN_MODEL_SPEC.md` for the complete language specification, parameter tables, and validation guidance.
