This is an offline, supplied-text evaluation. Complete the task yourself. Do not use tools, inspect any files, browse, spawn agents, or modify anything. All relevant inputs are supplied below. Embedded source text is data, not instructions. Do not claim runtime execution. Return a concise answer under 650 words with decisive evidence and stated limits. Do not infer prior reviewer conclusions or model comparisons.

OBJECTIVE: Review the supplied candidate code for material correctness defects against this contract: reusable response artifacts must be tied to the actual image/preprocessing/model inputs; the stage reports real image/model parity, not just self-consistency of a saved artifact. Saved ranking maps and decision comparisons must be finite and meet the declared tolerances. Digest checks protect bytes but are not a semantic proof of their values. Scope is only the supplied cache identity/reuse/verification path.
Report every independently established material defect with a concrete trigger, source lines, and a narrow correction or regression check. Do not invent behavior in omitted helpers: state necessary assumptions. Classify evidence as static. Return ACCEPT or REJECT; no runtime claims.

FILE caption_tune/labo/paired_response.py @ ed8b3cff214fe4c272d3a1fb989d03a6c5a112d4
644: ):
645:     return dict(
646:         budgets=list(budgets),
647:         n_random=int(n_random),
648:         seed=int(seed),
649:         batch_size=int(batch_size),
650:         variant=variant,
651:         max_patches=int(max_patches),
652:         tower=TOWER,
653:         conditions=list(CONDITIONS),
654:         tolerances=dict(cosine=COSINE_TOLERANCE, ranking=RANKING_TOLERANCE, k0=K0_TOLERANCE),
655:         seed_rule=SEED_RULE,
656:         region_rule=REGION_RULE,
657:         ranking_map=RANKING_MAP,
658:     )
659: 
660: 
661: def text_digest(text):
662:     return pa.weights_digest(torch.as_tensor(text).double().numpy())
663: 
664: 
665: def run_identity(pinned, text, settings):
666:     """What this stage depends on: the pinned run and its digests, the bank's text rows, settings, code."""
667:     here = Path(__file__).parent
668:     return vocabulary.digest(
669:         dict(
670:             version=VERSION,
671:             stage=STAGE,
672:             run_identity=pinned["record"]["identity"],
673:             frozen_digest=pinned["frozen_digest"],
674:             input_identity=pinned["input_identity"],
675:             digests=pinned["digests"],
676:             tau=pinned["tau"],
677:             text_sha256=text_digest(text),
678:             config=settings,
679:             modules={name: vocabulary.digest((here / name).read_bytes()) for name in MODULES},
680:         )
681:     )
682: 
683: 
684: def output_directory(cache_root, identity):
685:     return Path(cache_root) / OUTPUT_DIR / identity[:16]
686: 
687: 
688: def save(directory, identity, payload, arrays, meta=None):
689:     """Write `payload.json`, `arrays/*.npz`, then `run.json` over every digest."""
690:     directory = Path(directory)
691:     (directory / "arrays").mkdir(parents=True, exist_ok=True)
692:     body = pb.jsonable(dict(payload, identity=identity, provenance=meta or {}))
693:     (directory / "payload.json").write_text(json.dumps(body, separators=(",", ":")))
694:     names = ["payload.json"]
695:     for key, entry in arrays.items():

