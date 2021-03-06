rm(list=ls())
#Sources: 


###packages
library(caret)
library(ggplot2)
library(scales)
library(stringr)
library(plyr)

#Sources: 
setwd(dirname(rstudioapi::getSourceEditorContext()[[2]]))
sub <- "nov18_test/2018-11-25_ffs_plsnofrst_noelevelev2_cvindex/"
# sub <- "nov18/2018-11-16_ffs_plsnofrst_noelevelev2_cvindex/"
inpath_general <- "../data/"
inpath <- paste0("../data/", sub)
outpath <- paste0("../out/", sub)
if (file.exists(outpath)==F){
  dir.create(file.path(outpath), recursive = T)
}

if (grepl("nofrst", sub) == T){
  set <- "nofrst"
}else if (grepl("frst", sub) == T & grepl("nofrst", sub) == F){
  set <- "frst"
}else if (grepl("allplts", sub)){
  set <- "allplts"
}
##read data
prdct_df <- readRDS(file = paste0(outpath, "prdct_df.rds"))
trophic_tbl <- read.csv(paste0(inpath_general, "trophic_tbl.csv"), header = T, sep = ";", dec = ",") 
# pls_elevsq_prdct_cv_df <- readRDS(file = paste0(outpath, "pls_elevsq_prdct_cv_df.rds"))
mrg_tbl <- readRDS(paste0(inpath, "../tbl_mrg_", set, ".rds"))
obs_smmry <- readRDS(file = paste0(outpath, "obs_smmry.rds"))
err_hand_lst <- readRDS(file = paste0(inpath, "err_handling_files.rds"))
prdct_elev <- readRDS(paste0(inpath, "../df_resp_prdct_elev_", set, ".rds"))
# resp_vec <- colnames(mrg_tbl)[c(which(colnames(mrg_tbl) == "SRmammals") : 
#                                   which(colnames(mrg_tbl) == "SRmagnoliids"), 
#                                 which(colnames(mrg_tbl) == "sum_predator_N5") : 
#                                   which(colnames(mrg_tbl) == "sum_plant_N8"))]
resp_vec <- colnames(mrg_tbl)[c(which(colnames(mrg_tbl) == "SRmammals") :
                                  which(colnames(mrg_tbl) == "SRmagnoliids"),
                                grep("^sum_predator_N", colnames(mrg_tbl)) :
                                  grep("^sum_plant_N", colnames(mrg_tbl)))]



