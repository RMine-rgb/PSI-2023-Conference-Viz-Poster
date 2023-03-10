# Source code: https://vis-sig.github.io/blog/posts/2021-07-18-wonderful-wednesdays-july-2021/
# Example 1. Item response distribution plot
library(tidyverse)
library(mirt)
library(ggpubr)

library(forcats)
library(psych)
library(polycor)
library(GPArotation)
library(xtable)
library(lavaan)
library(lavaanPlot)

library(WrightMap)
library(data.table)
library(ggcorrplot)
library(lme4)
library(Matrix)
library(stringr)
library(hrbrthemes)
library(viridis)
library(gmodels)
library(pander)
library(rtf)
library(difR)



#Clear environment
rm(list=ls())

#Colour scheme
Turquoise100 <- "#00a3e0"
  Turquoise75 <- "#40bae8"
    Turquoise50 <- "#7fd1ef"
      Turquoise25 <- "#bfe8f7"
        Blue100 <- "#005587"
          Blue50 <- "#7FAAC3"
            Green100 <- "#43b02a"
              Green50 <- "#a1d794"
                Purple100 <-"#830065"
                  Purple50 <- "#c17fb2"

                  Names <- c(
                    'Dry Cough',
                    'Loss of Smell',
                    'Skin Rash',
                    'Fever',
                    'Headache',
                    'Short of Breath',
                    'Diarrhoea',
                    'Sore Throat',
                    'Fatigue',
                    'Runny Nose',
                    'Ocular Issues',
                    'Loss of Taste')



                  #Set data and results areas up
                  # sourcedata <- "C:/Users/q1062810/OneDrive - IQVIA/Wonderful Wednesday/Psychometrics/"

                  dat <-read.csv("data-raw/PSI_WW_psychometric.csv")

                  ### Make dataset for each timepoint ====
                  dat_t1 <- dat %>%
                    select(c(ends_with("T1"))) %>%
                    select(-c(starts_with("PGIC")))

                  colnames(dat_t1) <- Names

                  dat_t2 <- dat %>%
                    select(c(ends_with("T2"))) %>%
                    select(-c(starts_with("PGIC")))

                  colnames(dat_t2) <- Names

                  dat_t3 <- dat %>%
                    select(c(ends_with("T3"))) %>%
                    select(-c(starts_with("PGIC")))

                  colnames(dat_t3) <- Names

                  dat_t4 <- dat %>%
                    select(c(ends_with("T4"))) %>%
                    select(-c(starts_with("PGIC")))

                  colnames(dat_t4) <- Names

                  # Start data manip =========

                  myplot <- function(df, timepoint,graphname){

                    Resp_Dist <<- df %>% #set the dataset
                      apply(2, table) %>% # tabulate response distributions
                      as.data.frame() %>% #apply on the above line makes a matrix. This converts to a dataframe.
                      mutate(Response = as.factor(c(0:3))) #Here we make sure that we have a column labelling the response options
                    #select(Response, starts_with("item")) #And move response to the front of the dataset

                    colnames(Resp_Dist) <<- c(Names,"Response")

                    #Make a staked barchart for one of the timepoints
                    #First transpose the dataset to long format
                    Resp_Dist <<- Resp_Dist %>%
                      pivot_longer(cols = c(1:12), names_to = "Item", values_to = "Frequency") %>% #this is the line which makes a long dataset. here we are selecting all columns (ie columns relating to time 3) and keeping the item names in a new variable called "item" and the number that select each response option in a new variable called  "Frequency"
                      mutate(Item = as.factor(Item)) %>% #make item a factor rather than just a character variable. important for plotting
                      mutate(Response = as.factor(if_else(Response == 0, "Severe",
                                                          (if_else(Response == 1, "Moderate",
                                                                   (if_else(Response == 2, "Mild",
                                                                            "None")))))))


                    Resp_Dist$Response <- factor(Resp_Dist$Response, levels = c("Severe", "Moderate", "Mild", "None"))


                    Plot_Resp_Dist <<- ggplot(data=Resp_Dist, mapping = aes(fill = Response, x=reorder(Item, desc(Item)), y=Frequency)) + #start with a ggplot statement
                      geom_bar(aes(fill=factor(Response)),position="fill", stat="identity")+ #tell it you want a bar chart. position "fill" makes it a stacked bar chart
                      scale_fill_manual(name = "Response Option",values=c(Turquoise100, Turquoise75, Turquoise50, Turquoise25), guide = guide_legend(reverse = TRUE)) + #set the colours. Reverse makes sure that the bars are 0-3 rather than 3-0
                      theme_classic() + #just removes gridlines etc
                      ggtitle(paste(timepoint))+
                      labs(y= "Frequency of response option use", x = NULL) +
                      scale_y_continuous(labels = scales::percent) + #makes the axis percent
                      coord_flip() + #flips to a horizontal chart
                      theme(panel.background = element_blank(), axis.line = element_blank(),
                            axis.text=element_text(size=10),
                            axis.title=element_text(size=10),
                            legend.text=element_text(size=10),
                            legend.title=element_text(size=10),
                            plot.title = element_text(size=16, face="bold"),
                            plot.subtitle = element_text(size=14, face="bold"),
                            legend.position="right")

                    #view plot
                    Plot_Resp_Dist

                    assign(graphname, Plot_Resp_Dist, envir = .GlobalEnv)

                  }
                  DAY1 <- vector(mode = "list", length = 9)
                  myplot(dat_t1, "Day 1", "DAY1")

                  DAY2 <- vector(mode = "list", length = 9)
                  myplot(dat_t2, "Day 2", "DAY2")

                  DAY3 <- vector(mode = "list", length = 9)
                  myplot(dat_t3, "Day 3", "DAY3")

                  DAY4 <- vector(mode = "list", length = 9)
                  myplot(dat_t4, "Day 4", "DAY4")

                  DAY1
                  DAY2
                  DAY3
                  DAY4

                  Response_Distributions <- ggarrange(DAY1, DAY2, DAY3, DAY4, common.legend = TRUE, legend = "bottom")

                  Response_Distributions <- annotate_figure(Response_Distributions,
                                                            top = text_grob("Symptom severity increased each day", color = "black", face = "bold", size = 20),
                                                            bottom = NULL,
                                                            left = "SDQ-12 item name",
                                                            right = NULL)

                  Response_Distributions
                  png(filename = "outputs/Response Distributions.png",  width = 920, height = 540, units = "px", pointsize = 10,bg = "white")
                  Response_Distributions
                  dev.off()
