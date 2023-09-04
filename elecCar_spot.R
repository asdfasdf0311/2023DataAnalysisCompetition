#install.packages("readxl")
library(readxl)
#EDA ������Ž��
#�����ͺҷ�����
dat <- read_excel("chargingspot.xlsx")
#�����͸��Ȯ��
head(dat)
tail(dat)
#������ ��跮 Ȯ��
summary(dat) 
#�ڷᱸ��,����ġ, �ڷ��� Ȯ��
str(dat)
#����ġ Ȯ��
is.na(dat)
sum(is.na(dat))


dat1 = dat[,-1]
dat1

#�õ��� ������ ���� H,L�� ������ ���� grp�����߰�
grp <- c()
for (i in 1:nrow(dat1)){  #dat1$������ ���� ���� �׷� �з�
  if (dat1$������[i] >= 259.3){#298.6�� mean ����, 220�� median ����
    #�߾Ӱ��� ����� �߰����� 259.3�̿�
    grp[i] <- "H"} else {grp[i] <- "L"}}


grp <-factor(grp)  #���ں��͸� ���� Ÿ������ ����
grp <- factor(grp, levels=c("H","L"))  #������ ������ H,L -> H,L

dat2 <- data.frame(dat1, grp)  #dat�� grp �÷� �߰�
#�߰��ȵ����� Ȯ��
str(dat2)
head(dat2)
table(dat2$grp)

#�� ���� �׷��� ��պ��Ͱ� ���̰� ������ �ȳ�����
groupH <- dat2[dat2$grp == "H", -14] # High
groupL <- dat2[dat2$grp == "L", -14] # Low

colMeans(groupH)
colMeans(groupL)

library(Hotelling)#mean vector
#�͹����� : �ΰ��� mean vector�� �����ϴ�
#p-value�� 0.05���� ������ �͹����� �Ⱒ

result <- hotelling.test(x = groupH, y = groupL)
result
#################
#�� �׷��� Covariance Matrix�� �������� �ƴ���
round(cov(groupH), 2) # High
round(cov(groupL), 2) # Low

library(heplots)

result <- boxM(cbind(���������,���б�,��ȭ�ü�,�Ƿ��������,����Ȱ���α�,
                     �α�, ��������) ~ grp, data = dat2)
result


#H, L �� �׷캰 ������ ���� Ȯ��
par(mfrow=c(2,2))
for(i in 1:13) {
  boxplot(dat2[,i]~dat2$grp,main=colnames(dat2)[i])
}


#######################
dat_cor <- round(cor(dat1),2)
dat_cor
#��Ʈ��
par(mfrow=c(1,1))
library(corrplot)
corrplot(dat_cor)
#�������·�
corrplot(dat_cor, method="number")



fit_pca <- princomp(dat1, cor = TRUE)
fit_pca$sdev^2
fit_pca$loadings
dat1
summary(fit_pca)
screeplot(fit_pca, npcs = 13, type = "lines", main = "scree plot")
biplot(fit_pca)

library(factoextra)
fviz_eig(fit_pca)

summary(fit_pca)
fviz_contrib(fit_pca, choice = "var", axes = 1) #PC1����޴°�
fviz_contrib(fit_pca, choice = "var", axes = 2) #PC2����޴°�
fviz_contrib(fit_pca, choice = "var", axes = 3) #PC3����޴°�
fviz_contrib(fit_pca, choice = "var", axes = 4) #PC4����޴°�


