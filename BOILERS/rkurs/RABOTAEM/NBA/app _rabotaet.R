#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)
library(dplyr)
library(gbm)
library(randomForest)
library(fastDummies)
library(neuralnet)
library(shinythemes)
library(party)
library(shinyWidgets)


library(readxl)
winner <- read_excel("WINNER_with_date.xlsx")
winner$ID = c(1:nrow(winner))
winner$GDate = as.Date(winner$GDate)
winner$code = paste(winner$Away,"vs",winner$Home,sep = "-")
winner= winner %>% na.omit()
winner$HOME_WIN = as.factor(winner$HOME_WIN)
winner$ALastGameAgo = as.numeric(winner$ALastGameAgo)
winner$HLastGameAgo = as.numeric(winner$HLastGameAgo)
winner=winner %>% mutate_if(is.character, as.factor)


library(readxl)
total <- read_excel("TOTAL_with_date.xlsx")
total$ID = c(1:nrow(total))
total$GDate = as.Date(total$GDate)
total$code = paste(total$Away,"vs",total$Home,sep = "-")
total= total %>% na.omit()
total$ALastGameAgo = as.numeric(total$ALastGameAgo)
total$HLastGameAgo = as.numeric(total$HLastGameAgo)
total=total %>% mutate_if(is.character, as.factor)

library(readxl)
fora <- read_excel("FORA_with_date.xlsx")
fora$ID = c(1:nrow(fora))
fora$GDate = as.Date(fora$GDate)
fora$code = paste(fora$Away,"vs",fora$Home,sep = "-")
fora= fora %>% na.omit()
fora$ALastGameAgo = as.numeric(fora$ALastGameAgo)
fora$HLastGameAgo = as.numeric(fora$HLastGameAgo)
fora=fora %>% mutate_if(is.character, as.factor)






# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("lumen"),
                
                # Application title
                titlePanel(h1(strong("NBA BETTING HELPER"), align="center")),
                
                # Calendar
                fluidRow(
                  column(6,  
                         wellPanel(
                           dateInput("date", label = h3("Date input"), value = "2020-01-10"),
                           
                           htmlOutput("game_selector"),
                           
                           
                           
                           radioButtons("predict_type", h3("Prediction Type:"),
                                        list("Winner",
                                             "Total",
                                             "Fora")
                           ),
                           
                           
                           htmlOutput("algorithm_selector")
                           )),
                  column(6,
                         wellPanel(
                           sliderInput("ntree", label = h3("Number of Trees in RF", align="center"), min = 100, 
                                       max = 2100, value = 1100,step=100),
                           sliderInput("deeptree", label = h3("Deep of trees in RF", align="center"), min = 1, 
                                       max = 10, value = 2,step=1),
                           sliderInput("BOOSTntree", label = h3("Number of Trees in GBM", align="center"), min = 100, 
                                       max = 2100, value = 1100,step=100),
                           h3(actionButton("go", "All models", style='padding:14px; font-size:100%; color: #fff; background-color: #337ab7; border-color: #2e6da4'), align="center"))
                  )
                ),
                
                fluidRow(
                  column(12,  
                         wellPanel(
                           h3(htmlOutput("itog"), align="center")))
                  
                ),
                
                fluidRow(
                  column(12,  
                         mainPanel(width = 12,
                           h4(htmlOutput("lasttable")), align="center"))),
                

                
                
                #tags$audio(src = "sicko.mp3", type = "audio/mp3", autoplay = F, controls = "controls"),
                
                fluidRow(
                  column(12,  
                         mainPanel(width = 12,h3(actionButton("hype", "HYPE MUSIC",icon("fas fa-basketball-ball") ,style='padding:10px; font-size:100%; color: #fff; background-color: #DC143C; border-color: #2e6da4'), align="center"))
                  )
                ),
                

                
                fluidRow(
                  column(12,  
                         (h3(uiOutput("hypesong"), align="center"))
                  )
                ),
                
                fluidRow(
                  column(12,  
                         mainPanel(width = 12,h3(tags$embed(src = "swagh.gif"),align="center")),
                  )
                ),
                
                fluidRow(
                  column(12,  
                         img(src='nba.png',width="400", height="300"), align = "center")),
                fluidRow(absolutePanel(h4("Developers : ",tags$a(href="https://vk.com/kachanix", "Sirgay"),", " ,tags$a(href="https://vk.com/id113923607", "Alexander"),", ",tags$a(href="https://vk.com/flippiv", "Vladimir") ),fixed=T,bottom=0.5)                    
                         )
)






