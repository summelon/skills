# Swarm — workflows mode

Read this only when the run mode is **workflows**. A **wave** is one Workflow call covering the current frontier; this wave loop replaces steps 4–5 of [SKILL.md](SKILL.md).

Agents inside a wave are headless — no chat output, no AskUserQuestion, no stopping — so the step 4 task prompt gets one amendment: replace its final sentence with "If you hit a decision the issue doesn't settle, finish with status `question` and the question text in your structured result instead of inventing an answer." Questions come back as data; every wave starts from verified ground, because it is cut from the integration branch after the previous wave landed.

## Wave loop

While the frontier is non-empty:

1. **Dispatch the wave.** Check out the integration branch in the main repo (worktree isolation cuts from current state), then launch one Workflow over the frontier — one agent per ticket, the amended task prompt, model/effort from the fleet question (omit either to inherit the session's). Keep a wave within the session's workflow size guideline; a larger frontier waits for the next wave. Script shape:

   ```js
   export const meta = {
     name: 'swarm-wave',
     description: 'Implement one frontier wave, one isolated agent per ticket',
     phases: [{ title: 'Implement' }],
   }
   // args: { tickets: [{ number, prompt }] } — prompt is the full amended task
   const RESULT = {
     type: 'object',
     required: ['number', 'branch', 'status', 'summary'],
     properties: {
       number: { type: 'integer' },
       branch: { type: 'string', description: 'branch the work was committed on' },
       status: { enum: ['done', 'question'] },
       question: { type: 'string' },
       summary: { type: 'string', description: 'one line: what landed or what blocks' },
     },
   }
   const results = await parallel(args.tickets.map(t => () => {
     log(`#${t.number} dispatched`)
     return agent(t.prompt, {
       label: `#${t.number}`,
       phase: 'Implement',
       isolation: 'worktree',
       schema: RESULT,
     })
   }))
   return results.filter(Boolean)
   ```

2. **Integrate the wave.** When the workflow returns, merge each `done` branch into the integration branch per SKILL.md step 5 — smaller diff first, resolve conflicts yourself, a branch has landed only green. Digest each transition.
3. **Park and flush.** Park every `question` result per the Question queue. The wave boundary is the flush point — nothing is running, so put the whole batch to the user in one AskUserQuestion now; answered tickets rejoin the next wave.
4. Re-query the frontier — landed merges unblock tickets — and loop.

Done when: the frontier is empty and every child ticket has landed or is reported parked.

The user watches waves live with `/workflows`; your `log()` lines there mirror the digest lines you print in chat.

