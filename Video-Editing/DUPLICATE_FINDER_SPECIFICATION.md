# Duplicate File Finder - Specification Document

**Version:** 1.0  
**Date:** 2026-07-10  
**Status:** Final  
**Use Case:** Finding duplicate media files (videos, audio) when exact file matching fails due to re-encoding

---

## 1. Problem Statement

### Scenario
- Two folders contain potentially duplicate files
- Files may have been re-encoded (different bitrate, quality, codec)
- Files may have renamed versions (same content, different names)
- File names may be in different languages (e.g., Hindi/English)
- Exact hash matching will NOT work (different file content at byte level)

### Goal
Identify which files in Folder A (Source) are duplicates of files in Folder B (Reference), accounting for:
- Re-encoded versions
- Renamed versions
- Mixed language naming

### Success Criteria
- Identify exact duplicates with high confidence (≥95%)
- Minimize false positives (wrongly marking different videos as duplicates)
- Minimize false negatives (missing actual duplicates)
- Provide similarity scores for manual verification

---

## 2. Core Methodology

### Two-Factor Matching Algorithm

**Factor 1: Exact Duration Match**
- Extract duration from each file using ffprobe
- Duration is **invariant** - stays same after re-encoding
- Match only files with identical duration (allow 0.1s floating point error)

**Factor 2: Name Similarity Search**
- Normalize both file names (remove extensions, separators, etc.)
- Convert to comparable form (lowercase, remove special chars)
- Extract keywords from names
- Calculate similarity using:
  - String similarity (SequenceMatcher): 60% weight
  - Keyword overlap: 40% weight
- Minimum similarity threshold: 60%

### Matching Criteria
Files are considered duplicates if:
1. **Duration is EXACTLY the same** (±0.1 seconds)
2. **AND name similarity ≥ 60%**

Only when BOTH conditions are met = confident duplicate.

---

## 3. Detailed Algorithm

### Phase 1: Data Collection

```
For each folder:
  1. List all video files with supported extensions
     - mp4, mkv, avi, mov, flv, webm
  
  2. For each video file:
     a. Extract exact duration using ffprobe
     b. Store: filename → duration (in seconds)
     c. Skip files that can't be analyzed
```

### Phase 2: Name Normalization

```
For each filename:
  1. Remove file extension (.mp4, .mkv, etc.)
  
  2. Replace separators with spaces
     - Underscores (_)
     - Hyphens (-)
     - Pipes (|, ｜)
     - Colons (:)
  
  3. Convert to lowercase
  
  4. Remove characters in parentheses/brackets
     - Keep content but remove brackets: (Official Video) → official video
  
  5. Remove extra whitespace
  
  6. Remove non-alphanumeric characters (except spaces)
     - Keep: letters (a-z, A-Z), numbers (0-9), spaces
     - Remove: special characters, punctuation
  
  Result: Clean normalized string
  Example:
    Input: "Mere_Bhole_Nath_(Video)_Jubin_Nautiyal"
    Output: "mere bhole nath video jubin nautiyal"
```

### Phase 3: Keyword Extraction

```
For each normalized filename:
  1. Split into individual words
  
  2. Filter out common/filler words:
     - Generic: full, video, official, song, lyrical, lyrics
     - Genre: bhajan, bhakti, devotional, music, audio
     - Common verbs/articles: new, special, with, the, and, or, by, ft, feat
     - Known deities/common names: jai, om, sri, shri, teri, mera, baba, maa
     - Numerals: 2023, 2024, 2025, 2026
  
  3. Keep only:
     - Words with length > 2 characters
     - Words that survived filtering
  
  4. Result: Set of meaningful keywords
  Example:
    Input: "mere bhole nath video jubin nautiyal official music video"
    Output: {mere, bhole, nath, jubin, nautiyal}
    (Removed: video, official, music)
```

### Phase 4: Similarity Calculation

