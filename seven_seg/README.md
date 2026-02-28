# 7-Segment Display Test

2-digit multiplexed counter, counts 00 to 99 and wraps.
Each step is 0.5 seconds. Digits are multiplexed at ~100 Hz.
Segments and digits are active-low.

**Segments:** A=32 B=31 C=28 D=27 E=26 F=25 G=23
**Digits:** D1=34 (tens), D2=35 (ones) | **DP:** not connected

**Expected:** Display counts 00 → 01 → 02 → ... → 99 → 00.
