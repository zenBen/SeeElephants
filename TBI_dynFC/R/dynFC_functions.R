corr_rollme <- function(df, sbj, cnd, vrs, wnd, stp, method = "median")
{
  require(RcppRoll)
  if (length(sbj) > 1){
    s1 <- sbj[1]
    s2 <- sbj[2]
  }else{
    s1 <- s2 <- sbj
  }
  if (length(cnd) > 1){
    c1 <- cnd[1]
    c2 <- cnd[2]
  }else{
    c1 <- c2 <- cnd
  }
  if (length(vrs) > 1){
    v1 <- vrs[1]
    v2 <- vrs[2]
  }else{
    v1 <- v2 <- vrs
  }
  # select out two matched-length subset vectors
  dfa <- filter(df, Part == s1 & cond == c1) %>% select(v1) %>% unlist() %>% as.numeric
  dfb <- filter(df, Part == s2 & cond == c2) %>% select(v2) %>% unlist() %>% as.numeric
  # apply a requested roll method
  func <- paste0("roll_", method)
  dfa.roll <- do.call(func, list(dfa, n=wnd, by=stp))
  dfb.roll <- do.call(func, list(dfb, n=wnd, by=stp))
  # Check output has matched length & return
  if (length(dfa.roll) != length(dfb.roll)){
    print('A and B have different quantities of data!')
    return(NA)
  }
  retval <- list("corr" = cor(dfa.roll, dfb.roll), "count" = length(dfa.roll))
  return(retval)
}


corr_rollme_all <- function(df, condi, one_or_two_vars, wnd, stp, method = "median")
{
  sbjs <- unique(df$Part)
  match.pairs <- vector("numeric", length(sbjs))
  counts <- vector("numeric", length(sbjs))
  for (i in seq(1, length(sbjs))) {
    tmp <- corr_rollme(df, sbjs[i], condi, one_or_two_vars, wnd, stp, method)
    match.pairs[i] <- tmp$corr
    counts[i] <- tmp$count
  }
  if (all(diff(counts) == 0)) {
    counts <- counts[1]
  }else{
    print("Some pairs had different data quantities: is this right?")
    counts <- mean(counts)
  }
  return(list("corr" = match.pairs, "count" = counts))
}


upper2lower <- function(m) 
{
  m[lower.tri(m)] <- t(m)[lower.tri(m)]
  m
}


corr_rollme_all2all <- function(df, condi, one_or_two_vars, wnd, stp, method = "median", triangle = TRUE)
{
  sbjs <- unique(df$Part)
  mat.pairs <- matrix(nrow = length(sbjs), ncol = length(sbjs))
  counts <- vector("numeric", length(sbjs))
  for (a in seq(1, length(sbjs))) {
    for (b in seq(a, length(sbjs))) {
      tmp <- corr_rollme(df, c(sbjs[a], sbjs[b]), condi, one_or_two_vars, wnd, stp, method)
      mat.pairs[a, b] <- tmp$corr
    }
    counts[a] <- tmp$count
  }
  if (!triangle) {
    # Copy upper triangle to lower
    mat.pairs <- upper2lower(mat.pairs)
  }
  if (all(diff(counts) == 0)) {
    counts <- counts[1]
  }else{
    print("Some pairs had different data quantities: is this right?")
    counts <- mean(counts)
  }
  return(list("corr" = mat.pairs, "count" = counts))
}


sample_matrix <- function(idx, mtrx, repl = FALSE) 
{
  if (all(is.na(mtrx[lower.tri(mtrx)])))
  {
    mtrx <- upper2lower(mtrx)
  }
  sampix <- sample(idx, length(idx), repl)
  sampmat <- mtrx[, sampix]
  return(list("sampmat" = sampmat, "sampdiag" = diag(sampmat)))
}


sampmat_diag_stat <- function(FUN, idx, mtrx, repl = FALSE, ...) 
{
  samp <- sample_matrix(idx, mtrx, repl)
  sampstat <- FUN(samp$sampdiag, ...)
  return(sampstat)
}


plot_rwb_cormat <- function(mtrx)
{
  ggplot(data = melt(mtrx), aes(x=Var1, y=Var2, fill=value)) + 
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Pearson\nCorrelation") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 12, hjust = 1))+
    coord_fixed()
    # + xlab("") + ylab("")
}


pool_cocor_depgrp_nonol <- function(r.jk, r.hm, r.jh, r.jm, r.kh, r.km, n)
{
  # 
  ans <- list()
  for (i in seq(1, lengthr.jk))
  {
    cocor.dep.groups.nonoverlap(r.jk[i], r.hm[i], r.jh[i], r.jm[i], r.kh[i], r.km[i], n[i])
  }
}


ks_testNplot <- function(samples, names, plot_chk = TRUE)
{
  require(ggplot2)
  if (length(samples) > 1){
    s1 <- unlist(samples[1])
    s2 <- unlist(samples[2])
  }else{
    s1 <- s2 <- samples
  }
  if (length(names) > 1){
    n1 <- names[1]
    n2 <- names[2]
  }else{
    n1 <- n2 <- names
  }
  
  print(ks.test(s1, s2))

  if (!plot_chk) invisible()
  
  group <- c(rep(n1, length(s1)), rep(n2, length(s2)))
  dat <- data.frame(KSD = c(s1, s2), group = group)
  cdf1 <- ecdf(s1)
  cdf2 <- ecdf(s2) 
  
  minMax <- seq(min(s1, s2), max(s1, s2), length.out=length(s1)) 
  x0 <- minMax[which( abs(cdf1(minMax) - cdf2(minMax)) == max(abs(cdf1(minMax) - cdf2(minMax))) )] 
  y0 <- cdf1(x0) 
  y1 <- cdf2(x0) 
  
  ggplot(dat, aes(x = KSD, group = group, colour = group, linetype=group))+
    stat_ecdf(size=1) +
    xlab("dynFC") +
    ylab("Cumulative Distribution") +
    geom_segment(aes(x = x0[1], y = y0[1], xend = x0[1], yend = y1[1]),
                 linetype = "dashed", color = "red") +
    geom_point(aes(x = x0[1] , y= y0[1]), color="red", size=1) +
    geom_point(aes(x = x0[1] , y= y1[1]), color="red", size=1) +
    ggtitle(paste("K-S Test:", n1, "/", n2))
}