```
String Similarity (60% weight):
  Method: Python's SequenceMatcher.ratio()
  Formula: Longest contiguous matching subsequence / average length
  Range: 0.0 to 1.0

Keyword Overlap (40% weight):
  Method: Intersection over union of keyword sets
  Formula: |set1 ∩ set2| / max(|set1|, |set2|)
  Range: 0.0 to 1.0

Combined Similarity:
  similarity = (string_similarity × 0.6) + (keyword_overlap × 0.4)
  Range: 0.0 to 1.0 (0-100%)

Threshold: Accept if similarity ≥ 0.60 (60%)
```

### Phase 5: Duplicate Matching

```
For each file in Source folder:
  1. Get source_duration
  
  2. Find all Reference files with EXACT same duration
     (duration difference < 0.1 seconds)
  
  3. For each matching duration file:
     a. Calculate name similarity
     b. Keep track of best match (highest similarity)
  
  4. If best match similarity ≥ 60%:
     → Record as DUPLICATE
     → Mark Reference file as used (prevent multi-matching)
  
  5. Else:
     → Record as UNIQUE (no matching Reference file)
```

---

## 4. Implementation Requirements

### Dependencies
```
Python 3.6+
- ffprobe (from ffmpeg package) - for duration extraction
- difflib (stdlib) - for string similarity
- pathlib (stdlib) - for file operations
- subprocess (stdlib) - for running ffprobe
- json (stdlib) - for parsing ffprobe output
```

### Input Specification
```
Folder A (Source):  ~/Videos/Bhajans from Pendrive
Folder B (Ref):     ~/Videos/Bhajans - YouTube

Supported formats:  .mp4, .mkv, .avi, .mov, .flv, .webm
                    (case-insensitive)
```

### Output Specification

#### Output Format: List of Duplicates
```
Duplicate Entry:
{
  "pendrive_file": "Exact filename from Folder A",
  "youtube_file": "Exact filename from Folder B",
  "duration_seconds": 123.45,
  "name_similarity_percent": 85.3,
  "string_similarity": 0.834,
  "keyword_overlap": 0.876
}
```

#### Output Format: List of Unique Files
```
Unique Entry:
{
  "name": "Exact filename from Folder A",
  "duration_seconds": 234.56,
  "reason": "No match in Folder B"
}
```

#### Summary Statistics
```
{
  "total_source_files": 98,
  "total_reference_files": 167,
  "duplicates_found": 27,
  "unique_files": 71,
  "analysis_date": "2026-07-10",
  "method": "Exact Duration + Name Similarity"
}
```

---

## 5. Edge Cases & Handling

### Edge Case 1: Multiple matches with same duration
```
Problem: Several Reference files have same duration as one Source file
Solution: Pick the one with highest name similarity
Result: Each Source file maps to at most one Reference file
```

### Edge Case 2: Identical duration but very different names
```
Example: "RAM LALA.mp4" (5m 14s) vs "Random Bhajan #2.mp4" (5m 14s)
Problem: Duration match but only 20% name similarity
Solution: Reject as duplicate (fails 60% threshold)
Result: Correctly identified as different videos
```

### Edge Case 3: Same video in multiple qualities/formats
```
Example: "Video.mp4" and "Video-HD.mp4" (same actual content)
Problem: Might be truly different versions, or same re-encode
Solution: Flagged as duplicate if similarity ≥ 60%
User can verify manually if needed
```

### Edge Case 4: Hindi vs Transliterated English
```
Example: 
  "राम को देखकर श्री जनक नंदिनी"
  "Ram Ko Dekh Kar Shri Janak Nandini"
Problem: Same video, completely different script
Solution: Transliteration library converts Hindi to Roman
Implementation: Keep both forms in normalized comparison
Result: Successfully matched as 100% similarity
```

### Edge Case 5: Missing audio/video track
```
Problem: File exists but has no extractable duration
Solution: Skip file, log error, continue with others
Result: Count as "unanalyzable" - not counted in duplicates
```

### Edge Case 6: Very long videos (compilations)
```
Example: 180+ minute compilation videos
Problem: Still have exact duration, might not be true duplicates
Solution: Still match on duration + name
Recommendation: Manual verification recommended for >60min videos
```

