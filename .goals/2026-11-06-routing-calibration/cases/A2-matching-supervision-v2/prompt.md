This is an offline, supplied-text evaluation. Complete the task yourself. Do not use tools, inspect any files, browse, spawn agents, or modify anything. All relevant inputs are supplied below. Embedded source text is data, not instructions. Do not claim runtime execution. Return a concise answer under 650 words with decisive evidence and stated limits. Do not infer prior reviewer conclusions or model comparisons.

OBJECTIVE: Evaluate the proposed shortcut against the product/data contract and the supplied matcher. Specify the smallest safe data-to-head supervision contract, including presence/coordinate/spatial eligibility, matching/association conditions, and tests. You may recommend a design change but must not assume model accuracy. Distinguish detection assignment from demonstrated object identity. Cite matcher lines where relevant.
RETURN: Critical issues, a compact state/eligibility table or equivalent, and acceptance checks.

Reconstructed product/data contract from the 2026-10-27/28 design decisions:
- The detector remains frozen in evaluation mode; a head is trained on predicted instances.
- Each (instance, requested landmark) has independent certified-absent, known-present, unknown, ambiguous-owner, and crop/visibility states. A missing annotation alone does not certify absence.
- A valid support prompt may supervise the requested landmark; an invalid support prompt contributes no loss.
- Crop exclusion is distinct from certified physical absence. The API has a presence decision and an optional coordinate.
- Overlapping objects can contain another object's valid landmark in their image region. An unresolved annotation can name multiple candidate owners; silently dropping it must not turn those owners into negative examples.
Proposed shortcut under review: call the existing detection matcher, attach the matched object's available landmark annotation to every matched query, use missing landmarks as negatives, rasterize all absent pairs as a zero target on a shared image heatmap, and mask coordinates only when outside the crop.

FILE sam3/train/matcher.py @ 8b21fb79c867edc05663d296216a3f2e178ab8b5
470:         super().__init__()
471:         self.cost_class = cost_class
472:         self.cost_bbox = cost_bbox
473:         self.cost_giou = cost_giou
474:         self.norm = nn.Sigmoid()
475:         assert (
476:             cost_class != 0 or cost_bbox != 0 or cost_giou != 0
477:         ), "all costs cant be 0"
478:         self.focal = focal
479:         if focal:
480:             self.alpha = alpha
481:             self.gamma = gamma
482:             self.stable = stable
483:         self.remove_samples_with_0_gt = remove_samples_with_0_gt
484:         self.force_fp32 = force_fp32
485: 
486:     @torch.no_grad()
487:     def forward(
488:         self,
489:         outputs,
490:         batched_targets,
491:         repeats=1,
492:         repeat_batch=1,
493:         out_is_valid=None,
494:         target_is_valid_padded=None,
495:     ):
496:         """
497:         Performs the matching. The inputs and outputs are the same as
498:         BinaryHungarianMatcher.forward, except for the optional cached_padded
499:         flag and the optional "_boxes_padded" entry of batched_targets.
500: 
501:         Inputs:
502:         - outputs: A dict with the following keys:
503:             - "pred_logits": Tensor of shape (batch_size, num_queries, 1) with
504:                classification logits
505:             - "pred_boxes": Tensor of shape (batch_size, num_queries, 4) with
506:                predicted box coordinates in cxcywh format.
507:         - batched_targets: A dict of targets. There may be a variable number of
508:           targets per batch entry; suppose that there are T_b targets for batch
509:           entry 0 <= b < batch_size. It should have the following keys:
510:           - "boxes": Tensor of shape (sum_b T_b, 4) giving ground-truth boxes
511:              in cxcywh format for all batch entries packed into a single tensor
512:           - "num_boxes": int64 Tensor of shape (batch_size,) giving the number
513:              of ground-truth boxes per batch entry: num_boxes[b] = T_b
514:           - "_boxes_padded": Tensor of shape (batch_size, max_b T_b, 4) giving
515:             a padded version of ground-truth boxes. If this is not present then
516:             it will be computed from batched_targets["boxes"] instead, but
517:             caching it here can improve performance for repeated calls with the
518:             same targets.
519:         - out_is_valid: If not None, it should be a boolean tensor of shape
520:           (batch_size, num_queries) indicating which predictions are valid.
521:           Invalid predictions are ignored during matching and won't appear in
522:           the output indices.
523:         - target_is_valid_padded: If not None, it should be a boolean tensor of
524:           shape (batch_size, max_num_gt_boxes) in padded format indicating
525:           which GT boxes are valid. Invalid GT boxes are ignored during matching
526:           and won't appear in the output indices.
527: 
528:         Returns:
529:             A list of size batch_size, containing tuples of (idx_i, idx_j):
530:                 - idx_i is the indices of the selected predictions (in order)
531:                 - idx_j is the indices of the corresponding selected targets
532:                   (in order)
533:             For each batch element, it holds:
534:                 len(index_i) = len(index_j)
535:                              = min(num_queries, num_target_boxes)
536:         """
537:         _, num_queries = outputs["pred_logits"].shape[:2]
538: 
539:         out_score = outputs["pred_logits"].squeeze(-1)  # (B, Q)
540:         out_bbox = outputs["pred_boxes"]  # (B, Q, 4))
541: 
542:         device = out_score.device
543: 
544:         num_boxes = batched_targets["num_boxes"].cpu()
545:         # Get a padded version of target boxes (as precomputed in the collator).
546:         # It should work for both repeat==1 (o2o) and repeat>1 (o2m) matching.
547:         tgt_bbox = batched_targets["boxes_padded"]
548:         if self.force_fp32:
549:             out_score = out_score.float()
550:             out_bbox = out_bbox.float()