stats_all_lst <- lapply(resp_vec, function(resp){
  if(sum(grepl(paste0("^", resp), colnames(prdct_df))) > 0){
  print(resp)
  ##crop data on resp
  ##obs SR (forest and non-forest)
  obs_SRresp <- mrg_tbl[,c(which(colnames(mrg_tbl) %in% c("plotID", "plotUnq")), 
                            which(grepl(paste0("^", resp), colnames(mrg_tbl))))]
  ##obs resid (forest and non_forest)
  obs_residresp <- mrg_tbl[,c(which(colnames(mrg_tbl) %in% c("plotID", "plotUnq")), 
                               which(grepl(paste0("resid", resp), colnames(mrg_tbl))))]
  
  ##pls SR
  pls_SRresp <- prdct_df[,c(which(colnames(prdct_df) %in% c("plotID", "plotUnq")), 
                             which(grepl(paste0("^", resp), colnames(prdct_df))))]
  
  ##pls resid
  pls_residresp <- prdct_df[,c(which(colnames(prdct_df) %in% c("plotID", "plotUnq")), 
                                which(grepl(paste0("resid", resp), colnames(prdct_df))))]
  
  
  #prdct_elevsq aus resid berechnung cv
  prdct_elev_resp <- prdct_elev[,c(which(colnames(prdct_elev) %in% c("plotID", "plotUnq", "runs")),
                                   which(grepl(resp, colnames(prdct_elev))))]
  ##sum prdct_elevsq + resid aus resid berechnung
  #sum_elevsq_resid <- pls_residresp
  
  #####################################################################################
  # names(pls_residresp) <- paste0("ModellierteResiduen_",names(pls_residresp))
  # names(prdct_elev_resp)  <- paste0("Hoehenmodell_",names(prdct_elev_resp))
  # names(obs_SRresp) <- paste0("Observed_",names(obs_SRresp))
  # dat <- merge(pls_residresp,prdct_elev_resp,by.x="ModellierteResiduen_plotUnq",by.y="Hoehenmodell_plotUnq")
  # dat <- merge(dat,obs_SRresp,by.x="ModellierteResiduen_plotUnq",by.y="Observed_plotUnq")
  # dat$finalModel_run1 <- dat$ModellierteResiduen_residSRmammals_run1+dat$Hoehenmodell_SRmammals
  # dat$finalModel_run2 <- dat$ModellierteResiduen_residSRmammals_run2+dat$Hoehenmodell_SRmammals
  # dat$finalModel_run3 <- dat$ModellierteResiduen_residSRmammals_run3+dat$Hoehenmodell_SRmammals
  # dat$finalModel_run4 <- dat$ModellierteResiduen_residSRmammals_run4+dat$Hoehenmodell_SRmammals
  # dat$finalModel_run5 <- dat$ModellierteResiduen_residSRmammals_run5+dat$Hoehenmodell_SRmammals
  # 
  # dat_final <- dat[,names(dat)%in%c("Hoehenmodell_SRmammals",
  #                                   "Observed_SRmammals",
  #                                   paste0("finalModel_run",1:5))]
  # dat_final$final_SRmammals<-rowSums(dat_final[,3:7],na.rm=TRUE)
  # dat_final$diffHoehe <- abs(dat_final$Hoehenmodell_SRmammals-dat_final$Observed_SRmammals)
  # dat_final$diffFinal <- abs(dat_final$final_SRmammals-dat_final$Observed_SRmammals)
  
  #####################################################################################
  
  for (row in pls_residresp$plotUnq){
    for (col in colnames(pls_residresp)[3:ncol(pls_residresp)]){
      sum_elevsq_resid[which(sum_elevsq_resid$plotUnq == row), col] <- 
        pls_residresp[which(pls_residresp$plotUnq == row), col] + 
        prdct_elev_resp[which(prdct_elev_resp$plotUnq == row), resp]
    }}
  colnames(sum_elevsq_resid)[3:ncol(sum_elevsq_resid)] <- substring(colnames(sum_elevsq_resid)[3:ncol(sum_elevsq_resid)], 6, nchar(colnames(sum_elevsq_resid)[3:ncol(sum_elevsq_resid)]))


  
  
  # ##pls_elevsq cv - alt
  # pls_elevsq_cv_SRresp <- pls_elevsq_prdct_cv_df[, c(which(colnames(pls_elevsq_prdct_cv_df) %in% c("plotID", "plotUnq")), 
  #                                                    which(grepl(resp, colnames(pls_elevsq_prdct_cv_df))))]
  # ##sum elevsqcv und resid
  # prdct_elev_resp_mrgbl <- pls_elevsq_cv_SRresp
  # colnames(prdct_elev_resp_mrgbl)[3:ncol(prdct_elev_resp_mrgbl)] <- str_sub(colnames(prdct_elev_resp_mrgbl)[3:ncol(prdct_elev_resp_mrgbl)],-5, -1)
  # colnames(prdct_elev_resp_mrgbl) <- gsub("[^[:alnum:]]","",colnames(prdct_elev_resp_mrgbl))
  # rownames(prdct_elev_resp_mrgbl) <- prdct_elev_resp_mrgbl$plotUnq
  # prdct_elev_resp_mrgbl <- prdct_elev_resp_mrgbl[,!names(prdct_elev_resp_mrgbl) %in% c("plotID", "plotUnq")]
  # pls_residresp_mrgbl <- pls_residresp
  # colnames(pls_residresp_mrgbl)[3:ncol(pls_residresp_mrgbl)] <- str_sub(colnames(pls_residresp_mrgbl)[3:ncol(pls_residresp_mrgbl)], -4, -1)
  # rownames(pls_residresp_mrgbl) <- pls_residresp_mrgbl$plotUnq
  # pls_residresp_mrgbl <- pls_residresp_mrgbl[,!names(pls_residresp_mrgbl) %in% c("plotID", "plotUnq")]
  # #combine dfs
  # comb_dfs <- cbind(names=c(rownames(prdct_elev_resp_mrgbl), rownames(pls_residresp_mrgbl)),
  #                   rbind.fill(list(prdct_elev_resp_mrgbl, pls_residresp_mrgbl)))
  # sum_elevsq_resid <- ddply(comb_dfs, .(names), function(x) colSums(x[,-1], na.rm = F))
  # colnames(sum_elevsq_resid)[2:ncol(sum_elevsq_resid)] <- paste0(resp, "_", colnames(sum_elevsq_resid)[2:ncol(sum_elevsq_resid)])
  # colnames(sum_elevsq_resid)[1] <- "plotUnq"



  
  

  ##mean N SR - only calculated from frst/nnon-frst plots
  mn_N_SR <- obs_smmry[which(rownames(obs_smmry) == resp),"meanN_perplot"] 
  
  ##mean N resid - only calculated from frst/nnon-frst plots
  mn_N_resid <- obs_smmry[which(rownames(obs_smmry) == paste0("resid", resp)),"meanN_perplot"]
  
  ##sd SR
  sd_resp_SR <- obs_smmry[which(rownames(obs_smmry) == resp),"sd_per_resp"]
  
  #sdresid
  sd_resp_resid <- obs_smmry[which(rownames(obs_smmry) == paste0("resid", resp)),"sd_per_resp"]
  
  #######################
  ###stats calculations
  #######################
  ##SR_pls ~ obs
  runs <- c(paste0(resp, "_run1"), paste0(resp, "_run2"), paste0(resp, "_run3"), 
            paste0(resp, "_run4"), paste0(resp, "_run5"))
  
  stats_pls <- lapply(runs, function(i){
    #print(i)
    R2 <- caret::R2(pls_SRresp[,i], obs_SRresp[,resp], na.rm = T)
    # 1 - (sum((obs-pred)^2, na.rm = na.rm)/((n-1)*var(obs, na.rm = na.rm))))
    #1 - (sum((obs_SRresp[,resp]-pls_SRresp[,i])^2, na.rm = "complete.obs")/((sum(complete.cases((pls_SRresp[,i])))-1)*var(obs_SRresp[,resp], na.rm = "complete.obs")))
    RMSE <- caret::RMSE(pls_SRresp[,i], obs_SRresp[,resp], na.rm = T)
    RMSE_sd <- RMSE / sd_resp_SR
    return(list(resp_run = i, RMSE_sd = RMSE_sd, RMSE = RMSE, R2 = R2))
  })
  stats_pls <- data.frame(do.call("rbind", stats_pls))
  stats_pls$type <- "SR"

  ##sum_elevsq_resid ~ obs
  
  
  #Abfrage ob alle residuen runs gelaufen sind - funktioniert momentan nur bei einem fehlerhaften modell
  if (length(err_hand_lst) > 0){
  if (grepl(paste0("resid", resp), names(err_hand_lst))){
    err_run <- err_hand_lst[paste0("resid", resp)][[1]][[3]]
    runs <- runs[!grepl(err_run, runs)]
  }}
  stats_elevsq_resid_sum <- lapply(runs, function(m){
    print(m)
    R2 <- caret::R2(sum_elevsq_resid[,m], obs_SRresp[,resp], na.rm = T)
    RMSE <- caret::RMSE(sum_elevsq_resid[,m], obs_SRresp[,resp], na.rm = T)
    RMSE_sd <- RMSE / sd_resp_SR
    return(list(resp_run = m, RMSE_sd = RMSE_sd, RMSE = RMSE, R2 = R2))
  })
  stats_elevsq_resid_sum <- data.frame(do.call("rbind", stats_elevsq_resid_sum))
  stats_elevsq_resid_sum$type <- "sum_elevsq_resid"
  
  ##resid_pls ~ obs
  runs_res <- c(paste0("resid", resp, "_run1"), 
                paste0("resid", resp, "_run2"), paste0("resid", resp, "_run3"), 
                paste0("resid", resp, "_run4"), paste0("resid", resp, "_run5"))
  #Abfrage ob alle residuen runs gelaufen sind - funktioniert momentan nur bei einem fehlerhaften modell
  if (length(err_hand_lst) > 0){
  if (grepl(paste0("resid", resp), names(err_hand_lst))){
    err_run <- err_hand_lst[paste0("resid", resp)][[1]][[3]]
    runs_res <- runs_res[!grepl(err_run, runs_res)]
  }}
  stats_res <- lapply(runs_res, function(j){
    # print(j)
    R2 <- caret::R2(pls_residresp[,j], obs_residresp[,paste0("resid", resp)], na.rm = T)
    RMSE <- caret::RMSE(pls_residresp[,j], obs_residresp[,paste0("resid", resp)], na.rm = T)
    RMSE_sd <- RMSE / sd_resp_SR
    return(list(resp_run = j, RMSE_sd = RMSE_sd, RMSE = RMSE, R2 = R2))
  })
  stats_res <- data.frame(do.call("rbind", stats_res))

  stats_res$type <- "resid"

  ##elevsq_pls ~ obs
  runs_pls_elevsq_cv <- c(paste0("prd_", resp, "_run_1"), paste0("prd_", resp, "_run_2"), 
                   paste0("prd_", resp, "_run_3"), paste0("prd_", resp, "_run_4"), 
                   paste0("prd_", resp, "_run_5"))
  stats_pls_elevsq_cv <- lapply(seq(runs_pls_elevsq_cv), function(k){
    #zeilen, in denen prdct_elev_resp den richtigen run stehen hat. bei obs dann die gleiche plotUnq
    R2 <- caret::R2(prdct_elev_resp[which(prdct_elev_resp$runs == k),resp], 
                    obs_SRresp[c(which(obs_SRresp$plotUnq %in% prdct_elev_resp[which(prdct_elev_resp$runs == k), 
                                                                               "plotUnq"])),resp], na.rm = T)
    RMSE <- caret::RMSE(prdct_elev_resp[which(prdct_elev_resp$runs == k),resp], 
                        obs_SRresp[c(which(obs_SRresp$plotUnq %in% prdct_elev_resp[which(prdct_elev_resp$runs == k), 
                                                                                   "plotUnq"])),resp], na.rm = T)
    RMSE_sd <- RMSE / sd_resp_SR
    return(list(resp_run = k, RMSE_sd = RMSE_sd, RMSE = RMSE, R2 = R2))
  })
  
  stats_pls_elevsq_cv <- data.frame(do.call("rbind", stats_pls_elevsq_cv))
  stats_pls_elevsq_cv$type <- "SR_onlyelevsq"
 
  ###mrg stats
  mrg <- (rbind(stats_res, stats_pls, stats_pls_elevsq_cv, stats_elevsq_resid_sum))
  mrg$RMSE_sd <- as.numeric(mrg$RMSE_sd)
  mrg$RMSE <- as.numeric(mrg$RMSE)
  mrg$R2 <- as.numeric(mrg$R2)
  mrg$resp <- resp
  
  return(mrg)
  }
})
  
