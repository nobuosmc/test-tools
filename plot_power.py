import pandas as pd
import matplotlib.pyplot as plt
from scipy.interpolate import make_interp_spline
import numpy as np
import matplotlib as mpl


model = 'rccl'
file_prefix = "1node_dcmi_"+ model
data_file = file_prefix +".csv"
img_file = file_prefix +".jpg"

fan_mode = "optimal"

df = pd.read_csv(data_file)
min_power, max_power = df["Instant(W)"].min(), df["Instant(W)"].max()

# # ###########################################################################################
# smooth_times = (
#     pd.date_range(df["Sys.Time"].min(), df["Sys.Time"].max(), freq="0.3s")
#     .astype("string")
#     .to_list()
# )
# min_time = mpl.dates.datestr2num(df["Sys.Time"].min())
# max_time = mpl.dates.datestr2num(df["Sys.Time"].max())
# x_new = np.linspace(min_time, max_time, len(smooth_times))

# a_BSpline = make_interp_spline(df["Sys.Time"].map(mpl.dates.datestr2num), df["Instant(W)"])
# y_new = a_BSpline(x_new)

# print("origin min/max:", min_power, max_power)
# print("smooth min/max:", round(y_new.min(), 0), round(y_new.max(), 0))
# # ###########################################################################################

# Draw Plot
plt.figure(figsize=(16, 4), dpi=80)

# plt.plot(
#     df["Sys.Time"], df["Instant(W)"], color="tab:pink", linewidth=2, marker="o",
#     markerfacecolor="pink", markersize=2, markeredgecolor="tab:pink",
# )
plt.plot(
    df["Sys.Time"], df["Instant(W)"], color="#5F6FDF", linewidth=2.5,
    markerfacecolor="#5F6FDF", markersize=2, markeredgecolor="#5F6FDF",
)
# # ###########################################################################################
# plt.plot(
#     smooth_times, y_new, color="tab:pink", linewidth=2, marker="o", 
#     markerfacecolor="pink", markersize=2, markeredgecolor="tab:pink",
# )
# # ###########################################################################################

# Decoration
plt.ylim(min_power-650, max_power+850)

xtick_num = df.shape[0]//15
xtick_location = [i for i in range(len(df["Sys.Time"].to_list()))][::xtick_num]
xtick_labels = df["Sys.Time"].to_list()[::xtick_num]
# # ###########################################################################################
# xtick_num = len(smooth_times)//20
# xtick_location = [i for i in range(len(smooth_times))][::xtick_num]
# xtick_labels = smooth_times[::xtick_num]
# # ###########################################################################################

plt.xticks(ticks=xtick_location, labels=xtick_labels, horizontalalignment="right",
           rotation=45, fontsize=10, alpha=0.7)
plt.yticks(fontsize=12, alpha=0.7)

# set image title
# img_title = "MI300X Llama-2-"+ model +"-chat-hf Inference"
img_title = "MI300X 1node all_reduce"
plt.title(img_title, fontsize=22, pad=20)

plt.grid(axis="both", alpha=0.3)
lgnd = plt.legend(labels=["Fan mode: " + fan_mode], bbox_to_anchor=(0.5, 1.), loc="center", edgecolor='1.', markerscale=100.,
                  labelcolor='#8C8C8C', prop={"size":12, "weight": "bold"})
plt.margins(0.01)
plt.ylabel("Watts", fontsize=16)

# Remove borders
plt.gca().spines["top"].set_alpha(0.0)
plt.gca().spines["bottom"].set_alpha(0.3)
plt.gca().spines["right"].set_alpha(0.0)
plt.gca().spines["left"].set_alpha(0.3)

plt.subplots_adjust(top=0.85, bottom=0.35)
# plt.show()

plt.savefig(img_file)
print(img_file +" successfully saved in ./")