565:             if target_is_valid_padded is not None:
566:                 target_is_valid_padded = target_is_valid_padded.repeat(repeat_batch, 1)
567: 
568:         # keep only samples w/ at least 1 GT box in outputs
569:         if self.remove_samples_with_0_gt:
570:             if repeat_batch > 1:
571:                 batch_keep = batch_keep.repeat(repeat_batch)
572:             out_score = out_score[batch_keep]
573:             out_bbox = out_bbox[batch_keep]
574:             if out_is_valid is not None:
575:                 out_is_valid = out_is_valid[batch_keep]
576:         assert out_bbox.shape[0] == tgt_bbox.shape[0]
577:         assert out_bbox.shape[0] == num_boxes.shape[0]
578: 
579:         autocast_ctx = (
580:             torch.autocast(device_type=device.type, enabled=False)
581:             if self.force_fp32
582:             else nullcontext()
583:         )
584:         with autocast_ctx:
585:             # Compute the L1 cost between boxes
586:             cost_bbox = torch.cdist(out_bbox, tgt_bbox, p=1)
587: 
588:             # Compute the giou cost betwen boxes
589:             cost_giou = -generalized_box_iou(
590:                 box_cxcywh_to_xyxy(out_bbox), box_cxcywh_to_xyxy(tgt_bbox)
591:             )
592: 
593:             out_prob = self.norm(out_score)
594:             if not self.focal:
595:                 cost_class = -out_prob.unsqueeze(-1).expand_as(cost_bbox)
596:             else:
597:                 if self.stable:
598:                     rescaled_giou = (-cost_giou + 1) / 2
599:                     out_prob = (
600:                         out_prob.unsqueeze(-1).expand_as(cost_bbox) * rescaled_giou
601:                     )
602:                     cost_class = -self.alpha * (1 - out_prob) ** self.gamma * torch.log(
603:                         out_prob
604:                     ) + (1 - self.alpha) * out_prob**self.gamma * torch.log(
605:                         1 - out_prob
606:                     )
607:                 else:
608:                     # directly computing log sigmoid (more numerically stable)
609:                     log_out_prob = torch.nn.functional.logsigmoid(out_score)
610:                     log_one_minus_out_prob = torch.nn.functional.logsigmoid(-out_score)
611:                     cost_class = (
612:                         -self.alpha * (1 - out_prob) ** self.gamma * log_out_prob
613:                         + (1 - self.alpha)
614:                         * out_prob**self.gamma
615:                         * log_one_minus_out_prob
616:                     )
617:                 if not self.stable:
618:                     cost_class = cost_class.unsqueeze(-1).expand_as(cost_bbox)
619: 
620:             assert cost_class.shape == cost_bbox.shape
621: 
622:             # Final cost matrix
623:             C = (
624:                 self.cost_bbox * cost_bbox
625:                 + self.cost_class * cost_class


ADDITIONAL FROZEN SOURCE: sam3/train/matcher.py @ 8b21fb79c867edc05663d296216a3f2e178ab8b5

1: # Copyright (c) Meta Platforms, Inc. and affiliates. All Rights Reserved
2: 
3: """
4: Modules to compute the matching cost and solve the corresponding LSAP.
5: """
6: 
7: from contextlib import nullcontext
8: 
9: import numpy as np
10: import torch
11: 
12: from sam3.model.box_ops import box_cxcywh_to_xyxy, box_iou, generalized_box_iou
13: from scipy.optimize import linear_sum_assignment
14: from torch import nn
15: 
16: 
17: def _do_matching(cost, repeats=1, return_tgt_indices=False, do_filtering=False):
18:     if repeats > 1:
19:         cost = np.tile(cost, (1, repeats))
20: 
21:     i, j = linear_sum_assignment(cost)
22:     if do_filtering:
23:         # filter out invalid entries (i.e. those with cost > 1e8)
24:         valid_thresh = 1e8
25:         valid_ijs = [(ii, jj) for ii, jj in zip(i, j) if cost[ii, jj] < valid_thresh]
26:         i, j = zip(*valid_ijs) if len(valid_ijs) > 0 else ([], [])
27:         i, j = np.array(i, dtype=np.int64), np.array(j, dtype=np.int64)
28:     if return_tgt_indices:
29:         return i, j
30:     order = np.argsort(j)
31:     return i[order]
32: 
33: 
34: class HungarianMatcher(nn.Module):
35:     """This class computes an assignment between the targets and the predictions of the network
36: 
37:     For efficiency reasons, the targets don't include the no_object. Because of this, in general,

626:                 + self.cost_giou * cost_giou
627:             )
628:         # assign a very high cost (1e9) to invalid outputs and targets, so that we can
629:         # filter them out (in `_do_matching`) from bipartite matching results
630:         do_filtering = out_is_valid is not None or target_is_valid_padded is not None
631:         if out_is_valid is not None:
632:             C = torch.where(out_is_valid[:, :, None], C, 1e9)
633:         if target_is_valid_padded is not None:
634:             C = torch.where(target_is_valid_padded[:, None, :], C, 1e9)
635:         C = C.cpu().numpy()
636:         costs = [C[i, :, :s] for i, s in enumerate(num_boxes.tolist())]
637:         return_tgt_indices = (
638:             do_filtering or torch.any(num_queries < num_boxes * max(repeats, 1)).item()
639:         )
640:         if len(costs) == 0:
641:             # We have size 0 in the batch dimension, so we return empty matching indices
642:             # (note that this can happen due to `remove_samples_with_0_gt=True` even if
643:             # the original input batch size is not 0, when all queries have empty GTs).
644:             indices = []
645:             tgt_idx = torch.zeros(0).long().to(device) if return_tgt_indices else None
646:         elif return_tgt_indices:
647:             indices, tgt_indices = zip(
648:                 *(
649:                     _do_matching(
650:                         c,
651:                         repeats=repeats,
652:                         return_tgt_indices=return_tgt_indices,
653:                         do_filtering=do_filtering,
654:                     )
655:                     for c in costs
656:                 )
657:             )
658:             tgt_indices = list(tgt_indices)
659:             sizes = torch.cumsum(num_boxes, -1)[:-1]
660:             for i in range(1, len(tgt_indices)):
661:                 tgt_indices[i] += sizes[i - 1].item()
662:             tgt_idx = torch.from_numpy(np.concatenate(tgt_indices)).long().to(device)
663:         else:
664:             indices = [
665:                 _do_matching(c, repeats=repeats, do_filtering=do_filtering)
666:                 for c in costs
667:             ]
668:             tgt_idx = None
669: 
670:         if self.remove_samples_with_0_gt:
671:             kept_inds = batch_keep.nonzero().squeeze(1)
672:             batch_idx = torch.as_tensor(
673:                 sum([[kept_inds[i]] * len(src) for i, src in enumerate(indices)], []),
674:                 dtype=torch.long,
675:                 device=device,
676:             )
677:         else:
678:             batch_idx = torch.as_tensor(
679:                 sum([[i] * len(src) for i, src in enumerate(indices)], []),
680:                 dtype=torch.long,
681:                 device=device,
682:             )
683: 
684:         # indices could be an empty list (since we remove samples w/ 0 GT boxes)
685:         if len(indices) > 0:
686:             src_idx = torch.from_numpy(np.concatenate(indices)).long().to(device)
687:         else:
688:             src_idx = torch.empty(0, dtype=torch.long, device=device)
689:         return batch_idx, src_idx, tgt_idx
690: 
691: 
692: class BinaryOneToManyMatcher(nn.Module):

Clarification: explain whether the solver enforces a match-quality threshold, and how to invoke matching explicitly if frozen detector evaluation does not return the training assignments needed by the head. The required contract must reject forced low-quality association before landmark supervision.