stats_all <- do.call("rbind", stats_all_lst)
stats_all$resp_run <- gsub("_([0-9]+)", "\\1",  stats_all$resp_run)
stats_all$run <- as.numeric(gsub(".*?([0-9]+).*", "\\1",  stats_all$resp_run))


for (x in seq(nrow(stats_all))){
  trop <- NA
  for (i in trophic_tbl$Taxon){
    match <- grep(i, stats_all[x,"resp"], value=TRUE)
    if (length(match) != 0){
      trop <- trophic_tbl$diet[trophic_tbl$Taxon == i]
    }
    #print(trop)
  }
  stats_all$troph[x] <- as.character(trop)
}


for (i in seq(nrow(stats_all))){
  if (grepl("sum", stats_all$resp[i]) == T){
    stats_all$troph_sep[i] <- paste0(stats_all$troph[i], "_sum")
  }else{
    stats_all$troph_sep[i] <- stats_all$troph[i]
  }
}

stats_all$troph <- factor(stats_all$troph, levels = c("generalist", 
                                                      "predator", 
                                                      "herbivore", 
                                                      "decomposer", 
                                                      "plant", 
                                                      "birds", 
                                                      "bats", 
                                                      "summary", 
                                                      "trait"))

stats_all$troph_sep <- factor(stats_all$troph_sep, levels = c("generalist", "generalist_sum", 
                                              "predator", "predator_sum", 
                                              "herbivore", "herbivore_sum", 
                                              "decomposer", "decomposer_sum", 
                                              "plant", "plant_sum", 
                                              "birds", "birds_sum", 
                                              "bats", "bats_sum", 
                                              "summary", "summary_sum", 
                                              "trait", "trait_sum"))
