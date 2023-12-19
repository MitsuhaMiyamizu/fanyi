#' query gene information from NCBI
#' 
#' This function query gene information (including gene name, description and summary) from NCBI Gene database
#' @title gene_summary 
#' @rdname gene-summary
#' @param entrez entrez gene IDs
#' @return A data frame containing the information
#' @author Guangchuang Yu 
#' @export
gene_summary <- function(entrez) {
    gene_summary_ncbi(entrez)
}

#' @importFrom rentrez entrez_summary
gene_summary_ncbi <- function(entrez) {
    x <- rentrez::entrez_summary(db='gene', id=entrez)

    .extract_gene_summary(x)
}

.extract_gene_summary <- function(summary) {
    if (inherits(summary, "esummary")) {
        res <- as.data.frame(summary[c("uid", "name", "description", "summary")])
        return(res)
    } 

    # 'esummary_list' object

    res <- lapply(summary, function(item) {
        .extract_gene_summary(item)
    }) |> do.call(rbind, args = _)

    return(res)
}

#' convert gene symbol to entrez id
#' 
#' This function query gene symbols from NCBI Gene database and return corresponding entrez gene IDs
#' @title symbol2entrez
#' @rdname symbol2entrez
#' @param symbols gene symbols
#' @param organism correpsonding organism of the gene symbols
#' @return A data frame with SYMBOL and ENTREZ columns
#' @author Guangchuang Yu 
#' @export
#' @importFrom rentrez entrez_search
symbol2entrez <- function(symbols, organism = "Homo sapiens") {
    q <- sprintf("%s[Gene] AND %s[Organism]", symbols, organism)
    entrez <- vapply(q, function(query) {
        ret <- entrez_search(db='gene', term=query, retmax=1)
        return(ret$ids)
    }, FUN.VALUE = character(1))
    res <- data.frame(SYMBOL=symbols, ENTREZ=entrez)
    rownames(res) <- NULL
    return(res)
}

