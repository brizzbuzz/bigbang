{
  enable = true;

  # Enable default mappings
  addDefaultMappings = true;

  # Case sensitivity
  caseSensitive = false;

  # Set the safe labels (easily reachable keys)
  safeLabels = ["s" "f" "n" "u" "t" "b" "g" "h"];

  # Highlight unlabeled targets in phase one
  highlightUnlabeledPhaseOneTargets = true;

  # Set the labels for targets
  labels = ["s" "f" "n" "j" "k" "l" "h" "o" "d" "w" "e" "m" "b" "u" "y" "v" "r" "g" "t" "a" "q" "p" "c" "x" "z" "i"];

  # Set the max number of highlighted traversal targets
  maxHighlightedTraversalTargets = 100;

  # Set the max number of targets in phase one
  maxPhaseOneTargets = 50;

  # Special keys for multi-cursor mode
  specialKeys = {
    nextTarget = "<enter>";
    prevTarget = "<tab>";
    nextGroup = "<space>";
    prevGroup = "<S-space>";
    multiAccept = "<enter>";
    multiRevert = "<backspace>";
  };
}
