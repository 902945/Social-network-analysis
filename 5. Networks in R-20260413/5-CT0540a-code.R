# R code snippets from slides
# Slide file: CT0540 Networks in R/4-CT0540a


# A Basic Graph
# ==========
library(igraph)
g <- graph.empty(directed=TRUE)


# A Basic Graph
# ==========
g <- g + vertex("Elizabeth II") 
g <- g + vertex("Philip")
g <- g + vertex("Charles")
g <- g + vertex("Diana")
g <- g + vertex("William")
g <- g + vertex("Harry")
g <- g + vertex("Catherine")
g <- g + vertex("George")


# A Basic Graph
# ==========
g <- g + edges("Elizabeth II", "Charles")
g <- g + edges("Philip", "Charles")
g <- g + edges("Charles", "William")
g <- g + edges("Diana", "William")
g <- g + edges("Charles", "Harry")
g <- g + edges("Diana", "Harry")
g <- g + edges("William", "George")
g <- g + edges("Catherine", "George")


# A Basic Graph
# ==========
g


# Edge, vertex, and network attributes
# ==========
g


# Edge, vertex, and network attributes
# ==========
g


# A Basic Graph
# ==========
plot.igraph(g)


# Create Networks
# ==========
g1 <- graph( edges=c(1,2, 2,3, 3,1), n=3, directed=F); plot(g1)


# Create Networks
# ==========
g2 <- graph( edges=c(1,2, 2,3, 3,1), n=10)
plot(g2) 


# Create Networks
# ==========
g1
g2


# Create Networks
# ==========
g3 <- graph( c("John", "Jim", "Jim", "Jill", "Jill", "John")) # named vertices
plot(g3) 


# Create Networks
# ==========
g3

g4 <- graph( c("John", "Jim", "Jim", "Jack", "John", "John"), 
             isolates=c("Jesse", "Janis", "Jennifer", "Justin")
            ) 


# Create Networks
# ==========
plot(g4, edge.arrow.size=.5, vertex.color="gold", vertex.size=15, vertex.frame.color="gray", vertex.label.color="black", vertex.label.cex=0.8, vertex.label.dist=2, edge.curved=0.2)


# Create Networks
# ==========
plot(graph_from_literal(a---b, b---c)) # the number of dashes doesn't matter


# Create Networks
# ==========
plot(graph_from_literal(a--+b, b+--c))


# Create Networks
# ==========
plot(graph_from_literal(a+-+b, b+-+c)) 


# Create Networks
# ==========
plot(graph_from_literal(a:b:c---c:d:e))


# Create Networks
# ==========
gl <- graph_from_literal(a-b-c-d-e-f, a-g-h-b, h-e:f:i, j)
plot(gl)


# Edge, vertex, and network attributes
# ==========
plot(g4, edge.arrow.size=.5, vertex.color="gold", vertex.size=15, vertex.frame.color="gray", vertex.label.color="black", vertex.label.cex=0.8, vertex.label.dist=2, edge.curved=0.2)


# Edge, vertex, and network attributes
# ==========
E(g4) # Edges of the object
V(g4) # Vertices of the object


# Edge, vertex, and network attributes
# ==========
g4[]


# Edge, vertex, and network attributes
# ==========
V(g4)$name # automatically generated when we created the network.


# Edge, vertex, and network attributes
# ==========
V(g4)$gender <- c("male", "male", "male", "male", "female", "female", "male")

E(g4)$type <- "email" # Edge attribute, assign "email" to all edges

E(g4)$weight <- 10    # Edge weight, setting all existing edges to 10


# Edge, vertex, and network attributes
# ==========
edge_attr(g4)


# Edge, vertex, and network attributes
# ==========
vertex_attr(g4)


# Edge, vertex, and network attributes
# ==========
g4 <- set_graph_attr(g4, "name", "Email Network")
graph_attr_names(g4)
g4 <- set_graph_attr(g4, "company", "Microsoft")
graph_attr_names(g4)


# Edge, vertex, and network attributes
# ==========
graph_attr(g4, "name")
graph_attr(g4)


# Edge, vertex, and network attributes
# ==========
g4 <- delete_graph_attr(g4, "company")
graph_attr(g4)


