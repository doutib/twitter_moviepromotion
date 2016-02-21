library(ggplot2)
library(corrplot)
library(stats)
library(vcd)
library(dplyr)
library(RColorBrewer)
par(bg=NA)
movie = read.csv("summary.csv")
# df = cbind(log(movie$num_tweet),log(movie$num_follower),movie$IMDB_rate,log(movie$num_review),log(movie$sales))
# num_tweets vs sales, col as IMDB_rate
cor.mtest <- function(mat, conf.level = 0.95) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat <- lowCI.mat <- uppCI.mat <- matrix(NA, n, n)
  diag(p.mat) <- 0
  diag(lowCI.mat) <- diag(uppCI.mat) <- 1
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], conf.level = conf.level)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
      lowCI.mat[i, j] <- lowCI.mat[j, i] <- tmp$conf.int[1]
      uppCI.mat[i, j] <- uppCI.mat[j, i] <- tmp$conf.int[2]
    }
  }
  return(list(p.mat, lowCI.mat, uppCI.mat))
}
res1 <- cor.mtest(movie[,3:7], 0.95)
colr = colorRampPalette(c("red", "white", "blue"),alpha=TRUE)( 200)
colr2 = brewer.pal(8,"RdBu")
corrplot(cor(movie[,3:7]), method="color",col=colr2, p.mat = res1[[1]], sig.level = 0.01,tl.col = "royalblue3",tl.srt = 40)

movie_sort = filter(movie,Distributor=="Walt Disney"|Distributor=="Paramount Pictures"|Distributor=="Sony Pictures"|Distributor=="20th Century Fox")
movie_sort2 = filter(movie_sort,Genre=="Horror"|Genre=="Drama"|Genre=="Comedy"|Genre=="Adventure")
mosaicplot(table(movie_sort2[,8],movie_sort2[,9]),shade=TRUE,color=TRUE)

colnames(movie)[3:7] = c("#tweets","#followers","#rate","#review","sales")
ggplot(movie,aes(x=log(num_tweet),y=log(sales)))+geom_point(aes(col=IMDB_rate)) +scale_colour_gradient(low="red",high="green",guide="colourbar") + geom_smooth(se=FALSE)
# num_followers vs sales, col as IMDB rate
ggplot(movie,aes(x=log(num_follower),y=log(sales)))+geom_point(aes(col=IMDB_rate)) +scale_colour_gradient(low="red",high="green",guide="colourbar") + geom_smooth(se=FALSE)
# num_tweets vs IMDB_rate
ggplot(movie,aes(x=log(num_tweet),y=IMDB_rate))+geom_point()+geom_smooth(se=FALSE)
# num_followers vs IMDB_rate
ggplot(movie,aes(x=log(num_follower),y=IMDB_rate))+geom_point()+geom_smooth(se=FALSE)

# num_followers vs sales, col as IMDB rate
ggplot(movie,aes(x=log(num_follower),y=log(sales),label=Movie))+ geom_jitter(colour="dodgerblue4",alpha=0.5)+geom_smooth(se=TRUE,colour="lightskyblue",fill="lightskyblue")+ 
  labs(x="number of followers (log)", y="Box office sales (log)",title = "Twitter Followers and Movie Sales") + 
  theme(panel.grid=element_blank(),plot.background = element_rect(fill = "lightsteelblue3", color = "black", size = 3),
  axis.title.x=element_text(face="italic",size=15,margin=margin(t=5)),axis.title.y=element_text(face="italic",size=15,margin=margin(r=5)),plot.title=element_text(face="italic",size=20,margin=margin(b=10)),
  panel.background=element_rect(fill="aliceblue"),plot.margin=margin(t=10,b=10,l=10,r=20))
#+ geom_text()
# num_review vs sales
ggplot(movie, aes(x=log(num_review),y=log(sales),label=Movie))+geom_jitter(colour="tan2")+geom_smooth(se=TRUE,colour="goldenrod2",fill="goldenrod1")+ 
  labs(x="number of reviews (log)", y="Box office sales (log)", title = "IMDB reviews and Movie Sales") +
  theme(panel.grid=element_blank(),plot.background = element_rect(fill = "navajowhite", color = "black", size = 3),
        axis.title.x=element_text(face="italic",size=15,margin=margin(t=5)),axis.title.y=element_text(face="italic",size=15,margin=margin(r=5)),plot.title=element_text(face="italic",size=20,margin=margin(b=10)),
        panel.background=element_rect(fill="oldlace"),plot.margin=margin(t=10,b=10,l=10,r=20))