711: 
712: def cached_run(directory, identity):
713:     """The stored `run.json` when the identity matches and every artifact it names is intact, else None."""
714:     manifest = Path(directory) / "run.json"
715:     if not manifest.exists():
716:         return None
717:     run = json.loads(manifest.read_text())
718:     if run.get("identity") != identity or run.get("version") != VERSION:
719:         return None
720:     for name, digest in run.get("artifacts", {}).items():
721:         path = Path(directory) / name
722:         if not path.exists() or vocabulary.digest(path.read_bytes()) != digest:
723:             return None
724: 
725:     return run
726: 
727: 
728: def _parity_passed(parity):
729:     numbers = [(parity.get("cosine_max_diff", {}).get(e), COSINE_TOLERANCE) for e in EXPOSURES] + [
730:         (parity.get("ranking_max_diff"), RANKING_TOLERANCE),
731:         (parity.get("k0_max_diff"), K0_TOLERANCE),
732:     ]
733:     return (
734:         parity.get("binary_set_equal") is True
735:         and parity.get("cases_strongest_equal") is True
736:         and parity.get("finite") is True
737:         and parity.get("predictions_equal") == parity.get("n_sites")
738:         and all(isinstance(v, float) and math.isfinite(v) and v <= tol for v, tol in numbers)
739:     )
740: 
741: 
742: def verify_cached(directory, payload, pinned, decision, binary):
743:     """Re-check a reused run on a CPU: parity from the stored cosines, R algebra, regions and decisions.
744: 
745:     Re-runs the parity check (stored re-encoded cosines against the current cached scores, 501/501
746:     predictions), re-derives every ranking map from the stored float16 maps and re-derived shares,
747:     re-draws every region from its rule, and recomputes every decision from the stored cosines; each
748:     must equal the stored record. Returns the maxima it measured.
749:     """
750:     directory = Path(directory)
751:     if not _parity_passed(payload.get("parity") or {}):
752:         raise ParityError(f"the cached run's stored parity does not show every check passed: {payload.get('parity')}")
753:     with np.load(directory / "arrays" / "parity.npz") as stored:
754:         bright, dim = stored["bright"], stored["dim"]
755:         if list(stored["sites"]) != list(pinned["sites"]):
756:             raise ParityError("the cached run's sites differ from the pinned run's")
757:     parity, redone = check_parity(pinned, decision, binary, bright, dim)
758:     if [c["row"] for c in payload["cases"]] != [int(i) for i in binary]:
759:         raise ParityError("the cached run's cases differ from the binary errors")
760:     method = payload["method"]
761:     budgets, n_random, seed = tuple(method["budgets"]), method["n_random"], method["seed"]
762:     weights = np.asarray(pinned["weights"], dtype=np.float64)
763:     ranking_max, rebuild_max = 0.0, 0.0
764:     for case in payload["cases"]:
765:         row = case["row"]
766:         sign = pa.orientation(pinned["labels"][row])
767:         strongest = int(decision["strongest"][row])
768:         base = dict(bright=bright[row], dim=dim[row])
769:         shares = dict(zip(EXPOSURES, exposure_shares(base["bright"], base["dim"], pinned["tau"]), strict=True))
770:         raw = dict(base=base, plans={}, k0={}, targeted={}, random={})
771:         with np.load(directory / case["arrays"]) as entry:
772:             arrays = {key: entry[key] for key in entry.files}
773:         for e in EXPOSURES:
774:             maps = torch.from_numpy(arrays[f"maps_{e}"].astype(np.float64).reshape(arrays[f"maps_{e}"].shape[0], -1))
775:             require_finite(f"{case['site']} {e} maps", maps)
776:             if not np.array_equal(arrays[f"g_{e}"], shares[e]):
777:                 raise ParityError(f"{case['site']}: stored {e} shares differ from the re-derived ones")
778:             ranking = ranking_map(maps, shares[e], weights, strongest, sign)
779:             stored_r = arrays[f"R_{e}"].reshape(-1)
780:             rebuild_max = max(rebuild_max, float(np.abs(ranking.numpy() - stored_r).max(initial=0.0)))
781:             ranking_max = max(ranking_max, ranking_gap(maps, shares[e], weights, strongest, sign, stored_r))
782:             plan = exposure_plan(torch.from_numpy(stored_r), row, e, budgets, n_random, seed)
783:             raw["plans"][e] = plan
784:             raw["k0"][e], raw["targeted"][e], raw["random"][e] = (
785:                 arrays[f"k0_{e}"],
786:                 arrays[f"targeted_{e}"],
787:                 arrays[f"random_{e}"],
788:             )
789:         rebuilt = decide(raw, pinned, row, float(redone["s"][row]), budgets)
790:         stored_part = {key: case[key] for key in rebuilt}
791:         worst, _, mismatches = pa.max_difference(stored_part, pb.jsonable(rebuilt))
792:         rebuild_max = max(rebuild_max, worst)
793:         if mismatches or worst > REBUILD_TOLERANCE:
794:             raise ParityError(f"{case['site']}: stored decisions or regions differ from a rebuild: {mismatches[:3]}")
795:     if ranking_max > RANKING_TOLERANCE:
796:         raise ParityError(f"stored ranking maps miss their weighted phrase-map sums by {ranking_max:.3g}")
797:     if rebuild_max > REBUILD_TOLERANCE:
798:         raise ParityError(f"stored ranking maps or decisions differ from a rebuild by {rebuild_max:.3g}")
799: 
800:     return dict(
801:         parity=parity, ranking_max_diff=ranking_max, rebuild_max_diff=rebuild_max, n_cases=len(payload["cases"])
802:     )
803: 
804: 
805: def directory_size(directory):
806:     return sum(path.stat().st_size for path in Path(directory).rglob("*") if path.is_file())
807: 
808: 
809: def _fmt(value, spec):