stats_all <- stats_all[with(stats_all, order(troph_sep, resp)),] ####sortierung nach alphabet resp ist nicht sooo optimal, weil resids lfter zusammenstehen und nicht abwechselnd reisid und das entsprechende SR- eventuell "resid" hinten an namen dranschreiben
stats_all$resp <- factor(stats_all$resp, levels = unique(stats_all$resp))

mean_df_R2 <- aggregate(stats_all$R2, by = list(stats_all$resp, stats_all$type), FUN = mean, na.rm = T)
colnames(mean_df_R2) <- c("resp", "type", "mean_R2")
mean_df_RMSE <- aggregate(stats_all$RMSE, by = list(stats_all$resp, stats_all$type), FUN = mean, na.rm = T)
colnames(mean_df_RMSE) <- c("resp", "type", "mean_RMSE")
mean_df_RMSE_sd <- aggregate(stats_all$RMSE_sd, by = list(stats_all$resp, stats_all$type), FUN = mean, na.rm = T)
colnames(mean_df_RMSE_sd) <- c("resp", "type", "mean_RMSE_sd")

mean_df <- merge(mean_df_R2, mean_df_RMSE, by = c("resp", "type"))
mean_df <- merge(mean_df, mean_df_RMSE_sd, by = c("resp", "type"))

