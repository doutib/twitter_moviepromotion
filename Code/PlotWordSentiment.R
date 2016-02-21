setwd("~/Dropbox/School/Grad/ST222/twitter_moviepromotion")
acc = read.csv("../Data/AccuracyPerFeature.txt", header = FALSE)$V1
word_file = paste(readLines("../Data/vocab.txt"), collapse = " ")
words = (strsplit(word_file, split = " "))[[1]]

ord_acc = order(acc)

library(ggplot2)
library(grid)
library(gridExtra)
n = length(acc)
k = 20
p1 = ggplot() + 
  geom_bar(stat = 'identity', 
           aes(x = 1:k, y = acc[ord_acc[1:k]] - 0.5),
           fill = "indianred1",
           color = "white") + 
  geom_text(aes(x = 1:k, 
                y = acc[ord_acc[1:k]] - 0.5,
                label = words[ord_acc[1:k]]
                ), size = 5, angle = 45) + 
  ylab("Negativity of Words") + 
  xlab("Ranking of Negative Words")
p2 = ggplot() +   
  geom_bar(stat = 'identity',
           aes(x = 1:k, 
               y = acc[ord_acc[(5000-1):(5000-k)]] - 0.5), 
           fill = "royalblue1",
           color = "white") + 
  geom_text(aes(x = 1:k, 
                y = acc[ord_acc[(n-1):(n-k)]] - 0.5,
                label = words[ord_acc[(n-1):(n-k)]]
  ), angle = 45, size = 5) + 
  ylim(c(0,0.020)) + 
  ylab("Positivity of Words") + 
  xlab("Ranking of Positive Words")
p = grid.arrange(p2,p1)
ggsave("./Figures/WordSentiment.pdf", plot = p, width = 7, height = 5)
