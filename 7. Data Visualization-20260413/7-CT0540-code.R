# R code snippets from slides
# Slide file: CT0540/Data Visualisation


# Let's start with an example:
# ==========
library(car)    # install.packages("car") if needed
data(Salaries)
str(Salaries)


# Let's start with an example:
# ==========
plot(Salaries$yrs.since.phd, Salaries$salary)


# Let's go back to the example:
# ==========
with(Salaries, cor(salary, yrs.since.phd))
with(Salaries, cor(salary, yrs.service))


# Let's go back to the example:
# ==========
with(Salaries, cor.test(salary, yrs.since.phd))


# Load the data
# ==========
library(ggplot2) 
str(mpg)


# Creating a ggplot
# ==========
require(ggplot2)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) # scatterplot


# Aesthetic mappings
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))


# Aesthetic mappings
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))


# Aesthetic mappings
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))


# Aesthetic mappings
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))


# Aesthetic mappings
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")


# Facets
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class)


# Geometric Objects
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))


# Geometric Objects
# ==========
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))


# Geometric Objects
# ==========
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))


# Geometric Objects
# ==========
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))


# Geometric Objects
# ==========
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))


# Geometric Objects
# ==========
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv))


# Geometric Objects
# ==========
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv, linetype = drv))


# Geometric Objects
# ==========
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))


# Geometric Objects
# ==========
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()


# Geometric Objects
# ==========
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()


# Statistical Transformations
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))


# Bar Charts
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))


# Bar Charts
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))


# Bar Charts
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))


# Position adjustments
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")


# Position adjustments
# ==========
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")


# Boxplots
# ==========
data(airquality)
airquality$Month <- factor(airquality$Month,
                           labels = c("May", "Jun", "Jul", "Aug", "Sep"))
head(airquality)


# Boxplots
# ==========
p = ggplot(airquality, aes(x = Month, y = Ozone)) +
        geom_boxplot()
p


# Boxplots
# ==========
p <- p + scale_x_discrete(name = "Month") +
        scale_y_continuous(name = "Mean ozone in parts per billion")
p


# Boxplots
# ==========
p = p + scale_y_continuous(name = "Mean ozone in\nparts per billion")
p


# Boxplots
# ==========
p = p + scale_y_continuous(name = "Mean ozone in\nparts per billion",
                              breaks = seq(0, 175, 25),
                              limits=c(0, 175))


# Boxplots
# ==========
p


# Boxplots
# ==========
p = p + ggtitle("Boxplot of mean ozone by month")
p


# Boxplots
# ==========
fill <- "gold1"
line <- "goldenrod2"

p <- ggplot(airquality, aes(x = Month, y = Ozone)) +
        geom_boxplot(fill = fill, colour = line) +
        scale_y_continuous(name = "Mean ozone in\nparts per billion",
                           breaks = seq(0, 175, 25),
                           limits=c(0, 175)) +
        scale_x_discrete(name = "Month") +
        ggtitle("Boxplot of mean ozone by month")

png("image.png")
p
dev.off()

# Boxplots
# ==========
p


# Boxplots
# ==========
p = p + theme_bw()
p

