
posts = read.csv("nyt_posts.csv")
posts = posts[, -(37:40)]
saveRDS(posts, "nyt_posts.rds")
dim(posts)
names(posts)[1:23]
names(posts)[24:36]

p = posts[posts$Likes>4 & posts$Comments>4 & posts$Shares>4,]
dim(p)
paste0((round(dim(p)[1]/dim(posts)[1],2))*100, "%")

head(p$URL)
library(stringr)
p$post_id =str_sub(p$URL, 43, 60)
head(p$post_id)

table(p$Type)

# Take posts of type Link
p_link = p[p$Type=="Link",] #6,499
df_link = data.frame(postid = p_link$post_id, link=p_link$Link)

# Take all other posts
p_other = p[!(p$post_id %in% df_link$postid),] #810

# Select only posts having a message -- i.e., description
df_other = data.frame(postid = p_other$post_id, text=p_other$Message)
df_other = df_other[!(df_other$text==""),] #810

# How many posts have we selected? 
((nrow(df_link) + nrow(df_other)) / nrow(p) * 100) #100%

##############################
########## MESSAGES ##########
##############################

m = as.character(df_other$text)
y = which(unlist(lapply(m, function(x){grepl("COVID-19", x, ignore.case=T)})))
posts_covid_m = df_other[y,]
str(posts_covid_m)

###########################
########## LINKS ##########
###########################
# library(rvest)
# 
# posts_covid_l = data.frame(postid=as.character(), link=as.character(), text=as.character())
# links = df_link
# n = nrow(links)
# 
# for(i in 1499:n){
#   message(i)
#   id = links[i,]$postid
#   theurl = links[i,]$link 
#   temp = data.frame(postid = id, link = theurl, text = "")
#   
#   simple = try(read_html(theurl), silent=T)
#   
#   if(!(class(simple) == "try-error")){
#     text = simple %>% html_nodes("p") %>% html_text()
#     text = str_c(text, collapse = " ")
#   
#     if(grepl("COVID-19", text, ignore.case=T)){
#         message("Selected")
#         temp$text = text
#         posts_covid_l = rbind(posts_covid_l, temp) 
#     }
#   }
# }
# saveRDS(posts_covid_l, "posts_covid_l.rds")

posts_covid_l = readRDS("posts_covid_l.rds")
str(posts_covid_l)

postids_covid = c(posts_covid_m$postid, posts_covid_l$postid)
posts_covid_lm = merge(posts_covid_l, posts_covid_m, all=T)
str(posts_covid_lm)
posts_covid_lm = posts_covid_lm[, -3]
str(posts_covid_lm)

library(quanteda)
source("stopwords_extended.R")

corpus = corpus(posts_covid_lm, text_field = "text")
summary(corpus)

doc.tokens = tokens(corpus)
doc.tokens = tokens(doc.tokens, remove_punct = TRUE, remove_numbers = TRUE)
doc.tokens = tokens_select(doc.tokens, stopwords(language = "en", source = "snowball", simplify = TRUE), selection ='remove')
doc.tokens = tokens_select(doc.tokens, stopmore, selection ='remove')
doc.tokens = tokens_tolower(doc.tokens)
toks_ngram = tokens_ngrams(doc.tokens, n = 1:2)

# Construct a sparse document-feature matrix
dfmat1 = dfm(toks_ngram) %>% dfm_trim(min_termfreq = 10)
dfmat1

library(quanteda.textstats)
features_dfm = textstat_frequency(dfmat1, n = 100)
features_dfm$feature = with(features_dfm, reorder(feature, -frequency))
features_dfm

library(ggplot2)
ggplot(features_dfm, aes(x = feature, y = frequency)) +
  geom_point() + 
  theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1))

library(quanteda.textplots)
textplot_wordcloud(dfmat1)

#The kwic function (keywords-in-context) 
# performs a search for a word and allows us 
# to view the contexts in which it occurs:
set.seed(10)
s = sample(tokens(doc.tokens), 20)

png("lexical_dispersion.png", width = 2000, height = 1000, res=200)
kwic(s, pattern = "school") %>%textplot_xray()
dev.off()


library(stm)
topic.count = 10
dfm2stm = convert(dfmat1, to = "stm")
model.stm = stm(dfm2stm$documents, dfm2stm$vocab, K = topic.count, data = dfm2stm$meta, init.type = "Spectral") 
# Structural Topic Model using semi-collapsed variational EM
# This is the main function for estimating a Structural Topic Model (STM). 
# Users provide a corpus of documents (N) and a number of topics. 
# Each word in a document comes from exactly one topic and each document is represented 
# by the proportion of its words that come from each of the K topics. 
# These proportions are found in the N by K theta matrix. 
# Each of the K topics are represented as distributions over words. 
# The K-by-V (number of words in the vocabulary) matrix logbeta contains the natural log of the probability
# of seeing each word conditional on the topic.
# The most important user input in parametric topic models is the number of topics. 
# There is no right answer to the appropriate number of topics. 
# More topics will give more fine-grained representations of the data at the potential cost 
# of being less precisely estimated. The number must be at least 2 which is equivalent to a unidimensional scaling model.
# For short corpora focused on very specific subject matter (such as survey experiments) 3-10 topics is a useful 
# starting range. For small corpora (a few hundred to a few thousand) 5-50 topics is a good place to start. 
# Beyond these rough guidelines it is application specific. 
# Previous applications in political science with medium sized corpora (10k to 100k documents) 
# have found 60-100 topics to work well. For larger corpora 100 topics is a useful default size. 

saveRDS(model.stm, "model-stmk=10.rds")
model.stm = readRDS("model-stmk=10.rds")

plot(model.stm, type = "summary", text.cex = 0.5)

mod.out.corr = topicCorr(model.stm) # Estimates a graph of topic correlations of an STM object
corMat_adj = mod.out.corr$posadj

library(igraph)
gg = graph_from_adjacency_matrix(corMat_adj)
gg = as.undirected(gg)
gg

cent = eigen_centrality(gg)
V(gg)$eig = (cent$vector - min(cent$vector ))/(max(cent$vector)- min(cent$vector))
V(gg)$names = 1:topic.count

cl1 = cluster_fast_greedy(gg)

library(ggraph)
ggraph(gg) + 
  geom_edge_link(width = 0.4, edge_colour = "grey") + 
  geom_node_point(color = membership(cl1),  size = exp(V(gg)$eig)) +
  geom_node_text(aes(label = paste0("Topic ", V(gg)$names )), repel = T) + theme_classic()



