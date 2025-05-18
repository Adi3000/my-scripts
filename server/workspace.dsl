workspace "Adi3000 system" {

    model {
        
        // Personnes
        storageUser = person "Need file storage"
        homeUser = person "Need home automation"
        streamUser = person "Need media streaming"
        blogUser = person "Need to write an article"
        cerbinouUser = person "Need to ask a question"
        gamerUser = person "Need to Game"
        computerUser = person "Need to use Internet"
        downloaderUser = person "Need a new download"

        google = softwareSystem "Google Cloud" "Google Cloud Plateform" {
            cloudRun = container "Cloud Run" "Serverless docker instances" {
                gcpAuthentik = component "Authentik"
                gcpNextCloud = component "Nextcloud"
                gcpWordPress = component "Wordpress"
                gcpPlex = component "Plex Server"
            }
        }
        
        aiven = softwareSystem "Aiven Data storage" {
            postgresql = container "PostgreSQL"  {
                pgAuthentik = component "Postgresql Authentik"
                pgNextcloud = component "Postgresql Nextcloud"
            }
            redis = container "Redis" {
                redisAuthentik = component "Redis Authentik"
            }
            mySql = container "Cloud Run"  {
                wpPriseDeTete = component "MySQL Prise de tete"
                wpZapette = component "MySQL LaZapette"
            }
        }

        vps = softwareSystem "VPS" {
            homeAutomationServices = container "MQTT server" {
                mqtt = component "Zigbee MQTT Server"
                rednode = component "Rednode for home"
                homeAssistant = component "Home assistant for Maman-home"
            }
            blocky = container "Blocky DNS" {
                parentalControl = component "Parental DNS filtering"
                adRemover = component "Ads DNS filtering"
            }
            traefik = container "Traefik" {
                authentikDomain = component "login.adi3000.com"
                fafnirDomain = component "fafnir.adi3000.com"
                homeDomain = component "adi-home.adi3000.com"
                plexDomain = component "plex.adi3000.com"
            }
            torrent = container "Torrent downloader" {
                rutorrent = component "Rutorrent"
                rtorrent = component "RTorrent"
            }
            fileAnalyzer = container "Classifier for files Storage" {
                photoTagger = component "Auto tag photo"
            }
        }

        home = softwareSystem "Home component" {
            computer = container "Computer" {
                moonlight = component "Moonlight"    
            }
            router = container "Router" {
                ps4Port = component "Port PS4"
                moonLightPort = component "Port Moonlight"
            }
            ps4 = container "PS4" {
                remotePlay = component "Remote play"
            }
            zigbeeMesh = container "Zigbee Mesh" {
                homeAutomationComponent = component "Components Zigbee"
            }
            pizigbee = container "PiZigbee" {
                homeZ2MQTT = component "Zigbee2MQTT"
                remoteDomoPi = component "Remote Domo Pi"
                cerbinou = component "Cerbinou"
            }
            raspberry = container "Raspian" {
                fileStorage = component "File Storage"
                streamStorage = component "Movie/Serie Storage"
            }
        }
        storageUser -> fafnirDomain "Call for Nextcloud"
        fafnirDomain -> gcpAuthentik "Ensure authentication"
        gcpAuthentik -> pgAuthentik "Preserve users info"
        fafnirDomain -> gcpNextCloud "Trigger Nextcloud instance"
        gcpNextCloud -> pgNextcloud "Read data"
        gcpNextCloud -> fileStorage "Fetch files"
        photoTagger -> fileStorage "Autotag Photo"
        photoTagger -> pgNextcloud "Enhence photo metadata"
        
        homeUser -> homeDomain "Call for HomeDomain"
        homeDomain -> gcpAuthentik "Ensure authentication"
        homeDomain -> rednode "Controle house"
        rednode -> homeZ2MQTT "Receive signals"
        
        streamUser -> plexDomain "Stream a movie"
        plexDomain -> gcpAuthentik "Ensure authentication"
        plexDomain -> gcpPlex "Stream video"
        gcpPlex -> streamStorage "Fetch film to stream"
        
    }
    views {
        styles {        
            element "Component" {
                background #96c2af
                color #ffffff
            }
            element "Container" {
                background #6894b9
                color #ffffff
            }
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
        }
    }

}
