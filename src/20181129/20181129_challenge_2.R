camera_trap_data <- read.csv(file = "../data/20180123/20180123_observations_NPHK_cameratrapping.csv",
                             stringsAsFactors = FALSE, as.is = TRUE)

# transform the date columns to datetime
op <- options(digits.secs=3)
camera_trap_data$deploymentStart <- strptime(camera_trap_data$deploymentStart,
                                             format = "\"%Y-%m-%dT%H:%M:%OSZ\"")
camera_trap_data$deploymentEnd <- strptime(camera_trap_data$deploymentEnd,
                                           format = "\"%Y-%m-%dT%H:%M:%OSZ\"")
camera_trap_data$observationTimestamp <- strptime(camera_trap_data$observationTimestamp,
                                           format = "\"%Y-%m-%dT%H:%M:%OSZ\"")

# counts of humans (where animalVernacularName is 'Human') per month (sequenceMonth)
camera_trap_data_humans <- camera_trap_data[camera_trap_data$animalVernacularName =="Human",]

counts_per_month <- aggregate(camera_trap_data_humans$animalCount,
            by=list(sequenceMonth=camera_trap_data_humans$sequenceMonth),
            FUN=sum)
# rename to 'humans_observed'
colnames(counts_per_month)[colnames(counts_per_month)=="x"] <- "humans_observed"
# sort by 'humans_observed'
counts_per_month <- counts_per_month[order(counts_per_month$humans_observed,
                                           decreasing = TRUE),]