###################################### SERVER ######################################
server <- function(input, output) {
  
  output$value <- renderPrint({ input$date })
  #output$table <- renderTable(winner %>% filter(GDate == as.Date(input$date))%>% select(Home, ID))
  
  #Choosing the game
  output$game_selector = renderUI({#creates County select box object called in ui
    
    data_available = winner[winner$GDate == input$date, "code"]
    data_available = if(input$date %in% winner$GDate[50:length(winner$GDate)]){data_available}else{list("NO GAMES TODAY")}
    #creates a reactive list of available counties based on the State selection made
    selectInput(inputId = "game", #name of input
                label = h3("Game:"), #label displayed in ui
                choices = data_available, #calls list of available counties
                selected = data_available[1])
  })
  
  
  censusVis = reactive({game_id = winner %>% filter(GDate == as.Date(input$date)) %>% filter(code == input$game) %>% select(ID)
  game_id = as.numeric(game_id[1,"ID"])   
  game_id
  })
  
  uns = reactive({winner %>% filter(GDate == as.Date(input$date)) %>% filter(code == input$game) %>% select(ID)}) 
  game_id1 = reactive({as.numeric(uns()[1,"ID"])  })   
  
  
  
  
  
  
  
  
  
  output$algorithm_selector = renderUI({ 
    if(input$predict_type == "Winner") {
      selectInput(inputId = "algor", #name of input
                  label = h3("Algoritm:"), #label displayed in ui
                  choices = list("Logistic","RandomForest","Boosting","ANN","Stacking"), #calls list of available counties
                  selected = "Logistic")
    }   
    
    else {
      selectInput(inputId = "algor", #name of input
                  label = "Algoritm:", #label displayed in ui
                  choices = list("Regression","Boosting","HardBoosting","Stacking"), #calls list of available counties
                  selected = "Logistic")
    }   
  })
  
  
  output$itog = renderText(
    
    ########      LOGIT WINNER     #############
    if(input$predict_type == "Winner" & input$algor=="Logistic"){
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      #####CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      factors <- which(sapply(train, is.factor))
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2, as.numeric(be$nlevels[10]) != 1)
      
      WORSE = factors[BAD]
      #####CODE#####
      formula <- as.formula(paste(colnames(train)[222],'~', paste(colnames(train)[-WORSE],collapse = "+")))
      
      log.model = glm(formula, data = train, family = binomial(link = 'logit'))
      
      
      Log.train = predict(log.model, newdata = train, type = "response")
      Log.test = predict(log.model, newdata = test, type = "response")
      
      Log.pred.train0.5 = ifelse(Log.train > 0.5,1,0)
      Log.pred.test0.5 = ifelse(Log.test > 0.5,1,0)
      
      
      test$Home=as.character(test$Home)
      test$Away=as.character(test$Away)
      
      if (as.numeric(Log.test) > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    
      
      
      
      test$value_home = Log.test * 100 * (test$HODD - 1) - (1-Log.test) * 100
      test$value_away = (1-Log.test) * 100 * (test$AODD - 1) - Log.test * 100
      
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      
      test$prob = dplyr::case_when(
        test$team == test$Home ~ Log.test,
        test$team == test$Away ~ 1 - Log.test,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        str1 = paste0( "We recommend to put a bet on ","<b>" ,test$team,"</b>" ," with a coefficient ","<b>" ,round(test$coeff, digits = 3),"</b>","<br/> " ,"<small>", "The coefficients for this match are: ", round(test$HODD, digits = 3)," for " ,test$Home ," and ", round(test$AODD, digits = 3), " for ", test$Away, "<br/> ", "According to our prediction, ", test$team, "'s probability to win is ", round(test$prob, digits = 3),"<br/> ","Expected profit from this bet is ", round(max(test$value_home, test$value_away), digits = 3),".</small>")
      } else {
        str1 = paste0("There is no optimal prediction for this match: the coefficients are not profitable.","<br>","<small>" ,"The coefficients for this match are: ", round(test$HODD, digits = 3)," for ", test$Home, " and ", round(test$AODD, digits = 3), " for ", test$Away,"</small>",".</br>" )
      }
      
      
      #str1 = paste("We recommend you to bet on", paste("<b>",result,"</b>"), "with coefficient",paste("<b>",coeff,"</b>"))
      
      if (test$HOME_WIN == 1){
        
        winner = test[1, "Home"]
        
      } else {
        winner = test[1, "Away"]
      }
      
      if (((test$HOME_WIN == 1) & (as.factor(test$team) == test$Home)) | ((test$HOME_WIN == 0) & (as.factor(test$team) == test$Away))){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      library(stringr)
      if (str_detect(str1, "optimal")){
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>")
      } else {
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>", ", the prediction is", proper)
      }        
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
    }
    
    
    
    
    
    ########REG FORA###########
    else if(input$predict_type == "Fora" & input$algor=="Regression"){
      
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code, -ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      #####CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      #####CODE#####
      
      geegun = geegun[1:(length(geegun)-1)]
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse="+")))
      
      reg = lm(formula, data = train)
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      
      
      
      if (as.numeric(pred.Regression.Test) >= test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else  if (as.numeric(pred.Regression.Test) < test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      } else  if (as.numeric(pred.Regression.Test) >= test$ForaClose & test$ForaClose >= 0 ){
        
        result = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      
      if (test$Fora >= test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else if (test$Fora < test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Away)
        
      } else if (test$Fora >= test$ForaClose & test$ForaClose >= 0 ){
        
        true = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      
      if (true == result){
        
        check = '<font color="	#008000">correct</font>'
      } else {
        check = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("The true handcap is","<b>", test$Fora,"</b>", ", the prediction is", check)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
      
      
      
      
    }
    #############    REG TOTAL ###############
    else if(input$predict_type == "Total" & input$algor=="Regression"){
      
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)            
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))            
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      
      #######CODE#####
      geegun = geegun[1:(length(geegun)-1)]
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse = "+")))
      
      reg = lm(formula, data = train)
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      
      if (as.numeric(pred.Regression.Test) >= test$TotalClose){
        
        result = paste("Total over", test$TotalClose)
        
      } else {
        result = paste("Total under", test$TotalClose)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      if ((as.numeric(pred.Regression.Test) >= test$TotalClose & test$Total >= test$TotalClose) | (as.numeric(pred.Regression.Test) < test$TotalClose & test$Total < test$TotalClose)){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("True total is","<b>" ,test$Total,"</b>", ", the prediction is", proper)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
    }
    ###############  BOOSTING TOTAL  ################
    else if(input$predict_type == "Total" & input$algor=="Boosting"){
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))

      
      model.boost2=gbm(Total~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      
      if (as.numeric(predTestProb.boost2) >= test$TotalClose){
        
        result = paste("Total over", test$TotalClose)
        
      } else {
        result = paste("Total under", test$TotalClose)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      if ((as.numeric(predTestProb.boost2) >= test$TotalClose & test$Total >= test$TotalClose) | (as.numeric(predTestProb.boost2) < test$TotalClose & test$Total < test$TotalClose)){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("True total is","<b>" ,test$Total,"</b>", ", the prediction is", proper)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
      
      
    }
    #########   HardBoosting TOTAL   #################
    else if(input$predict_type == "Total" & input$algor=="HardBoosting"){
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      model.boost3=gbm(Total~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      
      if (as.numeric(predTestProb.boost3) >= test$TotalClose){
        
        result = paste("Total over", test$TotalClose)
        
      } else {
        result = paste("Total under", test$ForaClose)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      if ((as.numeric(predTestProb.boost3) >= test$TotalClose & test$Total >= test$TotalClose) | (as.numeric(predTestProb.boost3) < test$TotalClose & test$Total < test$TotalClose)){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("True total is","<b>" ,test$Total,"</b>", ", the prediction is", proper)
      
      HTML(paste(str1, str2, sep = '<br/>'))
    }
    
    ###############     BOOSTING FORA #################
    else if(input$predict_type == "Fora" & input$algor=="Boosting"){
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      model.boost2=gbm(Fora~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      
      
      if (as.numeric(predTestProb.boost2) >= test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else  if (as.numeric(predTestProb.boost2) < test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      } else  if (as.numeric(predTestProb.boost2) >= test$ForaClose & test$ForaClose >= 0 ){
        
        result = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      
      if (test$Fora >= test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else if (test$Fora < test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Away)
        
      } else if (test$Fora >= test$ForaClose & test$ForaClose >= 0 ){
        
        true = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      
      if (true == result){
        
        check = '<font color="	#008000">correct</font>'
      } else {
        check = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("The true handcap is","<b>", test$Fora,"</b>", ", the prediction is", check)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
    }
    
    
    
    
    ###############   HardBoosting FORA ###################
    else if(input$predict_type == "Fora" & input$algor=="HardBoosting"){
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      model.boost3=gbm(Fora~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      
      
      if (as.numeric(predTestProb.boost3) >= test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else  if (as.numeric(predTestProb.boost3) < test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      } else  if (as.numeric(predTestProb.boost3) >= test$ForaClose & test$ForaClose >= 0 ){
        
        result = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      
      if (test$Fora >= test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else if (test$Fora < test$ForaClose & test$ForaClose <= 0 ){
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Away)
        
      } else if (test$Fora >= test$ForaClose & test$ForaClose >= 0 ){
        
        true = paste("Handicap", -test$ForaClose, "in favour of ", test$Away)
        
      } else {
        
        true = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      
      if (true == result){
        
        check = '<font color="	#008000">correct</font>'
      } else {
        check = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("The true handcap is","<b>", test$Fora,"</b>", ", the prediction is", check)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
    }
    
    ################   STACKING TOTAL  ###################
    else if(input$predict_type == "Total" & input$algor=="Stacking"){
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse = "+")))
      
      reg = lm(formula, data = train)
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      new_pred.Regression.Test = predict(reg, newdata = new_test)

      
      model.boost2=gbm(Total~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      new_predTestProb.boost2 = predict(model.boost2, new_test, n.trees = 1000, type = "response")


      
      model.boost3=gbm(Total~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      new_predTestProb.boost3 = predict(model.boost3, new_test, n.trees = 1000, type = "response")

      dataStack =  data.frame(reg = pred.Regression.Test, 
                              gbm2 = predTestProb.boost2, 
                              gbm3 = predTestProb.boost3,
                              Total = test$Total)
      
      
      model.stack = caret::train(Total~., data=(dataStack %>% na.omit() ), method = "ctree")
      
      predictionsTest = data.frame(reg = new_pred.Regression.Test, 
                                   gbm2 = new_predTestProb.boost2, 
                                   gbm3 = new_predTestProb.boost3, 
                                   Total = new_test$Total)
      
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      
      
      if (as.numeric(predTest.stack) >= new_test$TotalClose){
        
        result = paste("Total over", new_test$TotalClose)
        
      } else {
        result = paste("Total under", new_test$TotalClose)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      if ((as.numeric(predTest.stack) >= new_test$TotalClose & new_test$Total >= new_test$TotalClose) | (as.numeric(predTest.stack) < new_test$TotalClose & new_test$Total < new_test$TotalClose)){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("True total is","<b>" ,new_test$Total,"</b>", ", the prediction is", proper)
      
      HTML(paste(str1, str2, sep = '<br/>'))
    }
    
    
    
    
    ##############STACKING FORA ##################
    else if(input$predict_type == "Fora" & input$algor=="Stacking"){
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)            
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))  
      
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', geegun))
      
      reg = lm(formula, data = train)
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      new_pred.Regression.Test = predict(reg, newdata = new_test)
      
      
      model.boost2=gbm(Fora~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      new_predTestProb.boost2 = predict(model.boost2, new_test, n.trees = 1000, type = "response")

      
      model.boost3=gbm(Fora~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      new_predTestProb.boost3 = predict(model.boost3, new_test, n.trees = 1000, type = "response")
      
      
      
      dataStack =  data.frame(reg = pred.Regression.Test, 
                              gbm2 = predTestProb.boost2, 
                              gbm3 = predTestProb.boost3,
                              Fora = test$Fora)
      
      
      model.stack = caret::train(Fora~., data=(dataStack %>% na.omit() ), method = "ctree")
      
      predictionsTest = data.frame(reg = new_pred.Regression.Test, gbm2 = new_predTestProb.boost2, gbm3 = new_predTestProb.boost3, Fora = new_test$Fora)
      
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      
      
      if (as.numeric(predTest.stack) >= new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(new_test$ForaClose), "in favour of", new_test$Away)
        
      } else  if (as.numeric(predTest.stack) < new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        result = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Home)
        
      } else  if (as.numeric(predTest.stack) >= new_test$ForaClose & new_test$ForaClose >= 0 ){
        
        result = paste("Handicap", -new_test$ForaClose, "in favour of", new_test$Away)
        
      } else {
        
        result = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Home)
        
      }
      
      str1 = paste("The prediction is - ", paste("<b>",result,"</b>"))
      
      if (new_test$Fora >= new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        true = paste("Handicap", abs(new_test$ForaClose), "in favour of", new_test$Away)
        
      } else if (new_test$Fora < new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        true = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Away)
        
      } else if (new_test$Fora >= new_test$ForaClose & new_test$ForaClose >= 0 ){
        
        true = paste("Handicap", -new_test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        true = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Home)
        
      }
      
      
      if (true == result){
        
        check = '<font color="	#008000">correct</font>'
      } else {
        check = '<font color="	#ff0000">incorrect</font>'
      }
      
      str2 = paste("The true handcap is","<b>", new_test$Fora,"</b>", ", the prediction is", check)
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
      
    }
    
    
    
    ############ RANDOM FOREST WINNER ###############
    else if(input$predict_type == "Winner" & input$algor=="RandomForest"){
      #winner=winner %>% mutate_if(is.character, as.factor)
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      
      set.seed(1)
      model.rf=randomForest::randomForest(HOME_WIN~.,data=train, mtry=5, ntree = 1000)
      
      
      predTrain.rf =as.numeric(predict(model.rf, train)) - 1
      predTest.rf = predict(model.rf, test)
      predTest.rf = as.numeric(predTest.rf) - 1
      
      predTest.rf = predict(model.rf, test,"prob")[,2]
      
      
      
      if (predTest.rf > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    
      
      
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      
      test$value_home = predTest.rf * 100 * (test$HODD - 1) - (1-predTest.rf) * 100
      test$value_away = (1-predTest.rf) * 100 * (test$AODD - 1) - predTest.rf * 100
      
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTest.rf,
        test$team == test$Away ~ 1 - predTest.rf,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        str1 = paste0( "We recommend to put a bet on ","<b>" ,test$team,"</b>" ," with a coefficient ","<b>" ,round(test$coeff, digits = 3),"</b>","<br/> " ,"<small>", "The coefficients for this match are: ", round(test$HODD, digits = 3)," for " ,test$Home ," and ", round(test$AODD, digits = 3), " for ", test$Away, "<br/> ", "According to our prediction, ", test$team, "'s probability to win is ", round(test$prob, digits = 3),"<br/> ","Expected profit from this bet is ", round(max(test$value_home, test$value_away), digits = 3),".</small>")
      } else {
        str1 = paste0("There is no optimal prediction for this match: the coefficients are not profitable.","<br>","<small>" ,"The coefficients for this match are: ", round(test$HODD, digits = 3)," for ", test$Home, " and ", round(test$AODD, digits = 3), " for ", test$Away,"</small>",".</br>" )
      }
      
      
      #str1 = paste("We recommend you to bet on", paste("<b>",result,"</b>"), "with coefficient",paste("<b>",coeff,"</b>"))
      
      if (test$HOME_WIN == 1){
        
        winner = test[1, "Home"]
        
      } else {
        winner = test[1, "Away"]
      }
      
      if (((test$HOME_WIN == 1) & (as.factor(test$team) == test$Home)) | ((test$HOME_WIN == 0) & (as.factor(test$team) == test$Away))){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      library(stringr)
      if (str_detect(str1, "optimal")){
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>")
      } else {
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>", ", the prediction is", proper)
      }        
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
    } 
    
    
    
    
    
    ############ ANN WINNER #################
    else if(input$predict_type == "Winner" & input$algor=="ANN"){
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      
      train$HOME_WIN = as.numeric(train$HOME_WIN) - 1
      test$HOME_WIN = as.numeric(test$HOME_WIN) - 1
      
      train1 = fastDummies::dummy_cols(train,remove_selected_columns = T,remove_first_dummy = TRUE)
      test1 = fastDummies::dummy_cols( test,remove_selected_columns = T,remove_first_dummy = TRUE)
      
      nn=neuralnet(HOME_WIN~.,data=(train1 %>% na.omit()) , hidden=c(20,10),act.fct = "logistic",
                   linear.output = FALSE)
      
      
      predTrain.nn = predict(nn,train1 %>% na.omit())
      predTest.nn = predict(nn, test1 %>% na.omit())
      
      Ann.pred.train0.5 = ifelse(predTrain.nn > 0.5,1,0)
      Ann.pred.test0.5 = ifelse(predTest.nn > 0.5,1,0)
      
      test$Home=as.character(test$Home)
      test$Away=as.character(test$Away)
      
      if (as.numeric(Ann.pred.test0.5) > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    
      
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      
      test$value_home = predTest.nn * 100 * (test$HODD - 1) - (1-predTest.nn) * 100
      test$value_away = (1-predTest.nn) * 100 * (test$AODD - 1) - predTest.nn * 100
      
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTest.nn,
        test$team == test$Away ~ 1 - predTest.nn,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        str1 = paste0( "We recommend to put a bet on ","<b>" ,test$team,"</b>" ," with a coefficient ","<b>" ,round(test$coeff, digits = 3),"</b>","<br/> " ,"<small>", "The coefficients for this match are: ", round(test$HODD, digits = 3)," for " ,test$Home ," and ", round(test$AODD, digits = 3), " for ", test$Away, "<br/> ", "According to our prediction, ", test$team, "'s probability to win is ", round(test$prob, digits = 3),"<br/> ","Expected profit from this bet is ", round(max(test$value_home, test$value_away), digits = 3),".</small>")
      } else {
        str1 = paste0("There is no optimal prediction for this match: the coefficients are not profitable.","<br>","<small>" ,"The coefficients for this match are: ", round(test$HODD, digits = 3)," for ", test$Home, " and ", round(test$AODD, digits = 3), " for ", test$Away,"</small>",".</br>" )
      }
      
      
      #str1 = paste("We recommend you to bet on", paste("<b>",result,"</b>"), "with coefficient",paste("<b>",coeff,"</b>"))
      
      if (test$HOME_WIN == 1){
        
        winner = test[1, "Home"]
        
      } else {
        winner = test[1, "Away"]
      }
      
      if (((test$HOME_WIN == 1) & (as.factor(test$team) == test$Home)) | ((test$HOME_WIN == 0) & (as.factor(test$team) == test$Away))){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      library(stringr)
      if (str_detect(str1, "optimal")){
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>")
      } else {
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>", ", the prediction is", proper)
      }        
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
      
    }
    
    ########### BOOSTING WINER ##################
    else if(input$predict_type == "Winner" & input$algor=="Boosting"){
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      model.boost=gbm((as.numeric(HOME_WIN)-1)~., data=train, distribution="bernoulli", n.trees=2000, interaction.depth=5)
      
      predTrainProb.boost = predict(model.boost, train, n.trees = 2000, type = "response")
      predTestProb.boost = predict(model.boost, test, n.trees = 2000, type = "response")
      
      Train.pred0.5.boost <- ifelse(predTrainProb.boost> 0.5,1,0)
      Test.pred0.5.boost <- ifelse(predTestProb.boost> 0.5,1,0)
      
      
      if (as.numeric(predTestProb.boost) >= 0.5){
        
        result = test[1,3]
        coeff = test[1,4]
        
      } else {
        result = test[1,1]
        coeff = test[1,2]
      }
      
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      
      test$value_home = predTestProb.boost * 100 * (test$HODD - 1) - (1-predTestProb.boost) * 100
      test$value_away = (1-predTestProb.boost) * 100 * (test$AODD - 1) - predTestProb.boost * 100
      
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTestProb.boost,
        test$team == test$Away ~ 1 - predTestProb.boost,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        str1 = paste0( "We recommend to put a bet on ","<b>" ,test$team,"</b>" ," with a coefficient ","<b>" ,round(test$coeff, digits = 3),"</b>","<br/> " ,"<small>", "The coefficients for this match are: ", round(test$HODD, digits = 3)," for " ,test$Home ," and ", round(test$AODD, digits = 3), " for ", test$Away, "<br/> ", "According to our prediction, ", test$team, "'s probability to win is ", round(test$prob, digits = 3),"<br/> ","Expected profit from this bet is ", round(max(test$value_home, test$value_away), digits = 3),".</small>")
      } else {
        str1 = paste0("There is no optimal prediction for this match: the coefficients are not profitable.","<br>","<small>" ,"The coefficients for this match are: ", round(test$HODD, digits = 3)," for ", test$Home, " and ", round(test$AODD, digits = 3), " for ", test$Away,"</small>",".</br>" )
      }
      
      
      #str1 = paste("We recommend you to bet on", paste("<b>",result,"</b>"), "with coefficient",paste("<b>",coeff,"</b>"))
      
      if (test$HOME_WIN == 1){
        
        winner = test[1, "Home"]
        
      } else {
        winner = test[1, "Away"]
      }
      
      if (((test$HOME_WIN == 1) & (as.factor(test$team) == test$Home)) | ((test$HOME_WIN == 0) & (as.factor(test$team) == test$Away))){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      library(stringr)
      if (str_detect(str1, "optimal")){
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>")
      } else {
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>", ", the prediction is", proper)
      }        
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
    }
    ############  STACKING WINNER  ###############
    else if(input$predict_type == "Winner" & input$algor=="Stacking"){
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      
      
      #####CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      factors <- which(sapply(train, is.factor))
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2, as.numeric(be$nlevels[10]) != 1)
      WORSE = factors[BAD]
      #####CODE#####
      formula <- as.formula(paste(colnames(train)[222],'~', paste(colnames(train)[-WORSE],collapse = "+")))
      log.model = glm(formula, data = train, family = binomial(link = 'logit'))
      
      Log.train = predict(log.model, newdata = train, type = "response")
      Log.test = predict(log.model, newdata = test, type = "response")
      new_Log.test = predict(log.model, newdata = new_test, type = "response")
      
      
      Log.pred.train0.5 = ifelse(Log.train > 0.5,1,0)
      Log.pred.test0.5 = ifelse(Log.test > 0.5,1,0)
      new_Log.pred.test0.5 = ifelse(new_Log.test > 0.5,1,0)
      
      
      
      set.seed(1)
      model.rf=randomForest::randomForest(HOME_WIN~.,data=train, mtry=5, ntree = 1000)
      
      
      predTrain.rf =as.numeric(predict(model.rf, train)) - 1
      predTest.rf = as.numeric(predict(model.rf, test)) - 1
      new_predTest.rf = as.numeric(predict(model.rf, new_test)) - 1
      
      

      
      train$HOME_WIN = as.numeric(train$HOME_WIN) - 1
      test$HOME_WIN = as.numeric(test$HOME_WIN) - 1
      new_test$HOME_WIN = as.numeric(new_test$HOME_WIN) - 1
      
      train1 = fastDummies::dummy_cols(train %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      test1 = fastDummies::dummy_cols( test %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      new_test1 = fastDummies::dummy_cols( new_test %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      
      train1$HOME_WIN = train$HOME_WIN
      test1$HOME_WIN = test$HOME_WIN
      new_test1$HOME_WIN = new_test$HOME_WIN
      
      nn=neuralnet(HOME_WIN~.,data=(train1 %>% na.omit()) , hidden=c(20,10),act.fct = "logistic",
                   linear.output = FALSE)
      
      
      predTrain.nn = predict(nn,train1 %>% na.omit())
      predTest.nn = predict(nn, test1 %>% na.omit())
      new_predTest.nn = predict(nn, new_test1 %>% na.omit())
      
      
      Ann.pred.train0.5 = ifelse(predTrain.nn > 0.5,1,0)
      Ann.pred.test0.5 = ifelse(predTest.nn > 0.5,1,0)
      new_Ann.pred.test0.5 = ifelse(new_predTest.nn > 0.5,1,0)
      
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      model.boost=gbm((as.numeric(HOME_WIN)-1)~., data=train, distribution="bernoulli", n.trees=2000, interaction.depth=5)
      
      predTrainProb.boost = predict(model.boost, train, n.trees = 2000, type = "response")
      predTestProb.boost = predict(model.boost, test, n.trees = 2000, type = "response")
      new_predTestProb.boost = predict(model.boost, new_test, n.trees = 2000, type = "response")
      
      
      Train.pred0.5.boost <- ifelse(predTrainProb.boost> 0.5,1,0)
      Test.pred0.5.boost <- ifelse(predTestProb.boost> 0.5,1,0)
      new_Test.pred0.5.boost <- ifelse(new_predTestProb.boost> 0.5,1,0)
      
      
      dataStack =  data.frame(reg = Log.pred.test0.5, 
                              rf = predTest.rf, 
                              ann = Ann.pred.test0.5,
                              gbm = Test.pred0.5.boost,
                              HOME_WIN = as.numeric(test$HOME_WIN)-1)
      
      
      model.stack = caret::train(HOME_WIN~., data=(dataStack %>% na.omit() ), method = "glm")
      
      predictionsTest = data.frame(reg = new_Log.pred.test0.5,
                                   rf = new_predTest.rf,
                                   ann = new_Ann.pred.test0.5,
                                   gbm = new_Test.pred0.5.boost,
                                   HOME_WIN = as.numeric(new_test$HOME_WIN)-1)
      
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      
      new_test$Home=as.character(new_test$Home)
      new_test$Away=as.character(new_test$Away)
      
      if (predTest.stack > 0.5){
        
        result = new_test[1,"Home"]
        coeff = new_test[1,4]
        
      } else {
        result = new_test[1,"Away"]
        coeff = new_test[1,2]
      }    
      
      new_test$Home = as.character(new_test$Home)
      new_test$Away = as.character(new_test$Away)
      
      new_test$value_home = predTest.stack * 100 * (new_test$HODD - 1) - (1-predTest.stack) * 100
      new_test$value_away = (1-predTest.stack) * 100 * (new_test$AODD - 1) - predTest.stack * 100
      
      new_test$team = case_when(
        (new_test$value_home >= new_test$value_away) & (new_test$value_home > 0) ~ new_test$Home,
        (new_test$value_away >= new_test$value_home) & (new_test$value_away > 0) ~ new_test$Away,
        TRUE ~ "0")
      
      new_test$coeff = dplyr::case_when(
        new_test$team == new_test$Home ~ new_test$HODD,
        new_test$team == new_test$Away ~ new_test$AODD,
        TRUE ~ 0)
      
      new_test$prob = dplyr::case_when(
        new_test$team == new_test$Home ~ predTest.stack,
        new_test$team == new_test$Away ~ 1 - predTest.stack,
        TRUE ~ 0)
      
      if (new_test$team != as.factor(0)){
        str1 = paste0( "We recommend to put a bet on ","<b>" ,new_test$team,"</b>" ," with a coefficient ","<b>" ,round(new_test$coeff, digits = 3),"</b>","<br/> " ,"<small>", "The coefficients for this match are: ", round(new_test$HODD, digits = 3)," for " ,new_test$Home ," and ", round(new_test$AODD, digits = 3), " for ", new_test$Away, "<br/> ", "According to our prediction, ", new_test$team, "'s probability to win is ", round(new_test$prob, digits = 3),"<br/> ","Expected profit from this bet is ", round(max(new_test$value_home, new_test$value_away), digits = 3),".</small>")
      } else {
        str1 = paste0("There is no optimal prediction for this match: the coefficients are not profitable.","<br>","<small>" ,"The coefficients for this match are: ", round(new_test$HODD, digits = 3)," for ", new_test$Home, " and ", round(new_test$AODD, digits = 3), " for ", new_test$Away,"</small>",".</br>" )
      }
      
      
      #str1 = paste("We recommend you to bet on", paste("<b>",result,"</b>"), "with coefficient",paste("<b>",coeff,"</b>"))
      
      if (new_test$HOME_WIN == 1){
        
        winner = new_test[1, "Home"]
        
      } else {
        winner = new_test[1, "Away"]
      }
      
      if (((new_test$HOME_WIN == 1) & (as.factor(new_test$team) == new_test$Home)) | ((new_test$HOME_WIN == 0) & (as.factor(new_test$team) == new_test$Away))){
        
        proper = '<font color="	#008000">correct</font>'
        
      } else {
        proper = '<font color="	#ff0000">incorrect</font>'
      }
      
      library(stringr)
      if (str_detect(str1, "optimal")){
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>")
      } else {
        str2 = paste("The true winner of this match is","<b>" ,winner,"</b>", ", the prediction is", proper)
      }        
      
      HTML(paste(str1, str2, sep = '<br/>'))
      
    }
  )
  
  
  
  
  
  
  
  
  #LAST TABLE
  
  
  
  allpred <- eventReactive(input$go, {
    
    ################## WINNER ####################
    if(input$predict_type == "Winner"){
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      #####CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      factors <- which(sapply(train, is.factor))
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2, as.numeric(be$nlevels[10]) != 1)
      WORSE = factors[BAD]
      #####CODE#####
      formula <- as.formula(paste(colnames(train)[222],'~', paste(colnames(train)[-WORSE],collapse = "+")))
      log.model = glm(formula, data = train, family = binomial(link = 'logit'))
      Log.train = predict(log.model, newdata = train, type = "response")
      Log.test = predict(log.model, newdata = test, type = "response")
      Log.pred.train0.5 = ifelse(Log.train > 0.5,1,0)
      Log.pred.test0.5 = ifelse(Log.test > 0.5,1,0)
      test$Home=as.character(test$Home)
      test$Away=as.character(test$Away)
      if (as.numeric(Log.test) > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    

      test$value_home = Log.test * 100 * (test$HODD - 1) - (1-Log.test) * 100
      test$value_away = (1-Log.test) * 100 * (test$AODD - 1) - Log.test * 100
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      test$prob = dplyr::case_when(
        test$team == test$Home ~ Log.test,
        test$team == test$Away ~ 1 - Log.test,
        TRUE ~ 0)
      if (test$team != as.factor(0)){
        logist1 = paste("<b>Logistic : </b> " ,"We recommend to put a bet on ","<b>" ,test$team,"</b>" )
      } else {
        logist1 = paste("<b>Logistic : </b>: " ,"There is no optimal prediction for this match: the coefficients are not profitable.")
      }
      coef = paste("The coefficients for this match are: ","<b>" , '<font color="	#1E90FF">', round(test$HODD, digits = 3)," for " ,test$Home,'</font>',"</b>" ," and ",  "<b>",'<font color="	#DC143C">' ,round(test$AODD, digits = 3), " for ", test$Away,'</font>',"</b>")
      
      
      
      
      
      
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      set.seed(1)
      model.rf=randomForest::randomForest(HOME_WIN~.,data=train, mtry=5, ntree = 1000)
      predTrain.rf =as.numeric(predict(model.rf, train)) - 1
      predTest.rf = predict(model.rf, test)
      predTest.rf = as.numeric(predTest.rf) - 1
      predTest.rf = predict(model.rf, test,"prob")[,2]
      
      if (predTest.rf > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    
      
      
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      test$value_home = predTest.rf * 100 * (test$HODD - 1) - (1-predTest.rf) * 100
      test$value_away = (1-predTest.rf) * 100 * (test$AODD - 1) - predTest.rf * 100
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTest.rf,
        test$team == test$Away ~ 1 - predTest.rf,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        randfor1 = paste0("<b>Random Forest :</b>", "We recommend to put a bet on ","<b>" ,test$team,"</b>" )
      } else {
        randfor1 = paste0("<b>Random Forest :</b>","There is no optimal prediction for this match: the coefficients are not profitable.")
      }  
      

      
      
      
      
      
      
      
      
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train$HOME_WIN = as.numeric(train$HOME_WIN) - 1
      test$HOME_WIN = as.numeric(test$HOME_WIN) - 1
      train1 = fastDummies::dummy_cols(train,remove_selected_columns = T,remove_first_dummy = TRUE)
      test1 = fastDummies::dummy_cols( test,remove_selected_columns = T,remove_first_dummy = TRUE)
      nn=neuralnet(HOME_WIN~.,data=(train1 %>% na.omit()) , hidden=c(20,10),act.fct = "logistic",
                   linear.output = FALSE)
      
      predTrain.nn = predict(nn,train1 %>% na.omit())
      predTest.nn = predict(nn, test1 %>% na.omit())
      Ann.pred.train0.5 = ifelse(predTrain.nn > 0.5,1,0)
      Ann.pred.test0.5 = ifelse(predTest.nn > 0.5,1,0)
      test$Home=as.character(test$Home)
      test$Away=as.character(test$Away)
      if (as.numeric(Ann.pred.test0.5) > 0.5){
        
        result = test[1,"Home"]
        coeff = test[1,4]
        
      } else {
        result = test[1,"Away"]
        coeff = test[1,2]
      }    
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      test$value_home = predTest.nn * 100 * (test$HODD - 1) - (1-predTest.nn) * 100
      test$value_away = (1-predTest.nn) * 100 * (test$AODD - 1) - predTest.nn * 100
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTest.nn,
        test$team == test$Away ~ 1 - predTest.nn,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        ann1 = paste("<b>ANN :</b>" ,"We recommend to put a bet on ","<b>" ,test$team,"</b>")
      } else {
        ann1 = paste("<b>ANN :</b>","There is no optimal prediction for this match: the coefficients are not profitable.")
      }  
      
      

      
      
      
      
      
      
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      model.boost=gbm((as.numeric(HOME_WIN)-1)~., data=train, distribution="bernoulli", n.trees=2000, interaction.depth=5)
      predTrainProb.boost = predict(model.boost, train, n.trees = 2000, type = "response")
      predTestProb.boost = predict(model.boost, test, n.trees = 2000, type = "response")
      Train.pred0.5.boost <- ifelse(predTrainProb.boost> 0.5,1,0)
      Test.pred0.5.boost <- ifelse(predTestProb.boost> 0.5,1,0)
      if (as.numeric(predTestProb.boost) >= 0.5){
        
        result = test[1,3]
        coeff = test[1,4]
        
      } else {
        result = test[1,1]
        coeff = test[1,2]
      }
      
      test$Home = as.character(test$Home)
      test$Away = as.character(test$Away)
      test$value_home = predTestProb.boost * 100 * (test$HODD - 1) - (1-predTestProb.boost) * 100
      test$value_away = (1-predTestProb.boost) * 100 * (test$AODD - 1) - predTestProb.boost * 100
      test$team = case_when(
        (test$value_home >= test$value_away) & (test$value_home > 0) ~ test$Home,
        (test$value_away >= test$value_home) & (test$value_away > 0) ~ test$Away,
        TRUE ~ "0")
      test$coeff = dplyr::case_when(
        test$team == test$Home ~ test$HODD,
        test$team == test$Away ~ test$AODD,
        TRUE ~ 0)
      test$prob = dplyr::case_when(
        test$team == test$Home ~ predTestProb.boost,
        test$team == test$Away ~ 1 - predTestProb.boost,
        TRUE ~ 0)
      
      if (test$team != as.factor(0)){
        boosting1 = paste("<b>Boosting :</b>" ,"We recommend to put a bet on ","<b>" ,test$team,"</b>")
      } else {
        boosting1 = paste("<b>Boosting :</b>" ,"There is no optimal prediction for this match: the coefficients are not profitable.")
      }
      

      
      
      
      
      
      
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      #####CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      factors <- which(sapply(train, is.factor))
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2, as.numeric(be$nlevels[10]) != 1)
      WORSE = factors[BAD]
      #####CODE#####
      formula <- as.formula(paste(colnames(train)[222],'~', paste(colnames(train)[-WORSE],collapse = "+")))
      log.model = glm(formula, data = train, family = binomial(link = 'logit'))
      Log.train = predict(log.model, newdata = train, type = "response")
      Log.test = predict(log.model, newdata = test, type = "response")
      new_Log.test = predict(log.model, newdata = new_test, type = "response")
      Log.pred.train0.5 = ifelse(Log.train > 0.5,1,0)
      Log.pred.test0.5 = ifelse(Log.test > 0.5,1,0)
      new_Log.pred.test0.5 = ifelse(new_Log.test > 0.5,1,0)
      set.seed(1)
      model.rf=randomForest::randomForest(HOME_WIN~.,data=train, mtry=5, ntree = 1000)
      predTrain.rf =as.numeric(predict(model.rf, train)) - 1
      predTest.rf = as.numeric(predict(model.rf, test)) - 1
      new_predTest.rf = as.numeric(predict(model.rf, new_test)) - 1
      train$HOME_WIN = as.numeric(train$HOME_WIN) - 1
      test$HOME_WIN = as.numeric(test$HOME_WIN) - 1
      new_test$HOME_WIN = as.numeric(new_test$HOME_WIN) - 1
      train1 = fastDummies::dummy_cols(train %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      test1 = fastDummies::dummy_cols( test %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      new_test1 = fastDummies::dummy_cols( new_test %>% select(-HOME_WIN),remove_selected_columns = T,remove_first_dummy = TRUE)
      train1$HOME_WIN = train$HOME_WIN
      test1$HOME_WIN = test$HOME_WIN
      new_test1$HOME_WIN = new_test$HOME_WIN
      nn=neuralnet(HOME_WIN~.,data=(train1 %>% na.omit()) , hidden=c(20,10),act.fct = "logistic",
                   linear.output = FALSE)
      
      
      predTrain.nn = predict(nn,train1 %>% na.omit())
      predTest.nn = predict(nn, test1 %>% na.omit())
      new_predTest.nn = predict(nn, new_test1 %>% na.omit())
      Ann.pred.train0.5 = ifelse(predTrain.nn > 0.5,1,0)
      Ann.pred.test0.5 = ifelse(predTest.nn > 0.5,1,0)
      new_Ann.pred.test0.5 = ifelse(new_predTest.nn > 0.5,1,0)
      test = winner %>% filter(ID==game_id1())
      train = winner %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      model.boost=gbm((as.numeric(HOME_WIN)-1)~., data=train, distribution="bernoulli", n.trees=2000, interaction.depth=5)
      predTrainProb.boost = predict(model.boost, train, n.trees = 2000, type = "response")
      predTestProb.boost = predict(model.boost, test, n.trees = 2000, type = "response")
      new_predTestProb.boost = predict(model.boost, new_test, n.trees = 2000, type = "response")
      Train.pred0.5.boost <- ifelse(predTrainProb.boost> 0.5,1,0)
      Test.pred0.5.boost <- ifelse(predTestProb.boost> 0.5,1,0)
      new_Test.pred0.5.boost <- ifelse(new_predTestProb.boost> 0.5,1,0)
      dataStack =  data.frame(reg = Log.pred.test0.5, 
                              rf = predTest.rf, 
                              ann = Ann.pred.test0.5,
                              gbm = Test.pred0.5.boost,
                              HOME_WIN = as.numeric(test$HOME_WIN)-1)
      
      model.stack = caret::train(HOME_WIN~., data=(dataStack %>% na.omit() ), method = "glm")
      predictionsTest = data.frame(reg = new_Log.pred.test0.5,
                                   rf = new_predTest.rf,
                                   ann = new_Ann.pred.test0.5,
                                   gbm = new_Test.pred0.5.boost,
                                   HOME_WIN = as.numeric(new_test$HOME_WIN)-1)
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      new_test$Home=as.character(new_test$Home)
      new_test$Away=as.character(new_test$Away)
      
      if (predTest.stack > 0.5){
        
        result = new_test[1,"Home"]
        coeff = new_test[1,4]
        
      } else {
        result = new_test[1,"Away"]
        coeff = new_test[1,2]
      }    
      
      new_test$Home = as.character(new_test$Home)
      new_test$Away = as.character(new_test$Away)
      new_test$value_home = predTest.stack * 100 * (new_test$HODD - 1) - (1-predTest.stack) * 100
      new_test$value_away = (1-predTest.stack) * 100 * (new_test$AODD - 1) - predTest.stack * 100
      new_test$team = case_when(
        (new_test$value_home >= new_test$value_away) & (new_test$value_home > 0) ~ new_test$Home,
        (new_test$value_away >= new_test$value_home) & (new_test$value_away > 0) ~ new_test$Away,
        TRUE ~ "0")
      new_test$coeff = dplyr::case_when(
        new_test$team == new_test$Home ~ new_test$HODD,
        new_test$team == new_test$Away ~ new_test$AODD,
        TRUE ~ 0)
      new_test$prob = dplyr::case_when(
        new_test$team == new_test$Home ~ predTest.stack,
        new_test$team == new_test$Away ~ 1 - predTest.stack,
        TRUE ~ 0)
      
      if (new_test$team != as.factor(0)){
        stack1 = paste("<b>Stacking :</b>" ,"We recommend to put a bet on ","<b>" ,new_test$team,"</b>")
      } else {
        stack1 = paste0("<b>Stacking :</b>" ,"There is no optimal prediction for this match: the coefficients are not profitable." )
      }
      
      
      if (test$HOME_WIN == 1){
        
        winner = test[1, "Home"]
        
      } else {
        winner = test[1, "Away"]
      }
      str2 = paste("The true winner of this match is","<b>", winner,"</b>")
      HTML(paste(coef,logist1,randfor1,boosting1,ann1, stack1,str2, sep = '<br/>'))
    
      
      
      
      
        
    }
    
    
    
    
    #FOR TOTAL################
    else if(input$predict_type == "Total"){
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)            
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))            
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse = "+")))
      
      reg = lm(formula, data = train)
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      
      if (as.numeric(pred.Regression.Test) >= test$TotalClose){
        
        result = paste("Total over", test$TotalClose)
        
      } else {
        result = paste("Total under", test$TotalClose)
        
      }
      
      reg1 = paste("<b>Regression :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      
      
      
      model.boost2=gbm(Total~., data=train, distribution="gaussian", n.trees=input$BOOSTntree, 
                       interaction.depth=2, verbose=F)
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = input$BOOSTntree, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = input$BOOSTntree, type = "response")
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      if (as.numeric(predTestProb.boost2) >= test$TotalClose){
        
        result = paste("Total over", test$TotalClose)
        
      } else {
        result = paste("Total under", test$ForaClose)
        
      }
      
      boost1 = paste("<b>Boosting :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      
      
      
      
      
      
      
      
      test = total %>% filter(ID==game_id1())
      train = total %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)
      
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse = "+")))
      
      reg = lm(formula, data = train)
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      new_pred.Regression.Test = predict(reg, newdata = new_test)
      
      
      model.boost2=gbm(Total~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      new_predTestProb.boost2 = predict(model.boost2, new_test, n.trees = 1000, type = "response")
      
      
      
      model.boost3=gbm(Total~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      new_predTestProb.boost3 = predict(model.boost3, new_test, n.trees = 1000, type = "response")
      
      dataStack =  data.frame(reg = pred.Regression.Test, 
                              gbm2 = predTestProb.boost2, 
                              gbm3 = predTestProb.boost3,
                              Total = test$Total)
      
      
      model.stack = caret::train(Total~., data=(dataStack %>% na.omit() ), method = "ctree")
      
      predictionsTest = data.frame(reg = new_pred.Regression.Test, 
                                   gbm2 = new_predTestProb.boost2, 
                                   gbm3 = new_predTestProb.boost3, 
                                   Total = new_test$Total)
      
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      
      
      if (as.numeric(predTest.stack) >= new_test$TotalClose){
        
        result = paste("Total over", new_test$TotalClose)
        
      } else {
        result = paste("Total under", new_test$TotalClose)
        
      }
      
      stacking = paste("<b>Stacking :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      str2 = paste( "True total is","<b>", new_test$Total,"</b>")
      
      
      
      HTML(paste(reg1, boost1,stacking,str2, sep = '<br/>'))
      
     
      
       
    }
    
    
    
    
    
    
    
    
    
    
    
    #FOR FORA
    else if(input$predict_type == "Fora"){
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)            
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', paste(geegun,collapse = "+")))
      
      reg = lm(formula, data = train)
      
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      if (as.numeric(pred.Regression.Test) >= test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else  if (as.numeric(pred.Regression.Test) < test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      } else  if (as.numeric(pred.Regression.Test) >= test$ForaClose & test$ForaClose >= 0 ){
        
        result = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      reg1 = paste("<b>Regression :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      
      
      
      model.boost2=gbm(Fora~., data=train, distribution="gaussian", n.trees=input$BOOSTntree, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = input$BOOSTntree, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = input$BOOSTntree, type = "response")
      if (as.numeric(pred.Regression.Test) >= test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(test$ForaClose), "in favour of", test$Away)
        
      } else  if (as.numeric(predTestProb.boost2) < test$ForaClose & test$ForaClose <= 0 ){
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      } else  if (as.numeric(predTestProb.boost2) >= test$ForaClose & test$ForaClose >= 0 ){
        
        result = paste("Handicap", -test$ForaClose, "in favour of", test$Away)
        
      } else {
        
        result = paste("Handicap", test$ForaClose, "in favour of", test$Home)
        
      }
      
      boost1 = paste("<b>Boosting :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      

      
      
      
      
      test = fora %>% filter(ID==game_id1())
      train = fora %>% filter(GDate < as.Date(input$date))
      test = test %>% select(-GDate,-code,-ID)
      train = train %>% select(-GDate,-code,-ID)            
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))  
      
      train <- as.data.frame(unclass(train)) 
      test = as.data.frame(unclass(test))
      
      new_test=test
      sicko = train
      train = sicko[1:round(0.6*nrow(sicko)),]
      test = sicko[ceiling(0.6*nrow(sicko)):nrow(sicko),]
      
      #######CODE#####
      debug_contr_error <- function (train, subset_vec = NULL) {
        if (!is.null(subset_vec)) {
          ## step 0
          if (mode(subset_vec) == "logical") {
            if (length(subset_vec) != nrow(train)) {
              stop("'logical' `subset_vec` provided but length does not match `nrow(train)`")
            }
            subset_log_vec <- subset_vec
          } else if (mode(subset_vec) == "numeric") {
            ## check range
            ran <- range(subset_vec)
            if (ran[1] < 1 || ran[2] > nrow(train)) {
              stop("'numeric' `subset_vec` provided but values are out of bound")
            } else {
              subset_log_vec <- logical(nrow(train))
              subset_log_vec[as.integer(subset_vec)] <- TRUE
            }
          } else {
            stop("`subset_vec` must be either 'logical' or 'numeric'")
          }
          train <- base::subset(train, subset = subset_log_vec)
        } else {
          ## step 1
          train <- stats::na.omit(train)
        }
        if (nrow(train) == 0L) warning("no complete cases")
        ## step 2
        var_mode <- sapply(train, mode)
        if (any(var_mode %in% c("complex", "raw"))) stop("complex or raw not allowed!")
        var_class <- sapply(train, class)
        if (any(var_mode[var_class == "AsIs"] %in% c("logical", "character"))) {
          stop("matrix variables with 'AsIs' class must be 'numeric'")
        }
        ind1 <- which(var_mode %in% c("logical", "character"))
        train[ind1] <- lapply(train[ind1], as.factor)
        ## step 3
        fctr <- which(sapply(train, is.factor))
        if (length(fctr) == 0L) warning("no factor variables to summary")
        ind2 <- if (length(ind1) > 0L) fctr[-ind1] else fctr
        train[ind2] <- lapply(train[ind2], base::droplevels.factor)
        ## step 4
        lev <- lapply(train[fctr], base::levels.default)
        nl <- lengths(lev)
        ## return
        b = list(nlevels = nl, levels = lev)
        assign("be", b, envir = .GlobalEnv)
      }
      
      debug_contr_error(train)
      be$nlevels
      
      
      factors <- which(sapply(train, is.factor))
      factors = factors[1:9]
      
      BAD = c(as.numeric(be$nlevels[1]) != 30, as.numeric(be$nlevels[2]) != 30, as.numeric(be$nlevels[3]) != 2, as.numeric(be$nlevels[4]) != 2, as.numeric(be$nlevels[5]) != 2, as.numeric(be$nlevels[6]) != 2, as.numeric(be$nlevels[7]) != 3, as.numeric(be$nlevels[8]) != 2, as.numeric(be$nlevels[9]) != 2)
      
      WORSE = factors[BAD]
      
      WORSE = factors[BAD]
      
      if (length(WORSE) == 0){
        
        geegun = colnames(train)
      } else {
        geegun = colnames(train)[-WORSE]
      }
      
      geegun = geegun[1:(length(geegun)-1)]
      
      #######CODE#####
      
      
      
      formula <- as.formula(paste(colnames(train)[222],'~', geegun))
      
      reg = lm(formula, data = train)
      
      
      pred.Regression.Train = predict(reg, newdata = train)
      pred.Regression.Test = predict(reg, newdata = test)
      new_pred.Regression.Test = predict(reg, newdata = new_test)
      
      
      model.boost2=gbm(Fora~., data=train, distribution="gaussian", n.trees=1000, 
                       interaction.depth=2, verbose=F)
      
      
      
      predTrainProb.boost2 = predict(model.boost2, train, n.trees = 1000, type = "response")
      predTestProb.boost2 = predict(model.boost2, test, n.trees = 1000, type = "response")
      new_predTestProb.boost2 = predict(model.boost2, new_test, n.trees = 1000, type = "response")
      
      
      model.boost3=gbm(Fora~., data=train, distribution="gaussian", n.trees=2000, 
                       interaction.depth=4, verbose=F)
      
      
      
      predTrainProb.boost3 = predict(model.boost3, train, n.trees = 1000, type = "response")
      predTestProb.boost3 = predict(model.boost3, test, n.trees = 1000, type = "response")
      new_predTestProb.boost3 = predict(model.boost3, new_test, n.trees = 1000, type = "response")
      
      
      
      dataStack =  data.frame(reg = pred.Regression.Test, 
                              gbm2 = predTestProb.boost2, 
                              gbm3 = predTestProb.boost3,
                              Fora = test$Fora)
      
      
      model.stack = caret::train(Fora~., data=(dataStack %>% na.omit() ), method = "ctree")
      
      predictionsTest = data.frame(reg = new_pred.Regression.Test, gbm2 = new_predTestProb.boost2, gbm3 = new_predTestProb.boost3, Fora = new_test$Fora)
      
      
      predTest.stack = predict(model.stack, newdata = predictionsTest)
      predTrain.stack = predict(model.stack, newdata = dataStack)
      
      
      if (as.numeric(predTest.stack) >= new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        result = paste("Handicap", abs(new_test$ForaClose), "in favour of", new_test$Away)
        
      } else  if (as.numeric(predTest.stack) < new_test$ForaClose & new_test$ForaClose <= 0 ){
        
        result = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Home)
        
      } else  if (as.numeric(predTest.stack) >= new_test$ForaClose & new_test$ForaClose >= 0 ){
        
        result = paste("Handicap", -new_test$ForaClose, "in favour of", new_test$Away)
        
      } else {
        
        result = paste("Handicap", new_test$ForaClose, "in favour of", new_test$Home)
        
      }
      
      str2 = paste("<b>Stacking : </b>","The true handcap is","<b>", new_test$Fora,"</b>")
      
      stack1 = paste("<b>Boosting :</b>","The prediction is - ", paste("<b>",result,"</b>"))
      
      
      
      
      HTML(paste(reg1,boost1,stack1,str2, sep = '<br/>'))
      
      
      
      
    }
    
    
    
    
    
  })#ALLPRED END
  
  output$lasttable = renderText(allpred())
  
  song <- eventReactive(input$hype, {tags$audio(src = "sicko.mp3", type = "audio/mp3", autoplay = "autoplay", controls = "controls")
  })
  
  output$hypesong = renderUI({song()})
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
