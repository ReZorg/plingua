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

1. ✅ `todo_pdp_two_species_competition.pli` (Probabilistic/PDP, Ecology, L1)
2. ✅ `todo_snp_3k_plus_2.pli` (Spiking neural, Arithmetic, L1) — uses `snp_model.pli`
3. ✅ `todo_tissue_sat_minimal.pli` (Tissue-like, SAT, L1)
4. ✅ `todo_sat_active_membranes_minimal.pli` (Cell-like active membranes, SAT, L1)
5. ✅ `todo_transition_language_acceptor.pli` (Transition, formal-language baseline, L1)
