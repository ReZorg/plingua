# FinOps Membrane Reconciliation — accospace + isabellex + fincosys

A membrane computing financial accounting system: the accospace metagraph of
the fincosys ecosystem, re-drawn as a transition P system whose evolution *is*
the reconciliation of the whole supply chain.

Models live in `examples/finops/`. They compile with `bin/plingua` and run on
`bin/psim` with no extensions.

## The image

| Metagraph | Membrane system |
|---|---|
| a cent of balance or movement | one token |
| a check between two quantities | an annihilation rule `L, R --> #` |
| an entity / account / statement | a membrane; kinds are label ranges |
| "reconciled" | the membrane annihilates to the empty multiset |
| an exception | a token that survives (the residual) |
| the exception report | the skin's multiset when the system halts (the *sediment*) |

**Normal-form theorem.** In a membrane holding left species `L` and right
species `R` where every `L` may annihilate every `R`, exhaustive annihilation
leaves tokens of one side only, and exactly `|ΣL − ΣR|` of them. The residual
is the imbalance, and it does not depend on which pairs the simulator chose to
fire first. (Proved in `cogpy/isabellex` `src/HOL/Fin/Fin_Membrane.thy`.)

Under maximal parallelism the simulator reaches the normal form in one step:
the selection loop keeps applying rules until none has a remaining
application.

## Kinds and labels

| Label | Kind | Wave | What it checks |
|---|---|---|---|
| `300+s` | statement `s` | step 1 | `o + c` vs `z + d` (opening + credits vs closing + debits) |
| `200+a` | account `a` | step 3 | `zc{s}` vs `oc{s+1}` (chain continuity); `zc{last}` vs `mz{a}` (master closing) |
| `100+e` | entity `e` | step 5 | `xo{r}` vs `xi{r}` (intra-entity transfers) |
| `0` | ecosystem | step 7 | `out{r}` vs `in{r}` (inter-company legs); `flow`/`tri` patterns |

Every membrane of a kind carries the same rule schema (`'{300+s} : 1<=s<=S`),
so one step of the simulator processes **all** statements, then all accounts,
then all entities — synchronously, however many there are. The wave count is
fixed at 7; it does not grow with the corpus.

Each membrane carries a clock (`k`, `ka`, `ke`) that counts down; at one it
dissolves with `@d` and its residual rises to the parent. Statements dissolve
at step 2, accounts at 4, entities at 6.

## Token species (amounts in cents, as multiplicities)

| Species | Meaning |
|---|---|
| `o{s} c{s} d{s} z{s}` | statement `s`: opening, credits, debits, closing |
| `oc{s} zc{s}` | chain copies of opening / closing; rise to the account |
| `mz{a}` | master (inventory) closing balance of account `a` |
| `xo{r} xi{r}` | intra-entity transfer legs, reference `r` |
| `out{r} in{r}` | inter-company payment legs, reference `r` |
| `flow{x,y}` `tri{x,y}` | one payment from entity `x` to entity `y` (round-trip / cycle markers) |
| `k{i} ka{i} ke{i}` | clocks |

## Reading the sediment

| Token in the skin | Reading |
|---|---|
| `o{s}*n` or `c{s}*n` | statement `s`: inflow side exceeds by `n` cents |
| `z{s}*n` or `d{s}*n` | statement `s`: outflow side exceeds by `n` cents |
| `oc{t}*n` (paired link) | statement `t` opens `n` cents above the previous closing: BALANCE_BREAK |
| `zc{s}*n` (paired link) | statement `s` closes `n` cents above the next opening |
| `zc{s}*n` **and** `oc{t}*m` | no pairing rule between `s` and `t`: MISSING_WINDOW (numbers skip) |
| `mz{a}*n` | inventory closing exceeds the last statement's closing by `n` |
| `out{r}` | payment left its source and never arrived: diversion suspect |
| `in{r}` | receipt with no matching outgoing leg |
| `xo{r}` / `xi{r}` | one-sided intra-entity transfer |
| `icm{r}` | inter-company payment `r` matched on both sides |
| `rt{x,y}` | round trip between entities `x` and `y` |
| `cyc{x,y,w}` | circular flow `x → y → w → x` |
| `flow` / `tri` | markers with no pattern; ignore |

The chain classes and verdicts are those of the accospace statement-chain
records and of HOL-Fin `Statements.thy`.

## Rule schemas