#+geom_text()

#num_review vs rate
ggplot(movie,aes(y=log(IMDB_rate),x=log(num_review)))+geom_point()+geom_smooth()




#PCA & k-means
kmeans=read.csv("kmeans_plot.csv")
ggplot(kmeans,aes(x=pc1,y=pc2,col=factor(group)))+geom_point()+labs(x="Principle Component1", y="Principle Component2", title="K-means Clustering")+
  theme(panel.grid=element_blank(),plot.background = element_rect(fill = "gray79", color = "black", size = 3),
        axis.title.x=element_text(face="italic",size=15),axis.title.y=element_text(face="italic",size=15),plot.title=element_text(face="italic",size=20),
        panel.background=element_rect(fill="gray95"), legend.background=element_blank(),legend.position="top",legend.key=element_rect(colour="black"))
qplot(pc1,pc2,data=kmeans,colour=I("royalblue3"))+ggtitle("PCA")

group1 = filter(kmeans,group=="0")
center1 = c(mean(group1$pc1),mean(group1$pc2))
group2 = filter(kmeans,group=="1")
center2 = c(mean(group2$pc1),mean(group2$pc2))
group3 = filter(kmeans,group=="2")
center3 = c(mean(group3$pc1),mean(group3$pc2))
group4 = filter(kmeans,group=="3")
center4 = c(mean(group4$pc1),mean(group4$pc2))
df = rbind(center1,center2,center3,center4)

#sales
cols = rainbow(26, s=.6, v=.9)[sample(1:26,26)]
ggplot(kmeans,aes(x=pc1,y=pc2))+geom_point(aes(size=sale,col=factor(index)),show.legend = FALSE)+scale_colour_discrete(guide = FALSE)+ggtitle("PCA analysis with sales")

point = cbind(c(1,2,3,4,5),c(18.37701874, 13.62293341, 11.73962387, 10.45110293,9.58773965))
points = data.frame(point)
colnames(points) = c("category","cost_function")
ggplot(points,aes(x=category,y=cost_function))+geom_point(size=4,colour="lightslategrey")+geom_line(colour='steelblue1')+ggtitle("K-means Cost Function")
#point1 = data.frame(cbind(c(1:10),c(0.09916704,0.02811137,0.02515275,0.02021391,0.01991578,0.0186758, 0.01851372, 0.01767081,0.01670852,0.01602201)))
point1 = data.frame(cbind(c(10:1)),c(0.01602201,0.01670852,0.01767081,0.01851372,0.0186758,0.01991578,0.02021391,0.02515275,0.02811137,0.09916704))
point2 = data.frame(cbind(c(1:10),c(0.09916704,0.1272784 ,0.15243115,0.17264506,0.19256084,0.21123664,0.22975036,0.24742117,0.26412968,0.2801517)))
colnames(point1) = c("principle_components","variance_explained")
colnames(point2) = c("principle_components","variance_explained")
a =rbind(point1,point2)
b = cbind(a,group)

ggplot(b,aes(principle_components,variance_explained))+geom_point(size=3,col="dimgray")+geom_path(aes(colour=group),show.legend = FALSE)+ggtitle("Variance explained by principle components")

ggplot(point1,aes(principle_components,variance_explained))+geom_line(aes(color="First line"))
  geom_line(data=point2,aes(color="Second line"))
  labs(color="Legend text")
  

## Bar plot
  df1 = data.frame(c("2007","2009","2014","2015"),c(61,66,73,89))
  df = data.frame(c(rep("2007",61),rep("2009",66),rep("2014",73),rep("2015",89)),c(rep("2007",61),rep("2009",66),rep("2014",73),rep("2015",89)))
  names(df1) = c("year","accounts")
  colr3 = brewer.pal(4,"Blues")
  col4 <- c("cadetblue1","deepskyblue","dodgerblue","dodgerblue3")
  ggplot(df1,aes(x=year,y=accounts))+geom_bar(stat="identity",alpha=0.5,aes(fill=year))+labs(title="Number of Movie Official Twitter Accounts Over Time",x="year",y="count")+geom_text(aes(label=accounts),vjust=0)+
    theme(panel.background=element_blank(),legend.position="none",axis.line=element_line(colour="black")) +scale_fill_manual(values=col4)
