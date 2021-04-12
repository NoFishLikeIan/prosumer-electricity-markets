"""
Maps 1 -> 2 and 2 -> 1
"""
function switch(idx)
    (idx % 2) + 1
end