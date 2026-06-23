TASK: Create Premium Rubik-Style 3D Cube Loading Logo Variants (Do NOT Replace Existing Implementations)

You are working on an existing Flutter project.

Your task is NOT to modify or destroy the current loading indicators.

Your task is to ADD new premium loading logo variants inspired by the LandyMaker cube logo.

IMPORTANT:

DO NOT delete any existing loader variants.
DO NOT replace current implementations.
DO NOT break backward compatibility.
DO NOT remove any existing enums, classes, painters, widgets, or APIs.
ADD new variants only.
Existing variants must continue working exactly as before.
First Step: Study Existing Code

Before making any changes:

Carefully analyze the current cube_loader.dart implementation.
Understand the rendering pipeline.
Understand how cube geometry is currently generated.
Understand the existing logo variant.
Identify why the current logo does not visually match a professional Rubik-style cube silhouette.

Do NOT start coding until the analysis is complete.

Design Goal

The goal is NOT to copy colors or textures from the logo image.

The goal is to reproduce the SAME VISUAL STRUCTURE and SAME CAMERA FEEL.

When a user sees the loader, the immediate reaction should be:

"That is a premium 3D cube logo."

Not:

"That is a random collection of cubes."

Critical Visual Requirements

The new loaders must preserve:

1. Strong Isometric Perspective

The cube must appear as if viewed from:

slightly above
slightly from a corner
showing 3 faces simultaneously

The camera angle should feel similar to:

premium Rubik's Cube renders
professional 3D product mockups
the supplied logo reference

Avoid:

flat front views
orthographic-looking views
excessive rotation that destroys readability
2. Stable Recognizable Silhouette

At every frame:

The user must still recognize:

a cube
a Rubik-style cube
a structured 3×3×3 formation

Avoid:

chaotic motion
cubes flying apart
losing the outer shape
rotations that make the logo unreadable

The silhouette must remain recognizable during the entire animation.

3. Premium Depth

Improve:

depth perception
face shading
visual hierarchy
cube separation

The loader should feel:

heavier
more premium
more intentional

Not:

floating squares
wireframe-like
toy-like
Create NEW Variants

Add several new variants.

Examples:

CubeLoaderVariant.logoPremium

Static premium logo composition with subtle breathing.

CubeLoaderVariant.logoPremiumFloat

Entire cube performs a very subtle floating motion.

Requirements:

extremely small movement
premium feeling
no bouncing
CubeLoaderVariant.logoPremiumWave

A wave passes through the cube body.

Requirements:

silhouette remains intact
cubes do not separate
depth remains readable
CubeLoaderVariant.logoPremiumCorePulse

The center area softly pulses.

Requirements:

elegant
minimal
suitable for loading screens
CubeLoaderVariant.logoPremiumRotate

Very slow rotation.

Requirements:

keep logo readable
never become edge-on
never spin fast

Maximum priority:

readability over motion.

Add One Experimental Variant

Create one creative premium concept.

Requirements:

still cube-based
still brand-appropriate
still professional
not gimmicky

You may invent the motion.

Animation Rules

Avoid:

spinning around a single axis forever
aggressive rotations
excessive wobbling
chaotic movement
arcade-style effects

Prefer:

subtle motion
premium motion
motion design suitable for SaaS branding

Think:

Apple
Linear
Stripe
Framer
Vercel

not gaming UI.

Geometry Improvements

If needed:

Create new geometry calculations specifically for premium logo variants.

Do NOT alter existing variants.

The premium variants may use:

different spacing
different cube proportions
different depth scaling
different projection math

if that produces a more authentic Rubik-style appearance.

Loader Preview Screen

Create or extend the existing loading-indicator preview/demo screen.

Display ALL newly added premium variants.

Requirements:

For every variant show:

variant name
animated preview
multiple sizes if useful

The goal is to allow visual comparison.

I want to open the preview page and compare all premium cube concepts side by side before choosing one for global use.

Code Quality Requirements
Reuse existing architecture.
Reuse existing geometry utilities when appropriate.
Avoid duplicate code.
Keep rendering performant.
Keep allocations low.
Follow project conventions.
Maintain Flutter Web performance.
Validation Checklist

Before finishing:

Verify:

project compiles successfully
no analyzer errors
no warnings introduced
all existing variants still work
all new variants render correctly
preview screen displays all new variants
animations loop seamlessly
no visible jump between last frame and first frame
no frame hitching
no broken rendering
Final Deliverable

When finished, provide a SHORT REPORT IN ARABIC containing:

Variants added.
Files modified.
Geometry changes made.
Animation techniques used.
Which variant you personally recommend as the default global loader and why.
Confirmation that no existing loader variants were removed or broken.

IMPORTANT:

Do not stop after creating one variant.

Create multiple premium alternatives and expose all of them in the loading preview screen so I can compare them and choose the best one.