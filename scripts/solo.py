import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, TwoSlopeNorm
from matplotlib.widgets import Slider, RadioButtons
from matplotlib.patches import Patch
import seaborn as sns

# 强制中文兼容
plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'sans-serif']
plt.rcParams['axes.unicode_minus'] = False

def compute_binary_bounds(n, alpha):
    """计算二元假设 (p=0.5) 下无法拒绝两端极端的定平区间边界 (O(logN) 优化)"""
    N = 2 * n
    # 寻找使得拒绝对立假设 p >= 0.5 失败的下界起点
    low, high, C_lower = 0, N, N
    while low <= high:
        mid = (low + high) // 2
        if stats.binom.cdf(mid, N, 0.5) > alpha:
            C_lower = mid
            high = mid - 1
        else:
            low = mid + 1
            
    # 寻找使得拒绝对立假设 p <= 0.5 失败的上界终点
    low, high, C_upper = 0, N, 0
    while low <= high:
        mid = (low + high) // 2
        if stats.binom.sf(mid - 1, N, 0.5) > alpha:
            C_upper = mid
            low = mid + 1
        else:
            high = mid - 1
            
    return C_lower / N, C_upper / N

def compute_required_n(delta, alpha):
    """计算将定平区间完全压缩到 [0.5-delta, 0.5+delta] 内至少需要的 n"""
    z = stats.norm.ppf(1 - alpha)
    n = max(1, int(0.5 * (z / (2 * delta))**2) - 100)
    
    while n > 1:
        lb, ub = compute_binary_bounds(n, alpha)
        if lb >= 0.5 - delta + 1e-9 and ub <= 0.5 + delta - 1e-9:
            n -= 1
        else:
            n += 1
            break
            
    while True:
        lb, ub = compute_binary_bounds(n, alpha)
        if lb >= 0.5 - delta + 1e-9 and ub <= 0.5 + delta - 1e-9:
            return n
        n += 1

def compute_data(n, delta, alpha):
    """计算双模型假设检验的颜色矩阵和文本矩阵"""
    size = n + 1
    color_single = np.zeros((size, size))
    color_strat = np.zeros((size, size))
    cred_single = np.zeros((size, size))
    cred_strat = np.zeros((size, size))
    text_single = np.empty((size, size), dtype=object)
    text_strat = np.empty((size, size), dtype=object)
    
    bounds = (0.5 - delta, 0.5 + delta)
    
    for i in range(size):
        for j in range(size):
            x1, x2 = i, j
            
            # 模型 A: 单一模型对照组 (精确二项检验)
            X_total = x1 + x2
            N_total = 2 * n
            P_hat_single = X_total / N_total
            
            p_rej_tails_S = stats.binomtest(X_total, N_total, bounds[0], alternative='greater').pvalue
            p_rej_heads_S = stats.binomtest(X_total, N_total, bounds[1], alternative='less').pvalue
            
            if P_hat_single > bounds[1]:
                p_rej_fair_S = stats.binomtest(X_total, N_total, bounds[1], alternative='greater').pvalue
                disp_p_S = p_rej_fair_S
            elif P_hat_single < bounds[0]:
                p_rej_fair_S = stats.binomtest(X_total, N_total, bounds[0], alternative='less').pvalue
                disp_p_S = p_rej_fair_S
            else:
                p_rej_fair_S = 1.0
                disp_p_S = max(p_rej_tails_S, p_rej_heads_S)
            
            rejections_S = sum(p <= alpha for p in [p_rej_tails_S, p_rej_heads_S, p_rej_fair_S])
            color_single[i, j] = 2 if rejections_S >= 2 else (1 if rejections_S == 1 else 0)
            cred_S = 1 - disp_p_S
            cred_single[i, j] = cred_S
            text_single[i, j] = f"{cred_S:.2f}" if cred_S <= 0.99 else ">.99"

            # 模型 B: 分层 Z 检验
            p1_hat, p2_hat = x1 / n, x2 / n
            P_hat_strat = 0.5 * p1_hat + 0.5 * p2_hat
            
            var_strat = (0.25 * p1_hat * (1 - p1_hat) / n) + (0.25 * p2_hat * (1 - p2_hat) / n)
            se_strat = np.sqrt(max(var_strat, 1e-8))
            
            z_tails = (P_hat_strat - bounds[0]) / se_strat
            p_rej_tails_Z = stats.norm.sf(z_tails)
            
            z_heads = (P_hat_strat - bounds[1]) / se_strat
            p_rej_heads_Z = stats.norm.cdf(z_heads)
            
            if P_hat_strat > bounds[1]:
                p_rej_fair_Z = stats.norm.sf(z_heads)
                disp_p_Z = p_rej_fair_Z
            elif P_hat_strat < bounds[0]:
                p_rej_fair_Z = stats.norm.cdf(z_tails)
                disp_p_Z = p_rej_fair_Z
            else:
                p_rej_fair_Z = 1.0
                disp_p_Z = max(p_rej_tails_Z, p_rej_heads_Z)
                
            rejections_Z = sum(p <= alpha for p in [p_rej_tails_Z, p_rej_heads_Z, p_rej_fair_Z])
            color_strat[i, j] = 2 if rejections_Z >= 2 else (1 if rejections_Z == 1 else 0)
            cred_Z = 1 - disp_p_Z
            cred_strat[i, j] = cred_Z
            text_strat[i, j] = f"{cred_Z:.2f}" if cred_Z <= 0.99 else ">.99"
    
    return color_single, color_strat, cred_single, cred_strat, text_single, text_strat

