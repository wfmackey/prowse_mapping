##Install and load ('library') packages required:
require("placement")
require("ggplot2")
require("plyr")
require("readr")
require("ggmap")


##Setting working directory: "these are where the files I'm talking about are"
  ##ie this is where your prescriptor/dispenser list .csv files are
  ##You can do this view the "files" tab on the bottom right hand side
  ##Navigate to your folder of choice, then hit the settings icon, hit "set as working directory"
  ##IF you do select your working directory manually as above, "comment out" (add ## in front of) or delete the setwd line below 
  ##Alternatively, put in the folder path between the quotation marks here:
setwd("~/Google Drive/prowse_guide")


##In the folder that has been set as the working directory, what is the .csv file called?
##THIS IS THE FILE YOU WILL CHANGE TO BE THE .csv FILE YOU HAVE MADE
##THIS IS THE FILE YOU WILL CHANGE TO BE THE .csv FILE YOU HAVE MADE
##THIS IS THE FILE YOU WILL CHANGE TO BE THE .csv FILE YOU HAVE MADE
##THIS IS THE FILE YOU WILL CHANGE TO BE THE .csv FILE YOU HAVE MADE
csv <- "gen_sample.csv"


  
##Read in our data. We are creatively calling our data "data".
data <- read_csv(csv)
  ##To explain this further, because it's important:
    #"object name" <- "function called read.csv that nicely imports our csv file into R" ("name of file, which we have already defiled as 'csv'")
    #you can change the object name to something else / something more convenient (noting that you'll have to change it in the proceding lines!)

##Examining our data
View(data)            #Look at it
names(data)           #Display the variable names to make sure everything is in order

print(data$postcode)  #Look at all observations from DATASET$COLUMN
print(data$origin_postcode)  #Look at all observations from DATASET$COLUMN

##Now, we're going to be using the drive_time function of the `placement` package. We can ask R to provider some useful information:
? drive_time
# in the "help" window, there will be "Usage", which describes the syntax of the function. It looks like:

    # drive_time(address, dest, auth = "standard_api", privkey = NULL,
    #            clientid = NULL, clean = "TRUE", travel_mode = "driving",
    #           units = "metric", verbose = FALSE, add_date = "none",
    #           language = "en-EN", messages = FALSE, small = FALSE)


# the "Arguments" section will provide insight into all of these arguments. Give it a read.

##Let's test the drive_time function on the 2nd [2] observation
drive_time_test <- drive_time(data$name[2],
                              data$origin_postcode[2] ,
                              travel_mode = "driving" ,
                              privkey = "" ,
                              units = "metric",
                              clean = FALSE
)

View(drive_time_test)
# Cool! Looks like it worked. But, maybe, we can make it better/more reliable in the face of all addresses/postcodes

##Now, what if we gave Google a bit more information? Say:
new_clinic <- paste0(data$name,", ",data$postcode, ", Australia")       #surely this will mean Google finds them!
  #What does this new object look like?
  View(new_clinic)

  #Great! And we'll add some detail to the postcodes (when you have time: add STATE to the .csv, as this will help)
new_origin <-   paste0("Postcode ", data$origin_postcode, ", Australia")
# Let's merge it with the rest:
new_data <- data.frame(new_clinic, new_origin)
  View(new_data)

  
#Wonderful, now we're ready to test it again, this time using the 5th observation:
drive_time_test2 <- drive_time(new_data$new_clinic[5] ,
                              new_data$new_origin[5] ,
                              travel_mode = "driving" ,
                              privkey = "" ,
                              units = "metric"
)

  View(drive_time_test2)

##Now we can run all of the observations through!
drive_time <- drive_time(new_data$new_clinic ,
                             new_data$new_origin ,
                             travel_mode = "driving" ,
                             privkey = "" ,
                             units = "metric"
)
  
View(drive_time)



##Done, great, wooh. Now we can export to csv and, from there, do whatever you want!
#Create a nice dataset with the variables we want
final_data <- data.frame(new_data$new_clinic,
                         drive_time$origin,
                         new_data$new_origin,
                         drive_time$destination,
                         drive_time$dist_num,
                         drive_time$time_mins)

write.csv(final_data,file = "final_data.csv")



##########Part 2: Mapping
# Where we used Google's handy search function to find our place of interest, we can also search it for latlong coordinates
#wfm_api <- "AIzaSyBd0Usn4qdFPCIY92EgOifNI87vxqUmy8g"

coords_clinic <-  geocode_url(new_data$new_clinic, 
                  privkey = wfm_api,
                  auth = "standard_api"
                  )

View(coords_clinic)

#Oooh, now we can plot all the clinics on a map!
qmplot(lng, lat, 
       data = coords_clinic, 
       zoom = 4,
       padding = 0,
       f = .30,
       color=I("orange"))
