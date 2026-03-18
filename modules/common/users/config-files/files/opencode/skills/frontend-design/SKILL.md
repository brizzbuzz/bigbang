---
name: frontend-design
description: Design and implement distinctive, production-grade frontend interfaces with strong visual direction, solid implementation quality, and disciplined verification.
license: Personal
compatibility: opencode
metadata:
  audience: frontend-agents
  scope: ui-design-and-implementation
---

Use this skill when the task involves building, restyling, or critically improving a frontend interface.

If the current repository provides a repo-local companion skill such as `frontend-design-<repo>`, load that too and follow its repo-specific direction alongside this base skill.

## What I do

I help build memorable frontend work across web components, pages, dashboards, landing sites, app shells, and other UI-heavy artifacts.

I do not settle for generic output. I choose a clear aesthetic direction, implement working code, and refine typography, spacing, color, motion, and responsiveness until the result feels deliberate.

## Core approach

Before coding, establish the design intent:

- Purpose: identify who the interface serves and what action or outcome matters most
- Context: understand whether this is a new surface or part of an existing design system
- Constraints: respect framework, accessibility, performance, and brand requirements
- Differentiator: decide what single quality should make the work memorable

Then commit to one strong aesthetic direction and carry it through the whole implementation. Possible directions include editorial, brutalist, utilitarian, luxury, retro-futurist, organic, playful, industrial, lo-fi, maximalist, or tightly restrained minimalist work. The goal is not to copy a style label. The goal is coherent, specific taste.

## Design standards

### Typography

- Avoid default-feeling font stacks such as Arial, Inter, Roboto, and bare system stacks unless the product already depends on them
- Choose type pairings with personality and clear hierarchy
- Use size, weight, case, spacing, and rhythm to create structure, not just bigger headings
- Let typography carry part of the product voice

### Color and atmosphere

- Define CSS variables or theme tokens for the palette
- Use a committed palette with a dominant hue and intentional accents
- Avoid washed-out, indecisive palettes and overused purple-on-white gradients unless the brand explicitly calls for them
- Build atmosphere with gradients, texture, shape, depth, pattern, glow, grain, or other details that fit the concept

### Layout and composition

- Prefer composition with intent over safe boilerplate layouts
- Use asymmetry, overlap, scale contrast, full-bleed moments, framing devices, or dense editorial structure when they improve the concept
- Preserve established patterns when working inside an existing product or design system
- Keep responsive behavior elegant on both mobile and desktop

### Motion

- Use motion to reinforce hierarchy and delight, not to decorate every element
- Favor a few meaningful moments such as staged entrances, hover transitions, and scroll reveals
- Keep motion performant and accessible

### Implementation quality

- Ship real working code, not mockups disguised as code
- Match the implementation to the stack already in the repo
- Reuse existing components, tokens, and conventions when appropriate
- Keep accessibility, semantics, keyboard behavior, and responsiveness intact

## Working rules

- If the repo already has a design system, preserve its language and improve within its constraints
- If the repo has no strong visual system, create one with conviction instead of falling back to generic defaults
- Do the non-blocked work first and avoid unnecessary clarification questions
- Prefer concrete implementation over vague design advice when the task asks for code
- When adding styles, centralize reusable tokens instead of scattering magic values
- Verify the result visually when tooling allows, and run relevant tests or builds when practical

## Deliverable expectations

Aim for output that is:

- Production-grade and responsive
- Distinctive rather than template-like
- Cohesive in typography, color, spacing, and motion
- Grounded in the product context
- Cleanly implemented and maintainable

## Anti-patterns to avoid

- Generic SaaS layouts with interchangeable cards and gradients
- Default typography choices that flatten the visual identity
- Random decorative effects without a unifying concept
- Over-animated interfaces that hurt clarity or performance
- Breaking established product patterns when extending an existing system