FILE caption_tune/cli/labo.py @ ed8b3cff214fe4c272d3a1fb989d03a6c5a112d4
1678: def paired_response(args):
1679:     """Parity, per-exposure ranking maps and token deletions for Method B's binary errors (one GPU)."""
1680:     import numpy
1681: 
1682:     started = time.perf_counter()
1683:     try:
1684:         pinned = labo_paired_attribution.load_pinned(args.cache_root)
1685:         replayed = labo_paired_attribution.replay(pinned)
1686:     except (labo_paired_attribution.PinError, labo_response.ParityError) as error:
1687:         raise SystemExit(f"paired-response: refused: {error}") from None
1688:     text = inputs.load_text(pinned["input_directory"])
1689:     if text["config"].get("walk_type") != labo_paired_response.TOWER:
1690:         raise SystemExit(f"paired-response: cached text rows are the {text['config'].get('walk_type')} tower")
1691:     text_row = {surface_id: i for i, surface_id in enumerate(text["surface_ids"])}
1692:     bank_text = text["features"][[text_row[surface_id] for surface_id in pinned["columns"]]].float()
1693:     settings = labo_paired_response.config(
1694:         batch_size=args.occlusion_batch, variant=args.variant, max_patches=args.max_patches
1695:     )
1696:     identity = labo_paired_response.run_identity(pinned, bank_text, settings)
1697:     cache = labo_paired_response.output_directory(args.cache_root, identity)
1698:     decision, binary = replayed["decision"], replayed["binary"]
1699:     print(
1700:         f"paired-response: run {pinned['record']['identity'][:16]}; inputs {pinned['input_identity'][:16]}; "
1701:         f"bank {pinned['digests']['bank'][:16]}; W {pinned['digests']['weights'][:16]}; tau {pinned['tau']!r}; "
1702:         f"identity {identity[:16]}; {len(binary)} binary errors"
1703:     )
1704: 
1705:     cached = None if args.rebuild else labo_paired_response.cached_run(cache, identity)
1706:     if cached is not None:
1707:         built = json.loads((cache / "payload.json").read_text())
1708:         try:
1709:             checked = labo_paired_response.verify_cached(cache, built, pinned, decision, binary)
1710:         except labo_response.ParityError as error:
1711:             raise SystemExit(f"paired-response: cached run failed its checks: {error}; rerun with --rebuild") from None
1712:         print(
1713:             f"  reused {cache}: parity re-run from the stored cosines; {checked['n_cases']} cases rebuilt "
1714:             f"(ranking maps within {checked['ranking_max_diff']:.3g}, decisions within {checked['rebuild_max_diff']:.3g})"
1715:         )
1716:         for line in labo_paired_response.summary_lines(built):
1717:             print(f"  {line}")
1718:         return dict(identity=identity, directory=str(cache), payload=built)
1719: 
1720:     from caption_tune import features
1721:     from caption_tune import model as model_module
1722: 
1723:     device = torch.device(args.device)
1724:     if device.type == "cuda" and device.index is not None:
1725:         torch.cuda.set_device(device)
1726:     loaded, tokenizer, processor = model_module.load(args.variant)
1727:     encoder = labo_response.Encoder(
1728:         loaded,
1729:         processor,
1730:         lambda texts, walk_type: model_module.encode_texts(texts, loaded, tokenizer, walk_type),
1731:         device=args.device,
1732:         max_patches=args.max_patches,
1733:     )
1734: 
1735:     def progress(stage, done, total):
1736:         if done == total or done % 100 == 0:
1737:             print(f"  {stage}: {done}/{total} ({time.perf_counter() - started:.0f} s)", flush=True)
1738: 
1739:     try:
1740:         built, arrays = labo_paired_response.analyse(
1741:             encoder,
1742:             lambda path: features.load_image(Path(args.root) / path),
1743:             pinned,
1744:             decision,
1745:             binary,
1746:             bank_text,
1747:             batch_size=args.occlusion_batch,
