#START OF AUTO-GENERATED PREAMBLE, WILL BE OVERWRITTEN WHEN THIS FILE IS USED AS A TEMPLATE
#Created 2025-01-30 at 11:10

xpose.runno <- '107'
toolname <- 'vpc'
pdf.filename <- paste0('PsN_',toolname,'_plots.pdf')
working.directory<-'/Users/jeff/Desktop/nonmem_project/test_nonmem/vpc_test_model/'
results.directory <- '..'
subset.variable<-NULL
tab.suffix <- '' 
rscripts.directory <- '/Library/Perl/5.34/PsN_5_5_0/R-scripts' # This is not used
tool.results.file <- 'vpc_results.csv'
theta.labels <- c('CLTV','VTV','KATV','prop error','additive error')
theta.fixed <- c(FALSE,FALSE,FALSE,FALSE,TRUE)
omega.labels <- c('IIV CL','IIV V','IIV KA')
omega.fixed <- c(FALSE,FALSE,FALSE)
sigma.labels <- c('PRO')
sigma.fixed <- c(TRUE)
n.eta <- 3
n.eps <- 1

vpctab <- 'vpctab'
have.loq.data <- FALSE
have.censored <- FALSE
is.categorical <- FALSE
is.tte <- FALSE
dv <- 'DV'
idv <- 'TIME'
samples <- 200

setwd(working.directory)

############################################################################
#END OF AUTO-GENERATED PREAMBLE
#WHEN THIS FILE IS USED AS A TEMPLATE THIS LINE MUST LOOK EXACTLY LIKE THIS


pdf(file=pdf.filename,width=10,height=7)
# get libPaths
library(PsNR)
library(magrittr)
library(methods)
library(xpose4)
library(vpc)
library(ggplot2)

#add R_info to the meta file
R_info(directory=working.directory)
meta <- PsNR::metadata(working.directory)

if (is.tte) {
    #data is in the model directory, go there to read input
    setwd(dirname(PsNR::model_path(meta)))
    capture.output(xpdb <- xpose4::xpose.data(PsNR::model_runno(meta)))
    plots <- xpose4::kaplan.plot(object=xpdb, VPC=T)
    #go back to vpc directory 
    setwd(working.directory)
} else if (is.categorical) { 
    plots <- xpose4::xpose.VPC.categorical(vpc.info=tool.results.file, vpctab=vpctab)
} else if (have.loq.data | have.censored) {
    plots <- xpose4::xpose.VPC.both(vpc.info=tool.results.file, vpctab=vpctab)
} else {
    plots <- xpose4::xpose.VPC(vpc.info=tool.results.file, vpctab=vpctab)
}
print(plots) 
if (exists('mix')) {     # A mixture model is a special case
    if (require("vpc")) {
        cat("<BR>")
        observations_tablefile <- paste0(working.directory, '/m1/vpc_original.npctab.dta')
        simulations_tablefile <- paste0(working.directory, '/m1/vpc_simulation.1.npctab.dta')

        obs <- read_nonmem_table(observations_tablefile)
        sim <- read_nonmem_table(simulations_tablefile)
        obs_phm <- read_nonmem_table(phm_obs_file)
        sim_phm <- read_nonmem_table(phm_sim_file)
        if (!exists('stratify_on')) {
            stratify_on <- NULL
        }

        # Read name of IDV from vpc_results.csv
        vpc_res <- read.csv(paste0(working.directory, '/vpc_results.csv'), skip=1, nrows=1, stringsAsFactors=FALSE)
        idv <- trimws(vpc_res$Independent.variable)

        vpc <- vpc::vpc(obs=obs, sim=sim, obs_cols=list(dv=dv, idv=idv), sim_cols=list(dv=dv, idv=idv), stratify=stratify_on, bins=bin_boundaries)
        print(vpc)
        plots_mixest <- mixture_vpc(obs, sim, obs_phm, sim_phm, dv=dv, idv=idv, bins=bin_boundaries, stratify_on=stratify_on)
        plots_randomized <- mixture_vpc(obs, sim, obs_phm, sim_phm, dv=dv, idv=idv, bins=bin_boundaries, stratify_on=stratify_on, randomize=TRUE)
        plots <- list()
        for (i in 1:length(plots_mixest)) {
            mixest <- plots_mixest[[i]]
            randomized <- plots_randomized[[i]]
            if (is.character(mixest) || is.character(randomized)) {     # An error message instead of plot
                cat("\\pagebreak\n\n")
                cat(p)
                cat("\\pagebreak")
            } else {
                plots[[2*i - 1]] <- mixest
                plots[[2*i]] <- randomized
            }
        }
        print(gridExtra::marrangeGrob(plots, nrow=2, ncol=2, top=NULL, padding=0))
        cat('<BR>')
        plots <- list()
        for (i in unique(obs_phm$SUBPOP)) { # Allowing cases with more than 2 mixtures
            temp_obs <- obs_phm %>% dplyr::filter(SUBPOP == i) %>% 
                        dplyr::arrange(PMIX) %>% 
                        dplyr::mutate(rank=1:dplyr::n()) # Get rank for the plot
            temp_sim <- sim_phm %>% dplyr::filter(SUBPOP == i) %>% 
                    dplyr::group_by(replicate) %>% # Assuming replicate is the simulation number
                    dplyr::arrange(PMIX) %>% 
                    dplyr::mutate(rank = 1:dplyr::n()) %>%  # Get rank for the plot by simulation
                    dplyr::group_by(rank) %>% 
                    dplyr::summarise(per5=quantile(PMIX, probs=c(0.05)), 
                                     per95=quantile(PMIX, probs=c(0.95))) # Get percentiles among simulations

            plots[[i]] <- ggplot() + 
                          geom_ribbon(data=temp_sim, aes(rank, ymin=per5, ymax=per95), alpha=0.2) +
                          geom_text(data=temp_obs, aes(rank, PMIX, label=SUBJECT_NO), size=8) +
                          geom_hline(yintercept=0.5, linetype="dashed", size=2) +
                          theme_classic() +
                          theme(axis.text.y=element_text(size=20),
                                axis.title.y=element_blank(),
                                axis.ticks.y=element_line(size=3),
                                axis.ticks.length=unit(6, "pt"),
                                axis.ticks.x=element_blank(),
                                axis.title.x=element_text(size=25),
                                axis.text.x=element_blank()) +
                          xlab(paste0("SUBPOP=", i))
            if (i > 1) {
                plots[[i]] <- plots[[i]] + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
            }
        }

        left_axis = grid::textGrob("IPmix", gp=grid::gpar(font=2,fontsize=25), rot=90)
        bottom_axis = grid::textGrob("Sorted ID", gp=grid::gpar(font=2,fontsize=25))
        title = grid::textGrob("IPmix with uncertainty 5-95% CI", gp=grid::gpar(font=2,fontsize=35))
        gridExtra::marrangeGrob(plots, nrow=1, ncol=2, top=title, left=left_axis, bottom=bottom_axis)
    }
}
dev.off()