```
/* Wave 1 -- every statement, synchronously */
[o{s}, z{s} --> #]'{300+s} : 1<=s<=S;
[c{s}, d{s} --> #]'{300+s} : 1<=s<=S;
[o{s}, d{s} --> #]'{300+s} : 1<=s<=S;
[c{s}, z{s} --> #]'{300+s} : 1<=s<=S;
[k{1} --> @d]'{300+s}      : 1<=s<=S;

/* Wave 2 -- every account: one pairing per consecutive statement pair */
[zc{s}, oc{s+1} --> #]'{200+a};        /* emitted per linkable pair */
[zc{last}, mz{a} --> #]'{200+a};
[ka{1} --> @d]'{200+a} : 1<=a<=A;

/* Wave 3 -- every entity */
[xo{r}, xi{r} --> #]'{100+e} : 1<=e<=E, 1<=r<=R;
[ke{1} --> @d]'{100+e}       : 1<=e<=E;

/* Wave 4 -- the ecosystem */
[out{r}, in{r} --> icm{r}]'0 : 1<=r<=R;
[flow{x,y}, flow{y,x} --> rt{x,y}]'0 : x+1<=y<=E, 1<=x<=E;
[tri{x,y}, tri{y,w}, tri{w,x} --> cyc{x,y,w}]'0 : y != w, x+1<=w<=E, x+1<=y<=E, 1<=x<=E;
```

Dependent ranges are written right-to-left (`x+1<=y<=E, 1<=x<=E`), which is
the order the compiler binds them in.

## Models

| File | Instance | Sediment |
|---|---|---|
| `examples/finops/membrane_reconciliation_minimal.pli` | 2 entities, 2 accounts, 3 statements, one payment, one round trip (hand-written) | `z{3}, icm{7}, rt{1,2}` |
| `examples/finops/fincosys_fixture_reconciliation.pli` | HOL-Fin-Test fixture (AYM 202–204 continuous, PF 5/7 missing window) + RegimA main/savings + 6 payments incl. a 3-cycle and a one-sided leg (generated) | `z{4}*500, zc{6}*2000, oc{7}*2500, out{6}, icm{1,2,3,5}, rt{1,2}, rt{2,3}, cyc{1,3,2}` |
| `examples/finops/accospace_grouped_reconciliation.pli` | accospace `tests/cpp/fixtures/grouped` as-is (generated) | `d{4}*1050, z{5}*1000, zc{3}*33975, mz{1}*33975, mz{2}*7400` |
| `examples/finops/fincosys_records_reconciliation.pli` | the whole RegimA corpus from accospace `records/atomese`: 17 entities, 69 accounts, 3,433 statements (generated with `--records`) | 119 species: 54 `zc`, 46 `oc` (missing windows, balance breaks), 13 `mz` (inventory mismatches), 6 internal imbalances; matches the closed form (`--compare`) |

The generated models come from
`fincosys/accospace` `scripts/export_membrane_psystem.py`, which reads the
same master files and `fincodat.statement.v1` corpus the accospace builder
reads, or (`--records`) an `accospace records` output directory: its balance
schedules supply opening, closing, credits and debits per statement and the
link class of every chain link, which decides the pairings. Negative balances
(credit cards) are translated per account by a constant, which leaves every
residual unchanged. Regenerate rather than hand-edit.

The full corpus compiles in about a second and settles on `psim` in under two:
3,433 statement membranes verify in one step and dissolve in the next, and the
seven-step wave count is the same as for the two-entity minimal model.

```bash
make compiler simulator
bin/plingua examples/finops/fincosys_fixture_reconciliation.pli -o /tmp/fx.json
bin/psim /tmp/fx.json -v 2          # -v 2 shows the rules fired per wave
make check-finops                   # compiles and simulates all three
```

## Native twin

`o9nn/ggnumlcash.cpp` `examples/financial-sim/membrane-reconciler.h` runs the
same waves natively (a thread per chunk of membranes of a kind) and emits the
same P-Lingua text through `to_plingua()`, so the simulator and the engine
cross-check each other; `test-membrane-reconciler` covers the fixture cases
above and a 2,000-statement supply chain that settles in the same 7 steps.

## Next waves

- Tolerance: HOL-Fin's `0.01` tolerance as a second species pair that
  absorbs up to one residual cent per link.
- Ownership transitivity and fund-flow chains: non-consuming derivations need
  a generation marker to terminate under maximal parallelism.
- Live feed: new statements as new membranes injected into a running account
  membrane between waves (division rules of the active-membrane model).
- Currency: a species per currency, with rate tokens as catalysts.