def draw_heatmaps(fig, axes, n, delta, alpha, mode="离散假设裁定"):
    """绘制双热力图及边界线"""
    color_single, color_strat, cred_single, cred_strat, text_single, text_strat = compute_data(n, delta, alpha)
    size = n + 1
    
    for ax in axes:
        ax.clear()
        
    if mode == "离散假设裁定":
        data_S = color_single
        data_Z = color_strat
        cmap = ListedColormap(['#ff6b6b', '#feca57', '#1dd1a1'])
        kwargs = {"vmin": 0, "vmax": 2}
    else:
        # 统计学非线性染色：以 (1-alpha) 为黄色的锚点，低于0.5视为完全红
        data_S = np.clip(cred_single, 0.5, 1.0)
        data_Z = np.clip(cred_strat, 0.5, 1.0)
        cmap = 'RdYlGn'
        norm = TwoSlopeNorm(vmin=0.5, vcenter=1.0 - alpha, vmax=1.0)
        kwargs = {"norm": norm}
    
    # 绘制单一边界热力图
    sns.heatmap(data_S, annot=text_single, fmt="", cmap=cmap, cbar=False,
                linewidths=.5, ax=axes[0], square=True, annot_kws={"fontsize": 9}, **kwargs)
    axes[0].set_title(f'单一二项分布对照组 (精确二项检验)\nTotal n={2*n}, Delta={delta}, Alpha={alpha}', fontsize=14, pad=15)
    axes[0].set_ylabel(f'先手胜场 (0-{n})', fontsize=12)
    axes[0].set_xlabel(f'后手胜场 (0-{n})', fontsize=12)
    
    # 绘制分层建模热力图
    sns.heatmap(data_Z, annot=text_strat, fmt="", cmap=cmap, cbar=False,
                linewidths=.5, ax=axes[1], square=True, annot_kws={"fontsize": 9}, **kwargs)
    axes[1].set_title(f'分层建模组 (分层 Z 检验)\nn1={n}, n2={n}, Delta={delta}, Alpha={alpha}', fontsize=14, pad=15)
    axes[1].set_ylabel(f'先手胜场 (0-{n})', fontsize=12)
    axes[1].set_xlabel(f'后手胜场 (0-{n})', fontsize=12)
    
    # 绘制 p_hat = 0.5 ± delta 边界线
    C_upper = n * (1 + 2 * delta)
    C_lower = n * (1 - 2 * delta)
    
    for ax in axes:
        K_u = C_upper + 1
        x0_u = max(0, K_u - size)
        y0_u = K_u - x0_u
        x1_u = min(size, K_u)
        y1_u = K_u - x1_u
        ax.plot([x0_u, x1_u], [y0_u, y1_u],
                color='black', linewidth=2, linestyle='--', label=f'P_hat={0.5+delta:.2f}')
        
        K_l = C_lower + 1
        x0_l = max(0, K_l - size)
        y0_l = K_l - x0_l
        x1_l = min(size, K_l)
        y1_l = K_l - x1_l
        ax.plot([x0_l, x1_l], [y0_l, y1_l],
                color='blue', linewidth=2, linestyle='--', label=f'P_hat={0.5-delta:.2f}')
        ax.legend(loc='upper left', bbox_to_anchor=(0, -0.05), fontsize=9, ncol=2)

