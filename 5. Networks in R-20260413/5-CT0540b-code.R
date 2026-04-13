# R code snippets from slides
# Slide file: CT0540 Networks in R/4-CT0540b


# Reading network data from files: matrix
# ==========
#Reading data
nodes2 <- read.csv("Dataset2-Media-User-Example-NODES.csv", header=T, as.is=T)
links2 <- read.csv("Dataset2-Media-User-Example-EDGES.csv", header=T, row.names=1)


# Reading network data from files
# ==========
# Examine the data:
head(nodes2)
head(links2)


# Bipartite: adjacency matrix for a two-mode network
# ==========
links2 <- as.matrix(links2)
str(links2)
str(nodes2)


# Turning networks into igraph objects
# ==========
library(igraph)
net2 <- graph_from_incidence_matrix(links2)
net2


# Turning networks into igraph objects
# ==========
table(V(net2)$type)


# Bipartite Networks
# ==========
plot(net2,vertex.label=NA)


# Bipartite Networks
# ==========
net2.bp <- bipartite.projection(net2)


# Plotting Bipartite Networks
# ==========
plot(net2.bp$proj1, vertex.label.color="black", vertex.label.dist=1,
     vertex.label=nodes2$media[!is.na(nodes2$media.type)])


# Plotting Bipartite Networks
# ==========
V(net2)$color <- c("steel blue", "orange")[V(net2)$type+1]
V(net2)$shape <- c("square", "circle")[V(net2)$type+1]
V(net2)$label <- ""
V(net2)$label[V(net2)$type==F] <- nodes2$media[V(net2)$type==F] 
V(net2)$label.cex=.6
V(net2)$label.font=2
plot(net2, vertex.label.color="white", vertex.size=(2-V(net2)$type)*8) 


# Plotting Bipartite Networks
# ==========
plot(net2, vertex.label=NA, vertex.size=7, layout=layout_as_bipartite) 


# Plotting Bipartite Networks
# ==========
par(mar=c(0,0,0,0))
plot(net2, vertex.shape="none", vertex.label=nodes2$media,
     vertex.label.color=V(net2)$color, vertex.label.font=2, 
     vertex.label.cex=.95, edge.color="gray70",  edge.width=2)


# Plotting in igraph  
# ==========
library(igraph) 
nodes <- read.csv("Dataset1-Media-Example-NODES.csv", header=T, as.is=T)
links <- read.csv("Dataset1-Media-Example-EDGES.csv", header=T, as.is=T)
net <- graph_from_data_frame(d=links, vertices=nodes, directed=T) 
plot(net, edge.arrow.size=.4, edge.curved=.1)


# Plotting in igraph  
# ==========
plot(net, edge.arrow.size=.2, edge.curved=0,
     vertex.color="orange", vertex.frame.color="#555555",
     vertex.label=V(net)$media, vertex.label.color="black",
     vertex.label.cex=.7) 


# Plotting in igraph  
# ==========
colrs <- c("gray50", "tomato", "gold")
V(net)$color <- colrs[V(net)$media.type]
plot(net) 


# Plotting in igraph  
# ==========
V(net)$size <- V(net)$audience.size*0.7
plot(net) 


# Plotting in igraph  
# ==========
V(net)$label.color <- "black"
V(net)$label <- NA
plot(net) 


# Plotting in igraph  
# ==========
E(net)$width <- E(net)$weight/6
plot(net)


# Plotting in igraph  
# ==========
E(net)$arrow.size <- .2
E(net)$edge.color <- "gray80"
plot(net)


# Plotting in igraph  
# ==========
plot(net, edge.color="orange", vertex.color="gray50") 


# Plotting in igraph  
# ==========
plot(net) 
legend(x=-1.1, y=-1.1, c("Newspaper","Television", "Online News"), pch=21,
       col="#777777", pt.bg=colrs, pt.cex=2.5, bty="n", ncol=1)


# Plotting in igraph  
# ==========
plot(net, vertex.shape="none", vertex.label=V(net)$media, 
     vertex.label.font=2, vertex.label.color="gray40",
     vertex.label.cex=.7, edge.color="gray85")


# Plotting in igraph  
# ==========
edge.start <- ends(net, es=E(net), names=F)[,1] #get the starting node for each edge
edge.col <- V(net)$color[edge.start]
my_layout = layout.fruchterman.reingold(net)
plot(net, edge.color=edge.col, edge.curved=.1, layout = my_layout)


# Layouts
# ==========
net.bg <- sample_pa(80) #BA-model is a very simple stochastic algorithm for building a graph
V(net.bg)$size <- 8
V(net.bg)$frame.color <- "white"
V(net.bg)$color <- "orange"
V(net.bg)$label <- "" 
E(net.bg)$arrow.mode <- 0
plot(net.bg)


# Layouts
# ==========
plot(net.bg, layout=layout_randomly)


# Layouts
# ==========
l <- layout_in_circle(net.bg)
plot(net.bg, layout=l)


# Layouts
# ==========
l <- layout_randomly(net.bg)
plot(net.bg, layout=l)


# Layouts
# ==========
l <- layout_on_sphere(net.bg)
plot(net.bg, layout=l)


# Layouts
# ==========
l <- layout_with_fr(net.bg)
plot(net.bg, layout=l)


# Layouts
# ==========
par(mfrow=c(2,2), mar=c(1,1,1,1))
plot(net.bg, layout=layout_with_fr)
plot(net.bg, layout=layout_with_fr)
plot(net.bg, layout=l)
plot(net.bg, layout=l)


# Layouts
# ==========
l <- layout_with_kk(net.bg)
plot(net.bg, layout=l)


# Layouts
# ==========
plot(net.bg, layout=layout_with_lgl)


# Improving Network Analysis
# ==========
plot(net)


# Improving Network Analysis
# ==========
mean(links$weight)
sd(links$weight)
hist(links$weight)


# Improving Network Analysis
# ==========
cut.off <- mean(links$weight) 
net.sp <- delete_edges(net, E(net)[weight<cut.off])
plot(net.sp) 


# Improving Network Analysis
# ==========
E(net)$width <- 2
plot(net, edge.color=c("dark red", "slategrey")[(E(net)$type=="hyperlink")+1],
      vertex.color="gray40", layout=layout_in_circle)


# Improving Network Analysis
# ==========
net.m <- net - E(net)[E(net)$type=="hyperlink"]
net.h <- net - E(net)[E(net)$type=="mention"]
par(mfrow=c(1,2))

plot(net.h, vertex.color="orange", main="Link: Hyperlink")
plot(net.m, vertex.color="lightsteelblue2", main="Link: Mention")


# Improving Network Analysis
# ==========
par(mfrow=c(1,2),mar=c(1,1,4,1))
l <- layout_with_fr(net)
plot(net.h, vertex.color="orange", layout=l, main="Tie: Hyperlink")
plot(net.m, vertex.color="lightsteelblue2", layout=l, main="Tie: Mention")


# Heatmaps
# ==========
# Heatmap of the network matrix:
netm <- get.adjacency(net, attr="weight", sparse=F)
colnames(netm) <- V(net)$media
rownames(netm) <- V(net)$media

palf <- colorRampPalette(c("gold", "dark orange")) 
heatmap(netm[,17:1], Rowv = NA, Colv = NA, col = palf(20), 
        scale="none", margins=c(10,10) )

