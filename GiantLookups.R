## LIBRARY THAT ENABLES THE HTTPS CALL ## 
library(httr)

## READ IN THE LOOKUP VALUES OF CONCERN ##
mylookup <- read.csv("mylookup.csv", header = FALSE)

## ARBITRARY "CHUNK" SIZE TO KEEP SEARCHES SMALLER ##
start <- 1
end <- 1000

## CREATE AN EMPTY DATA FRAME THAT WILL HOLD END RESULTS ##
alldata <- data.frame()

## HOW MANY "CHUNKS" WILL NEED TO BE RUN TO GET COMPLETE RESULTS ##
for(i in 1:250){
        ## CREATES THE LOOKUP STRING FROM THE mylookup VARIABLE ##
        lookupstring <- paste(mylookup[start:end], sep = "", collapse = '" OR VAR_NAME="')
        
        ## CREATES THE SEARCH STRING; THIS IS A SIMPLE SEARCH EXAMPLE ##
        searchstring <- paste('index = "my_splunk_index" (VAR_NAME="', lookupstring, '") | stats count BY VAR_NAME', sep = "")
        
        ## RUNS THE SEARCH; SUB IN YOUR SPLUNK LINK, USERNAME, AND PASSWORD ##
        response <- GET("https://our.splunk.link:8089/", 
                        path = "servicesNS/admin/search/search/jobs/export", 
                        encode="form", config(ssl_verifyhost=FALSE, ssl_verifypeer=0), 
                        authenticate("USERNAME", "PASSWORD"), 
                        query=list(search=paste0("search ", searchstring, collapse="", sep=""), 
                                   output_mode="csv"))
        
        ## CHANGES THE RESULTS TO A DATA TABLE ## 
        result <- read.table(text=content(response, as="text"), sep=",", header=TRUE,
                             stringsAsFactors=FALSE)
        
        ## BINDS THE CURRENT RESULTS WITH THE OVERALL RESULTS ##
        alldata <- rbind(alldata, result)
        
        ## UPDATES THE START POINT
        start <- end + 1
        
        ## UPDATES THE END POINT, BUT MAKES SURE IT DOESN'T GO TOO FAR ##
        if((end + 1000) > length(allusers)){
                end <- length(allusers)
        } else {
                end <- end + 1000
        }
        
        ## FOR TROUBLESHOOTING, I PRINT THE ITERATION ##
        #print(i)
}

## WRITES THE RESULTS TO A CSV ##
write.table(alldata, "mydata.csv", row.names = FALSE, sep = ",")