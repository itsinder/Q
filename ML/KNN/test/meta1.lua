return { 
 { name = "ccid", qtype = "I4"},
 { name = "click_ts", qtype = "SC", width = "36", is_load = false },
 { name = "msec_since_epoch", qtype = "I8" },
 { name = "score", qtype = "I4" },
 { name = "otp", qtype = "F4" }, 
 { name = "util", qtype = "F4" },
 { name = "q", qtype = "F4" },
 { name = "ty", qtype = "F4" },
 { name = "goal", qtype = "I1" } -- 1 or 0, what we are tryigng to predict
}