stats_all <- merge(stats_all, mean_df, by = c("resp", "type"))

saveRDS(stats_all, file = paste0(outpath, "stats_all.rds"))
write.csv(stats_all, file = paste0(outpath, "stats_all.csv"))

myColors <- c("mediumslateblue", "blue2", "aquamarine3", "chocolate1", 
              "firebrick1", "darkmagenta")
fillscl <- scale_fill_manual(name = "col",values = myColors)


# #pdf(file = paste0(outpath, "all_stats.pdf"), height= 10, width = 20)#, paper = "a4r")
# print(ggplot(data = stats_all, aes(x=resp, y=RMSE_sd)) + 
#         geom_boxplot(aes(fill=type), width = 1) + 
#   theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) + 
#   fillscl + 
#     ggtitle(title))
# #dev.off()
# 
# print(ggplot(data = stats_all, aes(x=resp, y=RMSE)) + 
#         geom_boxplot(aes(fill=type), width = 1) + 
#         theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) + 
#         fillscl + 
#         ggtitle(title))


pdf(file = paste0(outpath, "all_stats.pdf"), height= 10, width = 20)#, paper = "a4r")
print(ggplot(data = stats_all, aes(x=resp, y=RMSE_sd)) + 
        #geom_rect(fill=grey_pal()(length(levels(stats_all$troph_sep))+5)[as.numeric(stats_all$troph_sep)+5], 
                  #xmin = -Inf,xmax = Inf, ymin = -Inf,ymax = Inf) +
        geom_boxplot(aes(fill=type), width = 1) + 
        facet_grid(~troph_sep, scales = "free_x", space="free_x", switch = "x") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) + 
        fillscl + 
        ggtitle(paste0(set, "_", sub)))
