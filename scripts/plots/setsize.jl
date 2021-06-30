
upscale = 8 # 8x upscaling in resolution
fntsm = Plots.font("sans-serif", pointsize=round(10.0 * upscale))
fntlg = Plots.font("sans-serif", pointsize=round(14.0 * upscale))
default(titlefont=fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm)
default(size=(800 * upscale, 600 * upscale)) # Plot canvas size
        