def interactive_viewer():
    """交互式滑块界面"""
    fig, axes = plt.subplots(1, 2, figsize=(20, 10))
    fig.subplots_adjust(bottom=0.22, right=0.82)
    
    # 创建滑块区域
    ax_n = fig.add_axes([0.15, 0.10, 0.65, 0.03])
    ax_delta = fig.add_axes([0.15, 0.06, 0.65, 0.03])
    ax_alpha = fig.add_axes([0.15, 0.02, 0.65, 0.03])
    
    # 创建滑块
    slider_n = Slider(ax_n, 'n', 5, 50, valinit=15, valstep=1, color='#3498db')
    slider_delta = Slider(ax_delta, 'Delta', 0.01, 0.20, valinit=0.05, valstep=0.01, color='#2ecc71')
    slider_alpha = Slider(ax_alpha, 'Alpha', 0.01, 0.20, valinit=0.1, valstep=0.01, color='#e74c3c')
    
    # 模式切换开关
    ax_radio = fig.add_axes([0.83, 0.7, 0.15, 0.15])
    ax_radio.set_frame_on(False)
    radio = RadioButtons(ax_radio, ('离散假设裁定', '连续证据强度'))
    
    # 添加图例区域
    legend_ax = fig.add_axes([0.83, 0.4, 0.15, 0.2])
    legend_ax.axis('off')
    
    def update_legend(mode, current_alpha):
        legend_ax.clear()
        legend_ax.axis('off')
        if mode == '离散假设裁定':
            legend_elements = [
                Patch(facecolor='#1dd1a1', edgecolor='gray', label='成功拒绝其余两个假设'),
                Patch(facecolor='#feca57', edgecolor='gray', label='仅能拒绝一个假设'),
                Patch(facecolor='#ff6b6b', edgecolor='gray', label='无法拒绝任何假设')
            ]
            legend_ax.legend(handles=legend_elements, loc='center', title='假设裁定', 
                             fontsize=11, title_fontsize=13, frameon=True, labelspacing=1.5)
        else:
            legend_elements = [
                Patch(facecolor='#1a9850', edgecolor='gray', label=f'判定成立'),
                Patch(facecolor='#ffffbf', edgecolor='gray', label=f'临界边界'),
                Patch(facecolor='#d73027', edgecolor='gray', label='证据极弱')
            ]
            legend_ax.legend(handles=legend_elements, loc='center', title='显著性强度', 
                             fontsize=11, title_fontsize=13, frameon=True, labelspacing=1.5)
                             
    # 添加二元定平区间提示文本
    bounds_text = fig.text(0.83, 0.20, '', ha='left', va='center', fontsize=12,
                           color='#2c3e50', fontweight='bold',
                           bbox=dict(facecolor='#f8f9fa', edgecolor='gray', boxstyle='round,pad=0.5'))
                           
    # 添加加载提示文本
    loading_text = fig.text(0.5, 0.5, '', ha='center', va='center', fontsize=20,
                            color='red', fontweight='bold', zorder=100)
    
    # 初始绘制
    draw_heatmaps(fig, axes, 15, 0.05, 0.1, '离散假设裁定')
    update_legend('离散假设裁定', 0.1)
    lower_b, upper_b = compute_binary_bounds(15, 0.1)
    req_n = compute_required_n(0.05, 0.1)
    bounds_text.set_text(
        f"二元对称假设 (p=0.5)下\n"
        f"显著性 10% 的定平区间为 [{lower_b:.3f}, {upper_b:.3f}]\n"
        f"若要压缩到 [{0.5-0.05:.3f}, {0.5+0.05:.3f}]\n"
        f"至少需要先后手各 {req_n} 局"
    )
    
    def update(val):
        n = int(slider_n.val)
        delta = round(slider_delta.val, 2)
        alpha = round(slider_alpha.val, 2)
        mode = radio.value_selected
        
        loading_text.set_text('计算中...')
        fig.canvas.draw_idle()
        fig.canvas.flush_events()
        
        draw_heatmaps(fig, axes, n, delta, alpha, mode)
        update_legend(mode, alpha)
        
        lower_b, upper_b = compute_binary_bounds(n, alpha)
        req_n = compute_required_n(delta, alpha)
        pct = alpha * 100
        # Format the percentage correctly depending on if it's an integer
        alpha_str = f"{pct:.0f}" if pct.is_integer() else f"{pct:.1f}"
        
        bounds_text.set_text(
            f"二元对称假设 (p=0.5)下\n"
            f"显著性 {alpha_str}% 的定平区间为 [{lower_b:.3f}, {upper_b:.3f}]\n"
            f"若要压缩到 [{0.5-delta:.3f}, {0.5+delta:.3f}]\n"
            f"至少需要先后手各 {req_n} 局"
        )
        
        loading_text.set_text('')
        fig.canvas.draw_idle()
    
    slider_n.on_changed(update)
    slider_delta.on_changed(update)
    slider_alpha.on_changed(update)
    radio.on_clicked(update)

    plt.show()

# 启动交互界面
interactive_viewer()