# -*- coding: utf-8 -*-
"""
Plotting OR for Journal Club presentation of:
    https://doi.org/10.1093/ageing/afs076
"""
import pandas as pd
import matplotlib.pyplot as plt

reg_path = '../data/log-reg.xlsx'

fig = plt.figure(figsize = (7, 10))

# Load sheet
reg_result = pd.read_excel(reg_path)

# Split CI string
split_strings = reg_result["95% CI"].str.split(',')
reg_result["CI-lower"] = [float(split_i[0]) for split_i in split_strings]
reg_result["CI-upper"] = [float(split_i[1]) for split_i in split_strings]

# Calculate upper and lower error
reg_result["error-lower"] = [max(0, reg_result["OR"][i] - reg_result["CI-lower"][i]) for i in range(len(reg_result))]

reg_result["error-upper"] = [max(0, reg_result["CI-upper"][i] - reg_result["OR"][i]) for i in range(len(reg_result))] 

# prepare new plot axis
ax = fig.add_subplot(1,1,1)

# Plot group regions
borders = [0,2,5,8,11,14,18,20]

for j in range(len(borders)-1):
    if j % 2 == 0:
        color = "tab:blue"
    else:
        color = "white"
    plt.fill_between([-1, 17],
                     [borders[j]-0.5, borders[j]-0.5], 
                     [borders[j+1]-0.5, borders[j+1]-0.5],
                     color = color, alpha = 0.05,
                     lw = 0, zorder = 0)

# Plot results
n_vars = len(reg_result)
reg_result["Plot_OR"] = reg_result["OR"]



ax.errorbar(reg_result["Plot_OR"],range(n_vars)[::-1], fmt = "o", ms = 6,
            color = "k",
            xerr=[reg_result["error-lower"],
                  reg_result["error-upper"]], zorder = 1,
            ecolor = "k")
ax.plot(reg_result["Plot_OR"],range(n_vars)[::-1], "o", ms = 4,
            color = "tab:blue")


# Define axis limits
ax.set_xlim(0, 17)
ax.plot([1,1],[-1, n_vars], "k--")
ax.set_yticks(range(n_vars))
ax.set_ylim(-0.5, n_vars-0.5)
ax.set_xticks([0,1,5, 10, 15])
ax.set_yticklabels(reg_result["Characteristic"][::-1], size = 12)

ax.set_xlabel("Odds Ratio", size = 14)

# Save output
fig.savefig("../output/reg-results.svg", bbox_inches = "tight")