fviz_pca_var(fit_pca,
             col.var = "cos2", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

fviz_pca_biplot( fit_pca,
                 repel = TRUE,
                 geom = c("point"),
                 col.var = "#2E9FDF", # Variables color
                 col.ind = "#696969"  # Individuals color
)

#ȸ�ͺм�
dat1
model_1 = lm(������ ~ ��������� + ���б� + ��ȭ�ü� + �Ƿ�������� + 
               ����Ȱ���α� + �α� + �������� + ���̵� + �����Ƿ����� + 
               �������ѻ��� + ������� + ���κ���, data=dat1)
summary(model_1)

#������ ���������θ� ȸ�ͺм� �ٽ� ����
model_2 = lm(������ ~ ����Ȱ���α� + �α� + ���̵� + �����Ƿ�����,
             data=dat1)
summary(model_2)

#���� ���� ��, �� ���� ��
anova(model_1, model_2)

#������ ����� �߿䵵�� �ð�ȭ
relweights <- function(fit,...){
  R <- cor(fit$model)
  nvar <- ncol(R)
  rxx <- R[2:nvar, 2:nvar]
  rxy <- R[2:nvar, 1]
  svd <- eigen(rxx)
  evec <- svd$vectors
  ev <- svd$values
  delta <- diag(sqrt(ev))
  lambda <- evec %*% delta %*% t(evec)
  lambdasq <- lambda ^ 2
  beta <- solve(lambda) %*% rxy
  rsquare <- colSums(beta ^ 2)
  rawwgt <- lambdasq %*% beta ^ 2
  import <- (rawwgt / rsquare) * 100
  import <- as.data.frame(import)
  row.names(import) <- names(fit$model[2:nvar])
  names(import) <- "Weights"
  import <- import[order(import),1, drop=FALSE]
  dotchart(import$Weights, labels=row.names(import),
           xlab="% of R-Square", pch=19,
           main="Relative Importance of Predictor Variables",
           sub=paste("Total R-Square=", round(rsquare, digits=3)),
           ...)
  return(import)
}

pp1 = relweights(model_1, col="blue")
pp1
# ������
dataa <- c(0.8957698, 0.9911657, 1.4491809, 2.7209284, 2.8514528, 3.5512724, 10.0816763, 13.7223408, 13.8046443, 16.2418965, 16.3779688, 17.3117032)
labels <- c("���̵�", "�������ѻ���", "��ȭ�ü�", "��������", "�Ƿ��������", "�������", "���κ���", "�����Ƿ�����", "���б�", "�α�", "����Ȱ���α�", "���������")
# ���� �ȷ�Ʈ ����
colors <- rainbow(length(dataa))
# ���� ���
total <- sum(dataa)
# �ۼ�Ʈ ��� �� �� ����
percent <- round(dataa / total * 100, 2)
labels_with_percent <- paste(labels, percent, "%", sep = " ")
# �� �׷��� �׸���
pie(dataa, labels = labels_with_percent, col = colors)

pp = relweights(model_2, col="blue")
pp

# ������
dataa <- c(1.24919, 35.52300, 32.78764, 33.44017)
labels <- c("���̵�","�α�","����Ȱ���α�", "�����Ƿ�����")
# ���� �ȷ�Ʈ ����
colors <- rainbow(length(dataa))
# ���� ���
total <- sum(dataa)
# �ۼ�Ʈ ��� �� �� ����
percent <- round(dataa / total * 100, 2)
labels_with_percent <- paste(labels, percent, "%", sep = " ")
# �� �׷��� �׸���
pie(dataa, labels = labels_with_percent, col = colors)

#####������������
# ���� ����ȭ �Լ�
normalize <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# ���� ���� ��� �Լ�
calculate_rank <- function(data, weights) {
  normalized_data <- apply(data, 2, normalize)
  weighted_average <- normalized_data %*% weights
  rank <- rank(-weighted_average, ties.method = "min")
  return(rank)
}

# ������� ����ġ ����
variables <- c("����Ȱ���α�", "�α�", "���̵�", "�����Ƿ�����")
weights <- c(0.5967332, -0.0003018, -0.0298973, 7.0797779)
data <- dat1[,c("����Ȱ���α�","�α�", "���̵�", "�����Ƿ�����")]
data<-data.frame(data)
data

# ���� ���� ���
rank <- calculate_rank(data, weights)

# ��� ���
result <- data.frame("��������(�õ�)" = row.names(data), "��������" = rank)
print(result)