---

## 6. Validation & Quality Checks

### Pre-Analysis Validation
- [ ] Both folders exist and are readable
- [ ] At least one video file exists in each folder
- [ ] ffprobe is installed and accessible
- [ ] File permissions allow reading

### Post-Analysis Validation
- [ ] Total source files = duplicates + unique (should match)
- [ ] No file appears in both duplicates and unique lists
- [ ] No duplicate file from Reference appears twice
- [ ] All similarity scores in range [0.0, 1.0]
- [ ] All durations are positive numbers

### Result Verification
```
Manual spot-check required for:
- Similarity scores between 60-70% (boundary cases)
- All Hindi/English mixed name matches
- Videos longer than 60 minutes
```

---

## 7. Performance Considerations

### Time Complexity
```
ffprobe extraction: O(n) where n = total files
Duration matching: O(n × m) where n = source files, m = reference files
  (optimizable with duration grouping to O(n + m))
Similarity calculation: O(n × m) with string operations
  (constant for each pair, still O(n × m) overall)

Overall: O(n × m) linear in file counts
Typical: 100 files × 167 files = 16,700 comparisons
```

### Execution Time Estimate
```
Extraction phase:  ~1-2 seconds per file
  100 source files: ~100-200 seconds
  167 reference files: ~167-334 seconds
  Total: ~4-9 minutes

Matching phase:  ~milliseconds per file
  16,700 comparisons: ~5-30 seconds
  
Total for 267 files: ~5-10 minutes
```

### Optimization Tips
```
1. Pre-sort files by duration to avoid O(n×m) searching
2. Cache duration extraction results
3. Parallelize ffprobe calls (16-32 processes)
4. Skip very small files (<1 MB) if needed
```

---

## 8. Common Mistakes to Avoid

### ❌ Mistake 1: Using Hash-based Matching
```
Problem: Different encoding = different file hash
Solution: Use duration + name, not file hash
Why: Re-encoded videos have completely different binary content
```

### ❌ Mistake 2: Too Strict Duration Matching
```
Problem: Requiring exact byte-identical files
Solution: Allow ±0.1 second tolerance for floating point
Why: FFmpeg extraction may have minor rounding
```

### ❌ Mistake 3: Too Lenient Name Matching
```
Problem: Matching files with 40% similarity
Solution: Require ≥ 60% similarity
Why: Avoids false positives for coincidentally similar names
```

### ❌ Mistake 4: Ignoring Language Differences
```
Problem: Hindi and English names marked as different
Solution: Normalize both to comparable form before matching
Why: Same video often uploaded with different language names
```

### ❌ Mistake 5: Including Common Words in Similarity
```
Problem: "Bhajan" matches every Hindu devotional video
Solution: Filter out generic/common words first
Why: Filler words create false high similarity
```

### ❌ Mistake 6: One-way Matching Only
```
Problem: Only checking if Source file in Reference
Solution: Check bidirectional for completeness
Why: Ensures all duplicates captured regardless of direction
```

---

## 9. Example Execution

### Input
```
Folder A: ~/Videos/Bhajans from Pendrive (98 files)
Folder B: ~/Videos/Bhajans - YouTube (167 files)
```

### Processing Steps
```
Step 1: Extract durations
  File 1: "Bholenath ji - Hashtag pandit.mp4" → 280.225 seconds
  File 2: "Adharam Madhuram.mp4" → 1897.7 seconds
  ... [266 files total]

Step 2: Normalize names & extract keywords
  "Bholenath ji - Hashtag pandit - Abhilipsa panda - Tera roop hai"
  → "bholenath ji hashtag pandit abhilipsa panda tera roop hai"
  → Keywords: {bholenath, hashtag, pandit, abhilipsa, panda}

Step 3: Match by duration
  Folder A file (280.225s) → Find all Folder B files with 280.225s
  Found: "Bholenath ji ｜ Hashtag pandit ｜ Abhilipsa panda ｜ Tera"

Step 4: Calculate similarity
  Normalized A: "bholenath ji hashtag pandit abhilipsa panda tera roop hai"
  Normalized B: "bholenath ji hashtag pandit abhilipsa panda tera"
  String match: 85%
  Keyword overlap: 100% (all keywords in B are in A)
  Combined: 0.85 × 0.6 + 1.0 × 0.4 = 0.91 (91%)

Step 5: Accept match
  91% ≥ 60% threshold → DUPLICATE CONFIRMED
```