# Edge, vertex, and network attributes
# ==========
plot(g4, edge.arrow.size=.5, vertex.label.color="black", vertex.label.dist=1.5, vertex.color=c( "pink", "skyblue")[1+(V(g4)$gender=="male")])


# Edge, vertex, and network attributes
# ==========
g4s <- simplify( g4, remove.loops = T, 
                edge.attr.comb=c(weight="sum", type="ignore") )
plot(g4s, vertex.label.dist=1.5)


# Specific graphs
# ==========
eg <- make_empty_graph(40)
plot(eg, vertex.size=10, vertex.label=NA)


# Specific graphs
# ==========
fg <- make_full_graph(40)
plot(fg, vertex.size=10, vertex.label=NA)


# Specific graphs and graph models
# ==========
tr <- make_tree(40, children = 3, mode = "undirected")
plot(tr, vertex.size=10, vertex.label=NA) 


# Specific graphs and graph models
# ==========
st <- make_star(40)
plot(st, vertex.size=10, vertex.label=NA) 


# Specific graphs
# ==========
rn <- make_ring(40)
plot(rn, vertex.size=10, vertex.label=NA)


# Specific graphs
# ==========
zach <- graph("Zachary") # the Zachary Karate Club
plot(zach, vertex.size=10, vertex.label=NA)


# Diameter
# ==========
diameter(zach, directed=F)
diam <- get_diameter(zach, directed=F)
diam


# Diameter
# ==========
vcol <- rep("gray40", vcount(zach))
vcol[diam] <- "gold"
ecol <- rep("gray80", ecount(zach))
ecol[E(zach, path=diam)] <- "orange"
plot(zach, vertex.color=vcol, edge.color=ecol, edge.arrow.mode=0)


# Node degree
# ==========
deg <- degree(zach, mode="all")
plot(zach, vertex.size=deg)


# Node degree
# ==========
deg <- degree(zach, mode="all")
plot(zach, vertex.size=deg*2)


# Node degree
# ==========
hist(deg, breaks=1:vcount(zach)-1, main="Histogram of node degree")


# Degree distribution
# ==========
deg.dist <- degree_distribution(zach, cumulative=T, mode="all")
plot( x=0:max(deg), y=1-deg.dist, pch=19, cex=1.2, col="orange", xlab="Degree", ylab="Cumulative Frequency")


# Distances and paths
# ==========
mean_distance(zach, directed=F)


# Distances and paths
# ==========
distances(zach)


# Reading network data from files: edge list
# ==========
nodes <- read.csv("Dataset1-Media-Example-NODES.csv", header=T, as.is=T)
links <- read.csv("Dataset1-Media-Example-EDGES.csv", header=T, as.is=T)


# Examine the data
# ==========
head(nodes)
head(links)


# Examine the data
# ==========
nrow(nodes);# OR length(unique(nodes$id))
nrow(links);# OR nrow(unique(links[,c("from", "to")]))


# Weighted Networks
# ==========
links <- aggregate(links[,3], by=links[,-3], sum) #3rd col = weight
links <- links[order(links$from, links$to),]
colnames(links)[4] <- "weight"
rownames(links) <- NULL



# Turning networks into igraph objects
# ==========
net <- graph_from_data_frame(d=links, vertices=nodes, directed=T) 
class(net)
net 


# Turning networks into igraph objects
# ==========
E(net)
V(net)


# Turning networks into igraph objects
# ==========
E(net)$type
V(net)$media


# Turning networks into igraph objects
# ==========
plot(net, edge.arrow.size=.4,vertex.label=NA)


# Turning networks into igraph objects
# ==========
# Removing loops from the graph:
net <- simplify(net, remove.multiple = F, remove.loops = T) 

# If you need them, you can extract an edge list 
as_edgelist(net, names=T)


# Turning networks into igraph objects
# ==========
#or a matrix from igraph networks.
as_adjacency_matrix(net, attr="weight")




# Turning networks into igraph objects
# ==========
# Or data frames describing nodes and edges:
as_data_frame(net, what="edges")
as_data_frame(net, what="vertices")


# Turning networks into igraph objects
# ==========
library(igraph)
plot(degree.distribution(net))


