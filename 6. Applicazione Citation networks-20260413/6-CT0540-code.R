# R code snippets from slides
# Slide file: CT0540 Application: Citation Networks/5-CT0540


# Citation Networks
# ==========
allCounts <- as.matrix(read.csv("ac.csv", as.is=TRUE))
head(allCounts)


# Citation Networks
# ==========
library(igraph)
G <- graph.edgelist(allCounts, directed=FALSE)


# Citation Networks
# ==========
G


# Citation Networks
# ==========
themes <- read.csv("themes.csv", as.is=TRUE)
head(themes)


# Citation Networks
# ==========
matchingCases <- which(themes$issue %in% c(20040, 20050))
matchingCases_ids <- themes$usid[matchingCases]
H <- induced.subgraph(G, matchingCases_ids)
H


# Citation Networks
# ==========
plot.igraph(H)


# Citation Networks
# ==========
set.seed(1)
lout <- layout.fruchterman.reingold(H)


# Citation Networks
# ==========
head(lout)


# Citation Networks
# ==========
plot.igraph(H, layout=lout, vertex.size=5, vertex.label.cex=0.5)


# Citation Networks
# ==========
plot.igraph(H, layout=lout, vertex.size=5, vertex.label.cex=0.5)


# Citation Networks
# ==========
pdf("citation_graph.pdf",10,10)
  plot.igraph(H, layout=lout, vertex.size=10,
              vertex.label.cex=.5)
dev.off()


# Graph Centrality
# ==========
eigenCent <- evcent(H)$vector
sort(eigenCent,decreasing=TRUE)[1:10]


# Graph Centrality
# ==========
eigenCent <- evcent(H)$vector
sort(eigenCent,decreasing=TRUE)[1:10]


# Graph Centrality
# ==========
options(scipen=999)

# calculating 30 values (bins) using the quantile function
# in each bin there is the same number (frequency) of scores
bins <- unique(quantile(eigenCent, seq(0,1,length.out=30)))


# Graph Centrality
# ==========
bins


# Graph Centrality
# ==========
# cut identifies the corresponding bin for each score
vals <- cut(eigenCent, bins, labels=FALSE, include.lowest=TRUE)
length(vals); head(vals)
# heat.colors creates a vector of n contiguous colors
my_col = heat.colors(length(bins))
head(my_col)


# Graph Centrality
# ==========
# now we assign the heatest colors (more red) to the highest scores
colorVals <- rev(my_col)[vals] #sort of subsetting

V(H)$color <- colorVals


# Graph Centrality
# ==========
plot.igraph(H, vertex.label=NA, vertex.size=5)


# Graph Centrality
# ==========
plot.igraph(H, vertex.label=NA, vertex.size=5)


# Graph Centrality
# ==========
betweenCent <- betweenness(H)
sort(betweenCent,decreasing=TRUE)[1:10]
cor(betweenCent,eigenCent)


# Graph Centrality
# ==========
bins <- unique(quantile(betweenCent, seq(0,1,length.out=30)))
vals <- cut(betweenCent, bins, labels=FALSE, include.lowest=TRUE)
colorVals <- rev(heat.colors(length(bins)))[vals]
V(H)$color <- colorVals


# Graph Centrality
# ==========
plot.igraph(H, vertex.label=NA, vertex.size=5)


# Graph Communities
# ==========
w <- edge.betweenness.community(H)
sort(table(w$membership))


# Graph Communities
# ==========
sort(table(w$membership))


# Graph Communities
# ==========
V(H)$color <- rep("white", length(w$membership))
keepTheseCommunities <- names(sizes(w))[sizes(w) > 3]
matchIndex <- match(w$membership, keepTheseCommunities) # like %in%
colorVals <- rainbow(5)[matchIndex[!is.na(matchIndex)]]
V(H)$color[!is.na(matchIndex)] <- colorVals


# Graph Communities
# ==========
plot.igraph(H, vertex.label=NA, vertex.size=5)