dev.off()

###plot only summaries
stats_sum <- stats_all[grepl("sum", stats_all$troph_sep),]

pdf(file = paste0(outpath, "stats_sum.pdf"), height= 10, width = 20)#, paper = "a4r")
print(ggplot(data = stats_sum, aes(x=resp, y=RMSE_sd)) + 
        #geom_rect(fill=grey_pal()(length(levels(stats_all$troph_sep))+5)[as.numeric(stats_all$troph_sep)+5], 
        #xmin = -Inf,xmax = Inf, ymin = -Inf,ymax = Inf) +
        geom_boxplot(aes(fill=type), width = 1) + 
        facet_grid(~troph_sep, scales = "free_x", space="free_x", switch = "x") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) + 
        fillscl + 
        ggtitle(paste0(set, "_", sub)))
dev.off()

#   #pdf(file = paste0(path_nofrst, "stats_", resp, ".pdf"))
#   ##plot RMSE
#   print(ggplot(data = stats_all, aes(x=type, y=RMSE_sd)) +
#     geom_boxplot() +
#     ggtitle(resp))
# 
#   #v <- lm(pls_residresp[,paste0("resid", resp, "_run1")] ~ obs_residresp[,paste0("resid", resp)])
#   #plot(v)
# 
# 
#   #plot RMSE normiert auf sd f�r alle au�er Residuen
#   print(ggplot(data = mrg_RMSE_sd[which(mrg_RMSE_sd$type != "res"),], aes(x=type, y=RMSE_sd)) +
#     geom_boxplot()+
#     ggtitle(resp))
#   #dev.off()
# 
#   ##plot R2 aller vorhersagen aller runs: nur in forest/non-forest
#   runs <- c(paste0(resp, "_run1"), paste0(resp, "_run2"), paste0(resp, "_run3"),
#             paste0(resp, "_run4"), paste0(resp, "_run5"))
#   pls_all_mrg_df <- pls_SRresp_all[,which(colnames(pls_SRresp_all) == "plotUnq") :
#                                       which(colnames(pls_SRresp_all) == runs[1])]
#   colnames(pls_all_mrg_df)[3] <- "predicted"
# 
#   for (i in seq(2,length(runs))){
#     colnames(pls_SRresp_all)[2+i] <- "predicted"
#     pls_all_mrg_df <- rbind(pls_all_mrg_df, pls_SRresp_all[,c((which(colnames(pls_SRresp_all) == "plotUnq") :
#                                                                   which(colnames(pls_SRresp_all) == "plotID")), (2+i))])
#   }
#   pls_obs_df <- merge(pls_all_mrg_df, obs_SRresp, by = "plotUnq")
#   pls_obs_df <- pls_obs_df[which(complete.cases(pls_obs_df$predicted)),]
# 
#   ###statistische Ma�e �ber alle runs innerhalb von forest oder non-forest
#   stats_pls_all <- as.data.frame(t(postResample(pls_obs_df$predicted, pls_obs_df[,resp])))
#   RMSE_sd <- stats_pls_all[["RMSE"]] / sd_resp_SR
# 
# 
# }
# 