# Distances and Paths
# ==========
dist.from.NYT <- distances(net, v=V(net)[media=="NY Times"], to=V(net), weights=NA)
# Set colors to plot the distances:
oranges <- colorRampPalette(c("dark red", "gold"))
col <- oranges(max(dist.from.NYT)+1)
col <- col[dist.from.NYT+1]

plot(net, vertex.color=col, vertex.label=dist.from.NYT, edge.arrow.size=.6, 
     vertex.label.color="white")


# Distances and Paths
# ==========
news.path <- shortest_paths(net, from = V(net)[media=="MSNBC"], 
                                  to  = V(net)[media=="New York Post"], 
                                  output = "both") # both path nodes and edges
# Generate edge color variable to plot the path:
ecol <- rep("gray80", ecount(net))
ecol[unlist(news.path$epath)] <- "orange"
# Generate edge width variable to plot the path:
ew <- rep(2, ecount(net))
ew[unlist(news.path$epath)] <- 4
# Generate node color variable to plot the path:
vcol <- rep("gray40", vcount(net))
vcol[unlist(news.path$vpath)] <- "gold"
plot(net, vertex.color=vcol, edge.color=ecol, 
     edge.width=ew, edge.arrow.mode=0)


# Distances and Paths
# ==========
inc.edges <- incident(net, V(net)[media=="Wall Street Journal"], mode="all")

# Set colors to plot the selected edges.
ecol <- rep("gray80", ecount(net))
ecol[inc.edges] <- "orange"
vcol <- rep("grey40", vcount(net))
vcol[V(net)$media=="Wall Street Journal"] <- "gold"
plot(net, vertex.color=vcol, edge.color=ecol)


# Distances and Paths
# ==========
neigh.nodes <- neighbors(net, V(net)[media=="Wall Street Journal"], mode="out")
# Set colors to plot the neighbors:
vcol[neigh.nodes] <- "#ff9d00"
plot(net, vertex.color=vcol)


# Distances and Paths
# ==========
# For example, select edges from newspapers to online sources:
E(net)[ V(net)[type.label=="Newspaper"] %->% V(net)[type.label=="Online"] ]


# Distances and Paths
# ==========
cocitation(net)


# Density
# ==========
net <- graph_from_data_frame(d=links, vertices=nodes, directed=T) 
edge_density(net, loops=F)
ecount(net)/(vcount(net)*(vcount(net)-1)) #for a directed network


# Reciprocity
# ==========
reciprocity(net)
dyad_census(net) # Mutual, asymmetric, and null pairs
2*dyad_census(net)$mut/ecount(net) # Calculating reciprocity


# Clustering Coefficient (or Transitivity)
# ==========
transitivity(net, type="global")  # net is treated as an undirected network
transitivity(as.undirected(net, mode="collapse")) # same as above
transitivity(net, type="local")


# Triad Types
# ==========
# 003  A, B, C, empty graph
# 012  A->B, C 
# 102  A<->B, C  
# 021D A<-B->C 
# 021U A->B<-C 
# 021C A->B->C
# 111D A<->B<-C
# 111U A<->B->C
# 030T A->B<-C, A->C
# 030C A<-B<-C, A->C.
# 201  A<->B<->C.
# 120D A<-B->C, A<->C.
# 120U A->B<-C, A<->C.
# 120C A->B->C, A<->C.
# 210  A->B<->C, A<->C.
# 300  A<->B<->C, A<->C, complete graph

triad_census(net) # for directed networks
length(triad_census(net))


# Centrality & Centralization
# ==========
degree(net, mode="in")
centr_degree(net, mode="in", normalized=T)


# Closeness
# ==========
closeness(net, mode="all", weights=NA) 
centr_clo(net, mode="all", normalized=T)


# Betweenness
# ==========
betweenness(net, directed=T, weights=NA)
edge_betweenness(net, directed=T, weights=NA)


# Betweenness
# ==========
centr_betw(net, directed=T, normalized=T)


# Hubs and authorities
# ==========
hs <- hub_score(net, weights=NA)$vector
as <- authority_score(net, weights=NA)$vector

par(mfrow=c(1,2))
 plot(net, vertex.size=hs*50, main="Hubs")
 plot(net, vertex.size=as*30, main="Authorities")