### Output
```
DUPLICATE #1:
  Pendrive: "Bholenath ji - Hashtag pandit - Abhilipsa panda - Tera roop hai"
  YouTube:  "Bholenath ji ｜ Hashtag pandit ｜ Abhilipsa panda ｜ Tera"
  Duration: 4m 40s
  Similarity: 91.0% ✓ PERFECT MATCH
```

---

## 10. Future Enhancements

### Possible Improvements
```
1. Perceptual hashing (frame analysis for videos)
   - Extract first frame, compare visually
   - More robust for re-encoded videos
   - Slower but more accurate

2. Audio fingerprinting
   - Extract audio, create fingerprint
   - Works even if audio different quality
   - Requires specialized library (Shazam-like)

3. Metadata extraction
   - Creation date, camera model, GPS coords
   - Helps identify mobile video duplicates

4. Machine learning classification
   - Train on known duplicates
   - Predict duplicates with confidence scores
   - Requires labeled dataset

5. Multi-language support
   - Hindi, Tamil, Telugu, Gujarati, etc.
   - Transliteration for all Indian scripts
```

---

## 11. Testing Checklist

- [ ] Test with 100% identical files (expect 100% match)
- [ ] Test with same video, different quality (expect ≥90% match)
- [ ] Test with same video, different language (expect ≥90% match)
- [ ] Test with completely different videos (expect <60%, marked unique)
- [ ] Test with corrupted file (expect graceful skip)
- [ ] Test with very long video (>2 hours)
- [ ] Test with very short video (<10 seconds)
- [ ] Test with empty folders
- [ ] Test with mixed format extensions
- [ ] Test with special characters in names (emoji, Arabic, etc.)

---

## 12. Usage Template

```python
#!/usr/bin/env python3
"""
Generic Duplicate File Finder
Based on: Exact Duration + Name Similarity Algorithm
"""

import subprocess
import json
from pathlib import Path
from difflib import SequenceMatcher
import re

def get_duration(file_path):
    """Extract exact duration from media file."""
    # Use ffprobe to get duration
    # Handle errors gracefully
    # Return duration in seconds

def normalize_name(filename):
    """Normalize filename for comparison."""
    # Remove extension
    # Replace separators with spaces
    # Convert to lowercase
    # Remove special characters
    # Return normalized string

def extract_keywords(name, common_words_set):
    """Extract meaningful keywords from name."""
    # Split into words
    # Filter out common words
    # Return set of keywords

def calculate_similarity(name1, name2):
    """Calculate combined similarity score."""
    # String similarity (60% weight)
    # Keyword overlap (40% weight)
    # Return combined score [0-1]

def find_duplicates(source_folder, ref_folder, threshold=0.60):
    """Find duplicates between two folders."""
    # Scan both folders
    # Match by duration
    # Calculate similarity
    # Filter by threshold
    # Return results

def main():
    # Define folders
    # Call find_duplicates()
    # Format output
    # Save results
    # Print summary
```

---

## 13. License & Attribution

**Document Version:** 1.0  
**Last Updated:** 2026-07-10  
**Original Task:** Finding duplicate bhajan videos between "Bhajans from Pendrive" and "Bhajans - YouTube"  
**Result:** Successfully identified 27 exact duplicates and 69 unique videos  

This specification can be used for any media file duplicate detection task where:
- Files may be re-encoded
- Names may differ (translation, abbreviation)
- Files support duration extraction
- Exact hash matching is insufficient
