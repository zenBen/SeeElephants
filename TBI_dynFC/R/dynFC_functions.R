corr_rollmed <- function(df, sbj, cnd, vrs, wnd, stp)
{
  require
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
  dfa <- filter(df, Part == s1 & cond == c1) %>% select(v1)
  dfb <- filter(df, Part == s2 & cond == c2) %>% select(v2)
  dfa.roll <- roll_median(as.numeric(unlist(dfa)), n=wnd, by=stp)
  dfb.roll <- roll_median(as.numeric(unlist(dfb)), n=wnd, by=stp)
  if (length(dfa.roll) != length(dfb.roll)){
    print('A and B have different quantities of data!')
    return(NA)
  }
  retval <- list("corr" = cor(dfa.roll, dfb.roll), "count" = length(dfa.roll))
  return(retval)
}


corr_rollmed_all <- function(df, condi, one_or_two_vars, wnd, stp)
{
  sbjs <- unique(df$Part)
  match.pairs <- vector("numeric", length(sbjs))
  counts <- vector("numeric", length(sbjs))
  for (i in seq(1, length(sbjs))) {
    tmp <- corr_rollmed(df, sbjs[i], condi, one_or_two_vars, wnd, stp)
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


corr_rollmed_all2all <- function(df, condi, one_or_two_vars, wnd, stp, triangle = TRUE)
{
  sbjs <- unique(df$Part)
  mat.pairs <- matrix(nrow = length(sbjs), ncol = length(sbjs))
  counts <- vector("numeric", length(sbjs))
  for (a in seq(1, length(sbjs))) {
    for (b in seq(a, length(sbjs))) {
      tmp <- corr_rollmed(df, c(sbjs[a], sbjs[b]), condi, one_or_two_vars, wnd, stp)
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
